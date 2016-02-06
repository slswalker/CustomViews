//
//  Checkmark.swift
//  Checkmark animation
//
//  Created by Sam Walker on 2/6/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

func interpolate(value1: CGFloat, value2: CGFloat, ratio: CGFloat) -> CGFloat {
    return abs((ratio * value2) + ((1 - ratio) * value1))
}

func transitionColorFromFirstColor(color1: UIColor, toSecondColor color2: UIColor, forRatio ratio: CGFloat) -> UIColor {
    
    var red1 : CGFloat = 0
    var green1 : CGFloat = 0
    var blue1 : CGFloat = 0
    var alpha1: CGFloat = 0
    
    var red2 : CGFloat = 0
    var green2 : CGFloat = 0
    var blue2 : CGFloat = 0
    var alpha2: CGFloat = 0
    
    color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
    color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
    
    let red = interpolate(red1, value2: red2, ratio: ratio)
    let green = interpolate(green1, value2: green2, ratio: ratio)
    let blue = interpolate(blue1, value2: blue2, ratio: ratio)
    let alpha = interpolate(alpha1, value2: alpha2, ratio: ratio)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

func length(point1: CGPoint, point2: CGPoint) -> CGFloat {
    func square(x: CGFloat) -> CGFloat { return x * x }
    return sqrt( square(point1.x + point2.x) + square(point1.y + point2.y))
}

class Checkmark: UIView {
    
    // Progress = 0 -> 1
    var progress: CGFloat = 1
    var colors: [UIColor] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        opaque = false
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        var fillColor = UIColor.greenColor()
        
        if colors.count >= 2 {
            let x = progress * CGFloat(colors.count - 1)
            let a = floor(x)
            let b = ceil(x)
            let r = b - a
            
            if a == b {
                let i = Int(a)
                fillColor = colors[i]
            } else {
                fillColor = transitionColorFromFirstColor(colors[Int(a)], toSecondColor: colors[Int(b)], forRatio: r)
            }
        } else if colors.count == 1 {
            fillColor = colors.first!
        }
        
        let width = rect.width
        let height = rect.height
        let lineWidth = 0.3 * width
        let radius = lineWidth / 2
        
        let x1 = radius
        let y1 = height / 2 + radius
        let x2 = (width / 2) - radius / 2
        let y2 = height - radius
        let x3 = width - radius
        let y3 = radius
        
        
        let startPoint = CGPoint(x: x1 , y: y1)
        var middlePoint = CGPoint(x: x2, y: y2)
        var endPoint = CGPoint(x: x3, y: y3)
        
        let lineOneLength = length(startPoint, point2: middlePoint)
        let lineTwoLength = length(middlePoint, point2: endPoint)
        
        let total = lineOneLength + lineTwoLength
        let part = total * progress
        
        var drawSecondLine = true
        
        if part <= lineOneLength {
            drawSecondLine = false
            let r = part / lineOneLength
            let xn = (1 - r)*x1 + r*x2
            let yn = (1 - r)*y1 + r*y2
            
            middlePoint = CGPoint(x: xn, y: yn)
        } else if part < total {
            let r = (part - lineOneLength) / lineTwoLength
            let xn = (1 - r)*x2 + r*x3
            let yn = (1 - r)*y2 + r*y3
            endPoint = CGPoint(x: xn, y: yn)
        }
        
        if let contextRef = UIGraphicsGetCurrentContext() {
            
            CGContextSetLineCap(contextRef, .Round)
            CGContextSetLineJoin(contextRef, .Round)
            CGContextSetLineWidth(contextRef, lineWidth)
            CGContextSetStrokeColorWithColor(contextRef, fillColor.CGColor)
            
            CGContextMoveToPoint(contextRef, startPoint.x, startPoint.y)
            CGContextAddLineToPoint(contextRef, middlePoint.x, middlePoint.y)
            
            if drawSecondLine {
                CGContextAddLineToPoint(contextRef, endPoint.x, endPoint.y)
            }
            
            CGContextStrokePath(contextRef)
        }
    }
}