//
//  FailScreenViewController.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/28/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import UIKit
import CoreData
import iAd

class FailScreenViewController: UIViewController, ADInterstitialAdDelegate {
    
    var interAdView = UIView()
    
    var closeButton = UIButton()

    @IBOutlet weak var scoreLabel: UILabel!
    var score: Int = 0
    
    var highScore: Int = 0
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    
    @IBOutlet weak var MainView: UIView!
    
    let colors: [UIColor] = [UIColor.blueColor(), UIColor.greenColor(), UIColor.redColor(), UIColor.purpleColor(), UIColor.yellowColor(), UIColor.orangeColor()]
    
    var sendCirclesTimer: NSTimer = NSTimer()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // Create reference to our app delegate

    
    
    func close(sender: UIButton) {
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
        interstitialAdDidUnload(appDelegate.interAd)
    }
    
    @IBAction func showAd(sender: UIButton) {
        loadAd()
    }
    
    func loadAd() {
        
        if(appDelegate.interAd.loaded){
            //print("ad displayed")
            interAdView = UIView()
            interAdView.frame = self.view.bounds
            view.addSubview(interAdView)
            
            appDelegate.interAd.presentInView(interAdView)
            UIViewController.prepareInterstitialAds()
            
            interAdView.addSubview(closeButton)
        
        }
        else{
            //print("ad not displayed")
            appDelegate.loadAd()
        }
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {

    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interAdView.removeFromSuperview()
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        //print("failed to receive")
        //print(error.localizedDescription)
        
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
        
    }
    
    
    override func viewDidLoad(){
        
        
        closeButton.frame = CGRectMake(15, 15, 25, 25)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("x", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchDown)
        
        
        let randInt = Int(arc4random_uniform(UInt32(50)))
        print(randInt)
        
        if(randInt<25){
        loadAd()
        }
        
        
        self.sendCirclesTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "putCircleOnScreen", userInfo: nil, repeats: true)
        
        
        scoreLabel.text = "Score: " + String(score)
        
        highScoreLabel.text = "High Score: " + String(highScore)
    }
    
    func createDynamicCircle() -> TapCircleView{
        let size = CGFloat(min(MainView.superview!.bounds.size.width, MainView.superview!.bounds.size.height)/2)
        let origin = getRandomOrigin()
        let frame = CGRect(origin: origin, size: CGSize(width: size, height: size))
        
        
        let movingCircle =
        TapCircleView(frame:frame)
        
        return movingCircle
    }
    
    private func getRandomOrigin() -> CGPoint{
        let randX = arc4random_uniform(UInt32(MainView.superview!.bounds.width))
        
        return CGPoint(x: CGFloat(randX), y: CGFloat(-100))
        
    }
    
    func putCircleOnScreen() {
        
        let newCircle = createDynamicCircle()
        
        newCircle.desiredColour = UIColor.clearColor()
        newCircle.desiredOutlineColor = self.getRandomColor()
        
        MainView.addSubview(newCircle)
        
        
        moveCircleToBottom(newCircle)
    }
    
    func putCircleOnScreen(num: Int){
        
        for _ in (1...num){
            putCircleOnScreen()
        }
        
    }
    func moveCircleToBottom(movingCircle: TapCircleView){
        
        UIView.animateWithDuration(2, delay: 0, options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.AllowAnimatedContent] , animations:{  movingCircle.center.y += self.MainView!.superview!.bounds.height + 25}, completion: {finished in
            movingCircle.removeFromSuperview()})
        
    }
    
    func getRandomColor() -> UIColor{
        let randIndex: Int = Int(arc4random_uniform(UInt32(6)))
        
        return self.colors[randIndex]
        
    }
    
}
