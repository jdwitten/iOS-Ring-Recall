//
//  OpenScreenViewController.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/27/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import UIKit
import CoreData


/*
This is the ViewController for the Home screen
It controls the animating circles and manages the seques to the gameplay and tutorial screens
*/

class OpenScreenViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel! //The main title
    
    //An array of possible colors for the animating circles
    let colors: [UIColor] = [UIColor.blueColor(), UIColor.greenColor(), UIColor.redColor(), UIColor.purpleColor(), UIColor.yellowColor(), UIColor.orangeColor()]
    
    @IBOutlet weak var MainView: MainScreenCircle!
    
    var sendCirclesTimer: NSTimer = NSTimer() //The timer used to release the animating circles
    
    
   //When the view loads, this func activates the timer to animate the circles
    override func viewDidLoad(){
        self.sendCirclesTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "putCircleOnScreen", userInfo: nil, repeats: true)
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    //Creates and returns a circle view that will animate across the screen
    func createDynamicCircle() -> TapCircleView{
        let size = CGFloat(min(MainView.superview!.bounds.size.width, MainView.superview!.bounds.size.height)/2)
        let origin = getRandomOrigin()
        let frame = CGRect(origin: origin, size: CGSize(width: size, height: size))
        
        
        let movingCircle =
        TapCircleView(frame:frame)
        
        return movingCircle
    }
    
    
    //Will return a CGPoint at a random location across the top of the screen
    //This is where the circle will start animation from
    private func getRandomOrigin() -> CGPoint{
        let randX = arc4random_uniform(UInt32(MainView.superview!.bounds.width))
        
        return CGPoint(x: CGFloat(randX), y: CGFloat(-100))
        
    }
    
    
    //Walks the view through the process of animating a circle across the screen
    func putCircleOnScreen() {
        
        let newCircle = createDynamicCircle()
        
        newCircle.desiredColour = UIColor.clearColor()
        newCircle.desiredOutlineColor = self.getRandomColor()
        
        MainView.addSubview(newCircle)
        
        
        moveCircleToBottom(newCircle)
    }
    
    
    //A helper func to put more than one circle on the screen at once
    func putCircleOnScreen(num: Int){
        
        for _ in (1...num){
            putCircleOnScreen()
        }
        
    }
    
    
    
    //Manages the animation of moving a circle to the bottom of the screen
    //Takes a TapCircleView as an argument
    func moveCircleToBottom(movingCircle: TapCircleView){
        
        //Finds the bounds.height of the screen and then animates the circle to this point
        UIView.animateWithDuration(2, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.AllowAnimatedContent] , animations:{  movingCircle.center.y += self.MainView!.superview!.bounds.height + 25}, completion: {finished in
            movingCircle.removeFromSuperview()})
        
    }
    
    
    //Returns a random color that is used for the animating circle outline
    func getRandomColor() -> UIColor{
        let randIndex: Int = Int(arc4random_uniform(UInt32(6)))
        
        return self.colors[randIndex]
        
    }

}
