//
//  TutorialViewController.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/31/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    
    var middleOfComputerRun: Bool = false
    var readyForTaps: Bool = false
    var redo: Bool = false
    var playNow: Bool = false
    
    var tapQueue: [Int]! = [Int]()
    let currentPattern: [Int] = [0,2,4]
    let tutorialLabel = UILabel()
    
    @IBOutlet weak var scoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorialLabel.numberOfLines = 2
        self.tutorialLabel.adjustsFontSizeToFitWidth = true
        self.mainView.addSubview(tutorialLabel)
        scoreButton.setTitle("0", forState: UIControlState.Normal)
        
        let center = CGPoint(x: 0, y: tutorialLabel.superview!.bounds.height*(0.6))
        
        let labelHeight = (tutorialLabel.superview!.bounds.height)/6
        let labelWidth = tutorialLabel.superview!.bounds.width
        let labelSize = CGSize(width: labelWidth, height: labelHeight)
        let frame = CGRect(origin: center, size: labelSize)
       self.tutorialLabel.frame = frame
        self.tutorialLabel.font = UIFont(name: "Noteworthy", size: 30)
        self.tutorialLabel.textAlignment = NSTextAlignment.Center
        self.tutorialLabel.textColor = UIColor.whiteColor()
        
        
        firstInstruction()
        // Do any additional setup after loading the view.
    }
    
    func resizeTutorialLabel(){
        let center = CGPoint(x: 0, y: tutorialLabel.superview!.bounds.height*(0.6))
        
        let labelHeight = (tutorialLabel.superview!.bounds.height)/6
        let labelWidth = tutorialLabel.superview!.bounds.width
        let labelSize = CGSize(width: labelWidth, height: labelHeight)
        let frame = CGRect(origin: center, size: labelSize)
        self.tutorialLabel.frame = frame
        self.tutorialLabel.font = UIFont(name: "Noteworthy", size: 30)
        self.tutorialLabel.textAlignment = NSTextAlignment.Center
        self.tutorialLabel.textColor = UIColor.whiteColor()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.resizeTutorialLabel()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let computerRunColors: [UIColor] = [UIColor.blueColor(), UIColor.purpleColor(), UIColor.yellowColor(), UIColor.orangeColor(), UIColor.cyanColor(), UIColor.brownColor()]
    
    var lastUsedColor: UIColor = UIColor.clearColor()
    
    
    @IBAction func pressButton(sender: UIButton) {
        if(playNow){
            performSegueWithIdentifier("backToHome", sender: self)
        }
    }

    @IBOutlet weak var tapCircle6: TapCircleView!
    @IBOutlet weak var tapCircle8: TapCircleView!
    @IBOutlet weak var tapCircle7: TapCircleView!
    @IBOutlet weak var tapCircle4: TapCircleView!
    @IBOutlet weak var tapCircle2: TapCircleView!
    @IBOutlet weak var tapCircle9: TapCircleView!
    @IBOutlet weak var tapCircle3: TapCircleView!
    @IBOutlet weak var tapCircle1: TapCircleView!
    @IBOutlet weak var middleCircle: TapCircleView!
    @IBOutlet var mainView: UIView!
    
    
    
    @IBAction func touchDown(sender: TapCircleView) {
            if(!middleOfComputerRun && readyForTaps){
                sender.desiredColour = UIColor.yellowColor()
                sender.desiredOutlineColor = UIColor.yellowColor()
            }
    }
    
    
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
    
    func checkUserTaps(pattern: [Int]){
        //print(tapQueue)
        if(pattern.count == tapQueue?.count){
            var tracker: Int = 0
            for num in pattern{
                if num != tapQueue?[tracker]{
                    redo = true
                    self.processRun()
                    return
                }
                tracker++
            }
        }
        redo = false
        self.processRun()
        
    }
    func processRun(){
        if(redo){
           tutorialLabel.text = "Oops! Your pattern did not match! Try again!"
            tapQueue.removeAll()
            self.readyForTaps = false
            let triggerTime = (Int64(NSEC_PER_SEC * 2))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.firstInstruction()
            })
        }
        else{
            scoreButton.setTitle("1", forState: UIControlState.Normal)
          thirdInstruction()
        }
    }
    
    func thirdInstruction(){
        tutorialLabel.text = "Every time you get a pattern correct your score goes up!"
        let triggerTime = (Int64(NSEC_PER_SEC * 3))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.fourthInstruction()
        })
    }
    
    func fourthInstruction(){
        tutorialLabel.text = "It's that easy! But be careful..."
        let triggerTime1 = (Int64(NSEC_PER_SEC * 3))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime1), dispatch_get_main_queue(), { () -> Void in
            self.tutorialLabel.text = "The patterns become quicker and more complicated"
        })
        let triggerTime2 = (Int64(NSEC_PER_SEC * 6))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime2), dispatch_get_main_queue(), { () -> Void in
            self.tutorialLabel.text = "Have fun and good luck!"
            self.playNow = true
            self.scoreButton.setTitle("Play!", forState: UIControlState.Normal)
        })
    }
    
    
    @IBAction func tap(sender: TapCircleView) {
            if(!middleOfComputerRun && readyForTaps){
                sender.desiredOutlineColor = UIColor.blackColor()
                sender.desiredColour = UIColor.clearColor()
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
    
    func firstInstruction(){
        tutorialLabel.text = "While the middle ring is red, watch for the pattern"
        middleCircle.desiredColour = UIColor.redColor()
        middleCircle.desiredOutlineColor = UIColor.redColor()
        let triggerTime = (Int64(NSEC_PER_SEC * 2))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
          self.doPattern()
        })
    }
    
    func doPattern(){
        middleOfComputerRun = true
        var delayCount: Int = 1
        let withSpeedFactor = 1
        let withPattern: [Int] = [0,2,4]
        for circleIndex in withPattern{
            
            
            let triggerTime = (Int64(NSEC_PER_SEC/UInt64(withSpeedFactor)) * Int64((delayCount)))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.changeToBlue(circleIndex, withSpeedFactor: withSpeedFactor)
            })
            
            delayCount++
        }

        let triggerTime = (Int64(NSEC_PER_SEC/UInt64(withSpeedFactor)) * Int64((withPattern.count+1)))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.middleCircle.desiredColour = UIColor.clearColor()
            self.middleCircle.desiredOutlineColor = UIColor.clearColor()
            self.middleOfComputerRun = false
            self.secondInstruction()
        })
        
        
    }
    
    func changeToBlue(circleIndex: Int, withSpeedFactor: Int){
        let changingCircles: [TapCircleView] =
        [tapCircle1, tapCircle2, tapCircle3, tapCircle4, tapCircle6, tapCircle7, tapCircle8, tapCircle9]
        let color = UIColor.yellowColor()
        changingCircles[circleIndex].desiredColour = color
        changingCircles[circleIndex].desiredOutlineColor = color
        let triggerTime = (Int64(NSEC_PER_SEC / UInt64(withSpeedFactor)) * Int64(1))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.changeToClear(circleIndex)
        })
    }
    
    func changeToClear(circleIndex: Int){
        let changingCircles: [TapCircleView] =
        [tapCircle1, tapCircle2, tapCircle3, tapCircle4, tapCircle6, tapCircle7, tapCircle8, tapCircle9]
        changingCircles[circleIndex].desiredColour = UIColor.clearColor()
        changingCircles[circleIndex].desiredOutlineColor = UIColor.blackColor()
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
    
    func secondInstruction(){
        tutorialLabel.text = "Now it's your turn to repeat the pattern"
        readyForTaps = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
