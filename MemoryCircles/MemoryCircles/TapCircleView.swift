//
//  TapCircleView.swift
//  MemoryCircles
//
//  Created by Jonathan Witten on 12/22/15.
//  Copyright © 2015 Jonathan Witten. All rights reserved.
//

import UIKit
import CoreData
@IBDesignable


class TapCircleView : UIButton {
    
    var desiredColour: UIColor = UIColor.clearColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    var desiredOutlineColor: UIColor = UIColor.blackColor() {
        didSet{
            self.setNeedsDisplay()
        }
    }
   /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
    }
  */
    
    
    
    override func drawRect(rect: CGRect) {
        
        /*
        
        let ovalPath = UIBezierPath(ovalInRect: rect)
        
        UIColor.blueColor().set()
        
        desiredColour.setFill()
        ovalPath.fill()
        
        
        ovalPath.stroke()
        */
        
        
        // Get the Graphics Context
        let context = UIGraphicsGetCurrentContext();
        
        // Set the circle outerline-width
        CGContextSetLineWidth(context, 3.0);
        
        // Set the circle outerline-colour
        desiredOutlineColor.set()
        
        // Create Circle
        let circleSize: CGFloat = CGFloat(min(frame.size.width, frame.size.height)/4)
        
        CGContextAddArc(context, frame.size.width/2, frame.size.height/2, circleSize, 0.0, CGFloat(M_PI * 2.0), 1)
       
        
        // Draw
        CGContextSetFillColorWithColor(context, desiredColour.CGColor)
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
        
    }
    
    func color(fillColor: UIColor){
        UIColor.blueColor().setFill()
        self.setNeedsDisplay()
    }
    
}