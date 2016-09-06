//
//  Clock.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 01/09/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import Foundation
import UIKit

public protocol ClockDelegate {
    func timesChanged(clock:Clock, startDate:NSDate,  endDate:NSDate  ) -> ()
    
}
func medStepFunction(val: CGFloat, stepSize:CGFloat) -> CGFloat{
    let dStepSize = Double(stepSize)
    let dval  = Double(val)
    let nsf = floor(dval/dStepSize)
    let rest = dval - dStepSize * nsf
    return CGFloat(rest > dStepSize / 2 ? dStepSize * (nsf + 1) : dStepSize * nsf)

}
func angleToTime(input: CGFloat) -> CGFloat{
    return CGFloat((Double(input) - M_PI_2)/(2 * M_PI) * 12*60)
}
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
public class Clock : UIControl{
    
    public var delegate:ClockDelegate?
    //overall inset. Controls all sizes.
    var insetAmount: CGFloat = 60
    var timeStepSize: CGFloat = 5
    let gradientLayer = CAGradientLayer()
    let trackLayer = CAShapeLayer()
    let pathLayer = CAShapeLayer()
    let headLayer = CAShapeLayer()
    let tailLayer = CAShapeLayer()
    let topHeadLayer = CAShapeLayer()
    let topTailLayer = CAShapeLayer()
    let numeralsLayer = CALayer()
    let titleTextLayer = CATextLayer()
    let overallPathLayer = CALayer()
    let repLayer:CAReplicatorLayer = {
        var r = CAReplicatorLayer()
        r.instanceCount = 48
        r.instanceTransform =
            CATransform3DMakeRotation(
                CGFloat(2*M_PI) / CGFloat(r.instanceCount),
                0,0,1)
        
        return r
    }()
    
    let repLayer2:CAReplicatorLayer = {
        var r = CAReplicatorLayer()
        r.instanceCount = 12
        r.instanceTransform =
            CATransform3DMakeRotation(
                CGFloat(2*M_PI) / CGFloat(r.instanceCount),
                0,0,1)
        
        return r
    }()
    let twoPi =  CGFloat(2 * M_PI)
    let fourPi =  CGFloat(4 * M_PI)
    var headAngle: CGFloat = 0{
        didSet{
            if (headAngle - tailAngle > fourPi){
                headAngle -= fourPi
            } else if (headAngle - tailAngle <  0 ){
                headAngle += fourPi
            }
        }
    }

    var tailAngle: CGFloat = 0.7 * CGFloat(M_PI) {
        didSet{
            if (tailAngle > fourPi){
            		tailAngle -= fourPi
            }
            if (tailAngle <  0 ){
             tailAngle += fourPi
            }
        }
    }
    var internalShift: CGFloat = 5;
    var pathWidth:CGFloat = 34
    
    
    var trackWidth:CGFloat {return pathWidth }
    func proj(theta:Angle) -> CGPoint{
        let center = CGPointMake( self.layer.frame.midX, self.layer.frame.midY)
        return CGPointMake(center.x + trackRadius * cos(theta) ,
                           center.y - trackRadius * sin(theta) )
    }

    var headPoint: CGPoint{
        return proj(headAngle)
    }
    var tailPoint: CGPoint{
        return proj(tailAngle)
    }
    var headVal: CGFloat{
        return medStepFunction(angleToTime(headAngle), stepSize: timeStepSize)
    }
    var tailVal: CGFloat{
        return medStepFunction(angleToTime(tailAngle), stepSize: timeStepSize)
    }
    lazy internal var calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
    func toDate(val:CGFloat)-> NSDate {
        let comps = NSDateComponents()
        comps.minute = Int(val)
        return calendar!.dateByAddingComponents(comps, toDate: NSDate().startOfDay, options: [])!
    }
    var startDate: NSDate{
        get{return toDate(headVal) }
        set{
            let comps = calendar!.components([.Hour, .Minute], fromDate: startDate)
            let minSinceMid = comps.hour * 60 + comps.minute
            _ = minSinceMid
            }
    }
    var endDate: NSDate{
        get{return toDate(tailVal) }
        set{
            let comps = calendar!.components([.Hour, .Minute], fromDate: startDate)
            let minSinceMid = comps.hour * 60 + comps.minute
            _ = minSinceMid
        }
    }

    var internalRadius:CGFloat {
        return internalInset.height
    }
    var inset:CGRect{
        return CGRectInset(self.layer.bounds, insetAmount, insetAmount)
    }
    var internalInset:CGRect{
        let reInsetAmount = trackWidth / 2 + internalShift
        return CGRectInset(self.inset, reInsetAmount, reInsetAmount)
    }
    var numeralInset:CGRect{
        let reInsetAmount = trackWidth / 2 + internalShift + internalShift
        return CGRectInset(self.inset, reInsetAmount, reInsetAmount)
    }
    var titleTextInset:CGRect{
        let reInsetAmount = trackWidth / 2 + 4 * internalShift
        return CGRectInset(self.inset, reInsetAmount, reInsetAmount)
    }
    var trackRadius:CGFloat { return inset.height / 2}
    var buttonRadius:CGFloat { return /*44*/ pathWidth / 2 }
    var iButtonRadius:CGFloat { return /*44*/ buttonRadius - 1 }
    var strokeColor: UIColor {
        get {
            return UIColor(CGColor: trackLayer.strokeColor!)
        }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.colorWithAlphaComponent(0.1).CGColor
            pathLayer.strokeColor = strokeColor.CGColor
        }
    }

    
    func update() {
        let mm = min(self.layer.bounds.size.height, self.layer.bounds.size.width)
        self.layer.bounds.size = CGSize(width: mm, height: mm)
        self.layer.position = self.bounds.center
        strokeColor = tintColor
        overallPathLayer.frame = self.layer.bounds
        overallPathLayer.position = self.layer.position
        gradientLayer.frame = self.layer.bounds
        gradientLayer.position = self.layer.position
        trackLayer.frame.size = inset.size
        trackLayer.position = self.layer.position
        
        pathLayer.frame = inset
        pathLayer.position = self.layer.position
        repLayer.frame = internalInset
        repLayer2.frame = internalInset
        numeralsLayer.frame = numeralInset
        
        pathLayer.lineWidth = pathWidth
        trackLayer.lineWidth = trackWidth
        
        trackLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.fillColor = UIColor.clearColor().CGColor
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        updateGradientLayer()
        updateTrackLayerPath()
        updatePathLayerPath()
        updateHeadTailLayers()
        updateWatchFaceTicks()
        updateWatchFaceNumerals()
        updateWatchFaceTitle()
        CATransaction.commit()
    }
    func updateGradientLayer() {
        gradientLayer.colors = [UIColor ( red: 0.7011, green: 0.0, blue: 1.0, alpha: 1.0 ).CGColor, UIColor ( red: 0.9992, green: 0.0, blue: 0.5578, alpha: 1.0 ).CGColor]
        gradientLayer.mask = overallPathLayer
        gradientLayer.startPoint = CGPoint(x:0,y:0)
    }
    
    func updateTrackLayerPath() {
        let circle = UIBezierPath(
            ovalInRect: CGRect(
                origin:CGPoint(x: 0, y: 00),
                size: CGSize(width:trackLayer.frame.width,
                    height: trackLayer.frame.width)))
        trackLayer.lineWidth = pathWidth
        trackLayer.path = circle.CGPath
        
    }
    override public func layoutSubviews() {
        update()
    }
    func updatePathLayerPath() {
        let arcCenter = CGPoint(x: pathLayer.bounds.width / 2.0, y: pathLayer.bounds.height / 2.0)
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.lineWidth = pathWidth
//        print("start = \(headAngle), end = \(tailAngle)")
        pathLayer.path = UIBezierPath(
            arcCenter: arcCenter,
            radius: trackRadius,
            startAngle: ( 2 * CGFloat(M_PI)) -  headAngle,
            endAngle: ( 2 * CGFloat(M_PI)) -  (abs(headAngle - tailAngle) >= twoPi ? tailAngle - twoPi : tailAngle),
            clockwise: true).CGPath
    }
    
    
    func tlabel(str:String) -> CATextLayer{
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
        let l = CATextLayer()
        l.bounds.size = CGSize(width: 30, height: 15)
        l.fontSize = f.pointSize
        l.foregroundColor = tintColor.CGColor
        l.alignmentMode = kCAAlignmentCenter
        l.contentsScale = UIScreen.mainScreen().scale
        l.font = cgFont
        l.string = str
        
        return l
    }
    func updateHeadTailLayers() {
//        let lls = [headLayer, tailLayer, topHeadLayer, topTailLayer]
        let size = CGSize(width: 2 * buttonRadius, height: 2 * buttonRadius)
        let iSize = CGSize(width: 2 * iButtonRadius, height: 2 * iButtonRadius)
        let circle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y:0), size: size)).CGPath
        let iCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y:0), size: iSize)).CGPath
        tailLayer.path = circle
        headLayer.path = circle
        tailLayer.bounds.size = size
        headLayer.bounds.size = size
        tailLayer.position = tailPoint
        headLayer.position = headPoint
        topTailLayer.position = tailPoint
        topHeadLayer.position = headPoint
        headLayer.fillColor = UIColor.yellowColor().CGColor
        tailLayer.fillColor = UIColor.greenColor().CGColor
        topTailLayer.path = iCircle
        topHeadLayer.path = iCircle
        topTailLayer.bounds.size = iSize
        topHeadLayer.bounds.size = iSize
        topHeadLayer.fillColor = UIColor ( red: 0.1172, green: 0.1172, blue: 0.1172, alpha: 1.0 ).CGColor
        topTailLayer.fillColor = UIColor ( red: 0.0645, green: 0.0645, blue: 0.0645, alpha: 1.0 ).CGColor
        topHeadLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        topTailLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let stText = tlabel("Sleep")
        let endText = tlabel("Wake")
        stText.position = topHeadLayer.bounds.center
        endText.position = topTailLayer.bounds.center
        topHeadLayer.addSublayer(stText)
        topTailLayer.addSublayer(endText)
    }
    
    
    func updateWatchFaceNumerals() {
        numeralsLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
        let startPos = CGPoint(x: numeralsLayer.bounds.midX, y: 15)
        let origin = numeralsLayer.bounds.center
        let step = (2 * M_PI) / 12
        for i in (1 ... 12){
            let l = CATextLayer()
            l.bounds.size = CGSize(width: i > 9 ? 18 : 8, height: 15)
            l.fontSize = f.pointSize
            l.alignmentMode = kCAAlignmentCenter
            l.contentsScale = UIScreen.mainScreen().scale
            //            l.foregroundColor
            l.font = cgFont
            l.string = "\(i)"
            l.foregroundColor = UIColor.lightGrayColor().CGColor
            l.position = CGVector(from:origin, to:startPos).rotate( CGFloat(Double(i) * step)).add(origin.vector).point
            numeralsLayer.addSublayer(l)
        }
    }
    func updateWatchFaceTitle(){
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
//        let titleTextLayer = CATextLayer()
        titleTextLayer.bounds.size = CGSize( width: titleTextInset.size.width, height: 50)
        titleTextLayer.fontSize = f.pointSize
        titleTextLayer.alignmentMode = kCAAlignmentCenter
        titleTextLayer.foregroundColor = UIColor.whiteColor().CGColor
        titleTextLayer.contentsScale = UIScreen.mainScreen().scale
        titleTextLayer.font = cgFont
        var computedTailAngle = tailAngle + (headAngle > tailAngle ? twoPi : 0)
        computedTailAngle +=  (headAngle > computedTailAngle ? twoPi : 0)
        let fiveMinIncrements = Int( (abs(tailAngle - headAngle) / twoPi) * 12 /*hrs*/ * 12 /*5min increments*/)
        titleTextLayer.string = "\(fiveMinIncrements / 12)hr \((fiveMinIncrements % 12) * 5)min"
        titleTextLayer.position = gradientLayer.bounds.center
        
    }
    func tick() -> CAShapeLayer{
        let tick = CAShapeLayer()
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0,-3))
        path.addLineToPoint(CGPointMake(0,3))
        tick.path  = path.CGPath
        tick.bounds.size = CGSize(width: 6, height: 6)
        return tick
    }
    
    func updateWatchFaceTicks() {
        repLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t = tick()
        t.strokeColor = UIColor.whiteColor().CGColor
        t.position = CGPoint(x: repLayer.bounds.midX, y: 10)
        repLayer.addSublayer(t)
        repLayer.position = self.bounds.center
        repLayer.bounds.size = self.internalInset.size
    
        repLayer2.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t2 = tick()
        t2.strokeColor = tintColor.CGColor
        t2.lineWidth = 2
        t2.position = CGPoint(x: repLayer2.bounds.midX, y: 10)
        repLayer2.addSublayer(t2)
        repLayer2.position = self.bounds.center
        repLayer2.bounds.size = self.internalInset.size
    }
    var pointerLength:CGFloat = 0.0
    
    func createSublayers() {
        layer.addSublayer(repLayer2)
        layer.addSublayer(repLayer)
        layer.addSublayer(numeralsLayer)
        layer.addSublayer(trackLayer)
         
        overallPathLayer.addSublayer(pathLayer)
        overallPathLayer.addSublayer(headLayer)
        overallPathLayer.addSublayer(tailLayer)
        overallPathLayer.addSublayer(titleTextLayer)
        layer.addSublayer(overallPathLayer)
        layer.addSublayer(gradientLayer)
        gradientLayer.addSublayer(topHeadLayer)
        gradientLayer.addSublayer(topTailLayer)
        update()
        strokeColor = tintColor
    }
    override public init(frame: CGRect) {
        super.init(frame:frame)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self	, attribute: .Height, multiplier: 1, constant: 0))
        tintColor = UIColor ( red: 0.755, green: 0.0, blue: 1.0, alpha: 1.0 )
        backgroundColor = UIColor ( red: 0.1149, green: 0.115, blue: 0.1149, alpha: 1.0 )
        createSublayers()
    }
    
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self	, attribute: .Height, multiplier: 1, constant: 0))
        tintColor = UIColor ( red: 0.755, green: 0.0, blue: 1.0, alpha: 1.0 )
        backgroundColor = UIColor ( red: 0.1149, green: 0.115, blue: 0.1149, alpha: 1.0 )
        createSublayers()
    }
    
    
    private var backingValue: Float = 0.0
    
    /** Contains the receiver’s current value. */
    var value: Float {
        get { return backingValue }
        set { setValue(newValue, animated: false) }
    }
    
    /** Sets the receiver’s current value, allowing you to animate the change visually. */
    func setValue(value: Float, animated: Bool) {
        if value != backingValue {
            backingValue = min(maximumValue, max(minimumValue, value))
        }
    }
    
    /** Contains the minimum value of the receiver. */
    var minimumValue: Float = 0.0
    
    /** Contains the maximum value of the receiver. */
    var maximumValue: Float = 1.0
    
    /** Contains a Boolean value indicating whether changes
     in the sliders value generate continuous update events. */
    var continuous = true
    var valueChanged = false
    
    
    var pointMover:((CGPoint) ->())?
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        touches.forEach { (touch) in
        let touch = touches.first!
        guard let layer = self.overallPathLayer.hitTest( touch.locationInView(self) ) else { return }
        
        let pp: (() -> Angle, Angle->()) -> (CGPoint) -> () = { g, s in
            return { p in
                let c = self.layer.frame.center
                let computedP = CGPointMake(p.x, self.layer.frame.height - p.y)
                let v1 = CGVector(from: c, to: computedP)
                let v2 = CGVector(angle:g())
                
                s(clockDescretization(CGVector.signedTheta(v1, vec2: v2)))
                self.update()
            }
            
        }
        
        switch(layer){
        case headLayer:
            pointMover = pp({self.headAngle}, {self.headAngle += $0})
        case tailLayer:
            pointMover = pp({self.tailAngle}, {self.tailAngle += $0})
        case pathLayer:
            pointMover = pp({(self.tailAngle + self.headAngle) / 2}, {self.tailAngle += $0; self.headAngle += $0})
        default: break
        }
        
        
        
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pointMover = nil
//        do something
//        valueChanged = false
    }
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first, pointMover = pointMover else { return }
//        print(touch.locationInView(self))
        pointMover(touch.locationInView(self))
        
        if let delegate = delegate {
            delegate.timesChanged(self, startDate: self.startDate, endDate: endDate)
        }
        
    }
    
}


