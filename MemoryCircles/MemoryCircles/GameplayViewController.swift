//
//  ViewController.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/22/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import UIKit
import CoreData
import iAd

/*

This is the ViewController that manages the actual game
Utilizes CoreData to keep track of the user's high score


*/


class GameplayViewController: UIViewController{
    
    var lastUsedColor: UIColor = UIColor.clearColor()//Var to make sure color changes
    
    var roundColor: UIColor = UIColor.clearColor()
    
    //Possible Colors for the circles
    let computerRunColors: [UIColor] = [UIColor.blueColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.greenColor(), UIColor.whiteColor()]
    
    
    var redAlertFlag: Bool = false //tells if the user is being alerted they lost
    
    var keepPlaying: Bool = true //Tells the ViewController whether to show another pattern
    
    var middleOfComputerRun: Bool = false //invalidates any taps during the initial sequence
    
    var tapQueue: [Int]? = [Int]() //An array to keep track of user input
    
    var currentPattern: [Int] = [Int]() //The correct sequence of dots
    
    var highScoreSafe = [NSManagedObject]() //An object to place queries to CoreData
    
    var timer = 4 //Countdown timer
    
    var speedFactor: Double = 2.5
    
    //Keeps track of the user's score and resets the label when it changes
    var score: Int = 0{
        didSet{
            scoreLabel?.text = String(score)
        }
    }
    
    var logItems = [LogItem]() //An object to place queries to CoreData
    
    var middleOfGame: Bool = false //Keeps track if the game is in progress
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    func getRandomColor() -> UIColor{
        
        var randIndex: Int = Int(arc4random_uniform(UInt32(computerRunColors.count)))
        var randColor = self.computerRunColors[randIndex]
        
        while(randColor==lastUsedColor){
            randIndex = Int(arc4random_uniform(UInt32(computerRunColors.count)))
            randColor = self.computerRunColors[randIndex]
        }
        lastUsedColor = randColor
        return randColor
    }
    
    
    //As long as the computer isn't showing its sequence, a tap turns the circle blue
    @IBAction func touchDown(sender: TapCircleView) {
        if(!middleOfComputerRun && !redAlertFlag && middleOfGame){
            sender.desiredColour = roundColor
            sender.desiredOutlineColor = roundColor
        }
    }
    
    
    
    @IBOutlet weak var scoreLabel: UILabel! //Label displaying the current score
    
    
    //A tap adds it to TapQueue where it will then be evaluated if it matches the computer's sequence
    @IBAction func tap(sender: TapCircleView) {
        if(!middleOfComputerRun && middleOfGame){
            sender.desiredColour = UIColor.clearColor()
            sender.desiredOutlineColor = UIColor.blackColor()
            switch sender{
            case tapCircle1: self.addNumToTapQueue(0)
            case tapCircle2: self.addNumToTapQueue(1)
            case tapCircle3: self.addNumToTapQueue(2)
            case tapCircle4: self.addNumToTapQueue(3)
            case tapCircle6: self.addNumToTapQueue(4)
            case tapCircle7: self.addNumToTapQueue(5)
            case tapCircle8: self.addNumToTapQueue(6)
            case tapCircle9: self.addNumToTapQueue(7)
            default: break;
            }
        }
    }
    //The outlets connecting the circle views to the controller
    @IBOutlet weak var tapCircle1: TapCircleView!
    
    @IBOutlet weak var tapCircle2: TapCircleView!
    
    @IBOutlet weak var tapCircle3: TapCircleView!
    
    
    @IBOutlet weak var tapCircle4: TapCircleView!
    
    @IBOutlet weak var tapCircle5: TapCircleView!

    
    @IBOutlet weak var tapCircle6: TapCircleView!
    
    @IBOutlet weak var tapCircle7: TapCircleView!
    
    @IBOutlet weak var tapCircle8: TapCircleView!
 
    @IBOutlet weak var tapCircle9: TapCircleView!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Make sure the score label is formatted correctly
        scoreLabel.center = tapCircle5.center
        scoreLabel.text = " "
        tapCircle5.desiredOutlineColor = UIColor.clearColor()
    
        //This is the clock that manages the countdown at the start of gameplay
        var clock = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countdown:"), userInfo: nil, repeats: true)
        
        
        
        //Do the first run after the countdown is finished
        let triggerTime = (Int64(NSEC_PER_SEC * 4))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.roundColor = self.getRandomColor()
                let pattern: [Int] = self.createAPattern(3)
                self.scoreLabel.text = String(self.score)
                //print(pattern)
                self.currentPattern = pattern
                self.doComputerRun(pattern, withSpeedFactor: 2.5)
            
        })
        
    }
    
    
    //Manages the countdown at the beginning of gameplay by updating the label every second
    func countdown(clock: NSTimer) {
        
        timer--
        if(timer == 0){
            clock.invalidate()
            tapCircle5.desiredOutlineColor = UIColor.redColor()
            tapCircle5.desiredColour = UIColor.redColor()   
        }
        scoreLabel.text = String(timer)
    }
    
    
    
    //Used to access CoreData to retrieve the high score
    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "LogItem")
        
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "title == %@", "score")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        do{
        let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [LogItem]
            self.logItems = fetchResults!
            }
        catch{
            
        }
    }
    
    
    //Returns the user's High Score by looking at logItems
    func getHighScore() -> Int{
        fetchLog()
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let logItem = logItems[indexPath.row]
        return Int(logItem.score)
    }
    
    //Updates the user's High Score, Saves to Core Data
    func setHighScore(highScore: Int){
        fetchLog()
        
        //If there is no fetched score, then create a record with value 0
        if(logItems.count==0){
           LogItem.createInManagedObjectContext(managedObjectContext, title: "score", score: Int16(0))
            do{
                try managedObjectContext.save()
            }
            catch{
            }
        }
            
        //If there is a fetched record than update it with the new value
        else{
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let logItem = logItems[indexPath.row]
        logItem.setValue(highScore, forKey: "score")
            do{
                try managedObjectContext.save()
            }
            catch{}
        }
    }
    
    
    
    
    //Display a sequence of dots for the user to remember
    //Takes a pattern in the form of an Int array 
    //withSpeedFactor is how the controller alters the speed of the sequence
    func doComputerRun(withPattern: [Int], withSpeedFactor: Double){
        
        //Marks the following variables to ensure proper interactions with taps
        self.middleOfComputerRun = true
        self.middleOfGame = true
        
        //Change middle circle to red during run
        tapCircle5.desiredColour = UIColor.redColor()
        tapCircle5.desiredOutlineColor = UIColor.redColor()
        
        
        var delayCount: Int = 1 //Manages how long to delay the display of the dot
        for circleIndex in withPattern{
            
            //Changes the specified circle to a random color after triggerTime has elapsed
            let triggerTime = (Int64(Double(NSEC_PER_SEC)/withSpeedFactor) * Int64((delayCount)))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.changeToBlue(circleIndex, withSpeedFactor: withSpeedFactor)
            })
            
            delayCount++
        }
        
        
        //After all the dots are done displaying then change the middle circle back to clear
        let triggerTime = (Int64(Double(NSEC_PER_SEC)/withSpeedFactor) * Int64((withPattern.count+1)))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.tapCircle5.desiredColour = UIColor.clearColor()
            self.tapCircle5.desiredOutlineColor = UIColor.clearColor()
            self.middleOfComputerRun = false
        })
    }
    
    
    //Changes a circle to a random color after a certain elapsed time
    func changeToBlue(circleIndex: Int, withSpeedFactor: Double){
        let changingCircles: [TapCircleView] =
        [tapCircle1, tapCircle2, tapCircle3, tapCircle4, tapCircle6, tapCircle7, tapCircle8, tapCircle9]
        changingCircles[circleIndex].desiredColour =  roundColor
        changingCircles[circleIndex].desiredOutlineColor = roundColor
        let triggerTime = (Int64(Double(NSEC_PER_SEC) / withSpeedFactor))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.changeToClear(circleIndex)
        })
    }
    
    @IBAction func playAgain(sender: UIButton) {
        
        if(!middleOfGame){
            let pattern: [Int] = createAPattern(3)
            //print(pattern)
            currentPattern = pattern
            doComputerRun(pattern, withSpeedFactor: 2)
            middleOfGame = true
            keepPlaying = true
        }
    }
    
    
    //Changes circle back to clear color
    func changeToClear(circleIndex: Int){
        let changingCircles: [TapCircleView] =
        [tapCircle1, tapCircle2, tapCircle3, tapCircle4, tapCircle6, tapCircle7, tapCircle8, tapCircle9]
        changingCircles[circleIndex].desiredColour = UIColor.clearColor()
        changingCircles[circleIndex].desiredOutlineColor = UIColor.blackColor()
    }
    
    
    
    //Creates and returns a random pattern for the computer to execute
    func createAPattern(patternLength: Int) -> [Int]{
        var patternQueue: [Int] = [Int]()
        
        
        var lastPicked: Int = 0
        for _ in 1...patternLength{
            var nextPicked: Int = lastPicked
            //Make sure the same circle isn't picked twice in a row
            while( nextPicked == lastPicked){
                nextPicked = pickRandInt(8)
            }
            patternQueue.append(nextPicked)
            lastPicked = nextPicked
        }
        return patternQueue
    }
    
    
    //Picks a random int from 0 to num
    func pickRandInt(num: Int) -> Int{
        return Int(arc4random_uniform(UInt32(num)))
    }
    
    //Checks if the User taps matches the computer's dots
    func checkUserTaps(pattern: [Int]){
        print(tapQueue)
        if(pattern.count == tapQueue?.count){
            var tracker: Int = 0
            for num in pattern{
                if num != tapQueue?[tracker]{
                    //If any do not match then stop playing
                    keepPlaying = false
                    break;
                }
                tracker++
            }
        }
        else{ keepPlaying = false }
        
        //After done checking then process what to do next
        self.processRun()
        
    }
    
    
    //Adds a tap to the TapQueue and alerts to check when the number of taps = length of the original pattern
    func addNumToTapQueue(numToAdd: Int){
        if(tapQueue!.count+1 > currentPattern.count){
            return;
        }
            
        else if(tapQueue!.count+1 == currentPattern.count){
            tapQueue!.append(numToAdd)
            checkUserTaps(currentPattern)
        }
        else{
            tapQueue!.append(numToAdd)
        }
        
    }
    
    
    //Determines whether to keep playing or terminate game
    func processRun(){
        
        //If the user taps matched the computer's taps then set up another round
        if(keepPlaying){

            score++ //update score
            let newPatternLength = score/7 + 3 //every 7 rounds increase the pattern length
            let pattern: [Int] = createAPattern(newPatternLength)
            currentPattern = pattern
            
            lastUsedColor = roundColor
            roundColor = getRandomColor()
            
            
            tapQueue?.removeAll()//Clear user taps from previous round
            
            //Set the speed for the next round
            if(score<10){speedFactor = speedFactor + 0.3}
            else if(score<20){speedFactor = speedFactor + 0.25}
            else if(score<30){speedFactor = speedFactor + 0.1}
            else{speedFactor = speedFactor + 0.05}
            
            
            doComputerRun(pattern, withSpeedFactor: speedFactor) //start next level
        }
            
        //Manages when the user loses
        else{
            //print("you lose")
            tapQueue?.removeAll()
            middleOfGame = false
            
            
            //Check if this round's score was greater than the high score
            fetchLog()//access CoreData
            
            //create a record if this is the first time playing
            if(logItems.count==0){
                self.setHighScore(0)
            }
            
            //Check if this score beat the high score
            if(score > getHighScore()){
                setHighScore(score)
            }
            
            
            redAlert() //All circles flash red to indicate a loss
            
            
            //Seque to the Fail screen
            let triggerTime = (Int64(NSEC_PER_SEC) * Int64(1))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.clearAlert()
                self.performSegueWithIdentifier("End Game", sender: self)
            })
        }
        
        
        
    }
    

    //Change all circles to clear
    func clearAlert(){
        redAlertFlag = false
        
        self.tapCircle1.desiredColour = UIColor.clearColor()
        self.tapCircle2.desiredColour = UIColor.clearColor()
        self.tapCircle3.desiredColour = UIColor.clearColor()
        self.tapCircle4.desiredColour = UIColor.clearColor()
        self.tapCircle5.desiredColour = UIColor.clearColor()
        self.tapCircle6.desiredColour = UIColor.clearColor()
        self.tapCircle7.desiredColour = UIColor.clearColor()
        self.tapCircle8.desiredColour = UIColor.clearColor()
        self.tapCircle9.desiredColour = UIColor.clearColor()
        
        
        
        self.tapCircle1.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle2.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle3.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle4.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle5.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle6.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle7.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle8.desiredOutlineColor = UIColor.blueColor()
        self.tapCircle9.desiredOutlineColor = UIColor.blueColor()
        
    }
    
    //Change All circles to red
    func redAlert(){
        redAlertFlag = true
        
        self.tapCircle1.desiredColour = UIColor.redColor()
        self.tapCircle2.desiredColour = UIColor.redColor()
        self.tapCircle3.desiredColour = UIColor.redColor()
        self.tapCircle4.desiredColour = UIColor.redColor()
        self.tapCircle5.desiredColour = UIColor.redColor()
        self.tapCircle6.desiredColour = UIColor.redColor()
        self.tapCircle7.desiredColour = UIColor.redColor()
        self.tapCircle8.desiredColour = UIColor.redColor()
        self.tapCircle9.desiredColour = UIColor.redColor()
        
        
        
        self.tapCircle1.desiredOutlineColor = UIColor.redColor()
        self.tapCircle2.desiredOutlineColor = UIColor.redColor()
        self.tapCircle3.desiredOutlineColor = UIColor.redColor()
        self.tapCircle4.desiredOutlineColor = UIColor.redColor()
        self.tapCircle5.desiredOutlineColor = UIColor.redColor()
        self.tapCircle6.desiredOutlineColor = UIColor.redColor()
        self.tapCircle7.desiredOutlineColor = UIColor.redColor()
        self.tapCircle8.desiredOutlineColor = UIColor.redColor()
        self.tapCircle9.desiredOutlineColor = UIColor.redColor()
    }
    
    
    
    //Prepares the Fail screen after a loss
    override func prepareForSegue(seque: UIStoryboardSegue, sender: AnyObject?){
        if let identifier = seque.identifier{
            switch identifier{
                case "End Game":
                    if let vc = seque.destinationViewController as? FailScreenViewController{
                        vc.score = self.score
                        vc.highScore = getHighScore()
                }
            default: break
            }
        }
    }
    
}

