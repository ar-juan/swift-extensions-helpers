//
//  UISliderWithSteps.swift
//
//
//  Created by Arjan van der Laan on 06/05/16.
//

import UIKit

class UISliderWithSteps: UISlider {
    var numberOfSteps: Int? {
        didSet {
            if numberOfSteps != nil {
                if numberOfSteps != oldValue {
                    setNeedsDisplay()
                }
            }
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        if numberOfSteps != nil {
            let trackRect = trackRectForBounds(rect)
            let start = trackRect.origin
            let width = trackRect.width
            let stepSize = width / CGFloat(numberOfSteps!)
            var currentX = start.x
            for stepNumber in 0...numberOfSteps! {
                currentX = start.x + (CGFloat(stepNumber) * stepSize)
                
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: currentX, y: rect.origin.y + 0.35 * rect.height))
                path.addLineToPoint(CGPoint(x: currentX, y: rect.origin.y + 0.65 * rect.height))
                path.closePath()
                UIColor.grayColor().set()
                path.lineWidth = 1
                path.stroke()
                
            }
        }
    }
    
    override func thumbRectForBounds(bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let width = bounds.width
        let standardThumbRect = super.thumbRectForBounds(bounds, trackRect: rect, value: value)
        let standardThumbSize = standardThumbRect.size
        let currentThumbCenterX = CGFloat((value - minimumValue) / (maximumValue - minimumValue)) * width
        return CGRect(origin: CGPoint(x: currentThumbCenterX - 0.5 * standardThumbSize.width, y: rect.origin.y + 0.5 * rect.height - 0.5 * standardThumbSize.height), size: standardThumbSize)
        
    }
    
}
