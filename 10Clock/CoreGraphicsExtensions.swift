//
//  CoreGraphicsExtensions.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 01/09/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import Foundation
import UIKit
typealias Angle = CGFloat
func df() -> CGFloat {
    return    CGFloat(drand48())
}
func clockDescretization(val: CGFloat) -> CGFloat{
    let min:Double  = 0
    let max:Double = 2 * Double(M_PI)
    let steps:Double = 144
    let stepSize = (max - min) / steps
    let nsf = floor(Double(val) / stepSize)
    let rest = Double(val) - stepSize * nsf
    return CGFloat(rest > stepSize / 2 ? stepSize * (nsf + 1) : stepSize * nsf)
    
}
extension CALayer {
    func doDebug(){
        self.borderColor = UIColor(hue: df() , saturation: df(), brightness: 1, alpha: 1).CGColor
        self.borderWidth = 2;
        self.sublayers?.forEach({$0.doDebug()})
    }
}
extension CGRect{
    var center:CGPoint { return CGPoint(x:midX, y: midY)}
}
extension CGPoint{
    var vector:CGVector { return CGVector(dx: x, dy: y)}
}
extension CGVector{
    static var root:CGVector{ return CGVector(dx:1, dy:0)}
    var magnitude:CGFloat { return sqrt(pow(dx, 2) + pow(dy,2))}
    var normalized: CGVector { return CGVector(dx:dx / magnitude,  dy: dy / magnitude) }
    var point:CGPoint { return CGPoint(x: dx, y: dy)}
    func rotate(angle:Angle) -> CGVector { return CGVector(dx: dx * cos(angle) - dy * sin(angle), dy: dx * sin(angle) + dy * cos(angle) )}
    
    func dot(vec2:CGVector) -> CGFloat { return dx * vec2.dx + dy * vec2.dy}
    func add(vec2:CGVector) -> CGVector { return CGVector(dx:dx + vec2.dx , dy: dy + vec2.dy)}
    func cross(vec2:CGVector) -> CGFloat { return dx * vec2.dy - dy * vec2.dx}
    
    init( from:CGPoint, to:CGPoint){
        dx = to.x - from.x
        dy = to.y - from.y
    }
    
    init(angle:Angle){
        let compAngle = angle < 0 ? (angle + CGFloat(2 * M_PI)) : angle
        dx = cos(compAngle)
        dy = sin(compAngle)
        
        //        print("x = \(dx)  y = \(dy)")
    }
    static func theta(vec1:CGVector, vec2:CGVector) -> Angle{
        return acos(vec1.normalized.dot(vec2.normalized))
    }
    static func signedTheta(vec1:CGVector, vec2:CGVector) -> Angle{
        
        return (vec1.normalized.cross(vec2.normalized) > 0 ?  -1 : 1) * theta(vec1.normalized, vec2: vec2.normalized)
    }
    
}