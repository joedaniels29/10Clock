//
//  Clock.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 01/09/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import Foundation
import UIKit

@objc public  protocol TenClockDelegate {
    func timesChanged(clock:TenClock, startDate:NSDate,  endDate:NSDate  ) -> ()

}
func medStepFunction(val: CGFloat, stepSize:CGFloat) -> CGFloat{
    let dStepSize = Double(stepSize)
    let dval  = Double(val)
    let nsf = floor(dval/dStepSize)
    let rest = dval - dStepSize * nsf
    return CGFloat(rest > dStepSize / 2 ? dStepSize * (nsf + 1) : dStepSize * nsf)

}

//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//@IBDesignable
public class TenClock : UIControl{

    public var delegate:TenClockDelegate?
    //overall inset. Controls all sizes.
    @IBInspectable var insetAmount: CGFloat = 40
    var internalShift: CGFloat = 5;
    var pathWidth:CGFloat = 54

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
            if (headAngle > fourPi  +  CGFloat(M_PI_2)){
                headAngle -= fourPi
            }
            if (headAngle <  CGFloat(M_PI_2) ){
                headAngle += fourPi
            }
        }
    }

    var tailAngle: CGFloat = CGFloat(2 * M_PI) + 0.7 * CGFloat(M_PI) {
        didSet{
            if (tailAngle  > headAngle + fourPi){
                tailAngle -= fourPi
            } else if (tailAngle  < headAngle ){
                tailAngle += fourPi
            }

        }
    }


    public var numeralsColor:UIColor? = UIColor.darkGrayColor()
    public var minorTicksColor:UIColor? = UIColor.lightGrayColor()
    public var majorTicksColor:UIColor? = UIColor.blueColor()
    public var centerTextColor:UIColor? = UIColor.darkGrayColor()

    public var titleColor = UIColor.lightGrayColor()
    public var titleGradientMask = false

    //disable scrol on closest superview for duration of a valid touch.
    var disableSuperviewScroll = false

    public var headBackgroundColor = UIColor.whiteColor()
    public var tailBackgroundColor = UIColor.whiteColor()

    public var headTextColor = UIColor.blackColor()
    public var tailTextColor = UIColor.blackColor()

    public var minorTicksEnabled:Bool = true
    public var majorTicksEnabled:Bool = true
    @objc public var disabled:Bool = false {
        didSet{
        		update()
        }
    }
    
    public var buttonInset:CGFloat = 2
    func disabledFormattedColor(color:UIColor) -> UIColor{
        return disabled ? color.greyscale : color
    }




    var trackWidth:CGFloat {return pathWidth }
    func proj(theta:Angle) -> CGPoint{
        let center = self.layer.center
        return CGPointMake(center.x + trackRadius * cos(theta) ,
                           center.y - trackRadius * sin(theta) )
    }

    var headPoint: CGPoint{
        return proj(headAngle)
    }
    var tailPoint: CGPoint{
        return proj(tailAngle)
    }

    lazy internal var calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)!
    func toDate(val:CGFloat)-> NSDate {
        let comps = NSDateComponents()
        comps.minute = Int(val)
        return calendar.dateByAddingComponents(comps, toDate: NSDate().startOfDay, options: .init(rawValue:0))!
    }
    public var startDate: NSDate{
        get{return angleToTime(headAngle) }
        set{ headAngle = timeToAngle(newValue) }
    }
    public var endDate: NSDate{
        get{return angleToTime(tailAngle) }
        set{ tailAngle = timeToAngle(newValue) }
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
        let reInsetAmount = trackWidth.checked / 2 + 4 * internalShift
        return CGRectInset(self.inset, reInsetAmount, reInsetAmount)
    }
    var trackRadius:CGFloat { return inset.height / 2}
    var buttonRadius:CGFloat { return /*44*/ pathWidth / 2 }
    var iButtonRadius:CGFloat { return /*44*/ buttonRadius - buttonInset }
    var strokeColor: UIColor {
        get {
            return UIColor(CGColor: trackLayer.strokeColor!)
        }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.colorWithAlphaComponent(0.1).CGColor
            pathLayer.strokeColor = strokeColor.CGColor
        }
    }


    // input a date, output: 0 to 4pi
    func timeToAngle(date: NSDate) -> Angle{
        let units : NSCalendarUnit = [.Hour, .Minute]
        let components = self.calendar.components(units, fromDate: date)
        let min = Double(  60 * components.hour + components.minute )

        return medStepFunction(CGFloat(M_PI_2 - ( min / (12 * 60)) * 2 * M_PI), stepSize: CGFloat( 2 * M_PI / (12 * 60 / 5)))
    }

    // input an angle, output: 0 to 4pi
    func angleToTime(angle: Angle) -> NSDate{
        let dAngle = Double(angle)
        let min = CGFloat(((M_PI_2 - dAngle) / (2 * M_PI)) * (12 * 60))
        let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate())

        return self.calendar.dateByAddingUnit(.Minute, value: Int(medStepFunction(min, stepSize: 5/* minute steps*/)), toDate: startOfToday, options: .init(rawValue:0))!
    }
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }
    public func update() {
        let mm = min(self.layer.bounds.size.height, self.layer.bounds.size.width)
        CATransaction.begin()
        self.layer.size = CGSize(width: mm, height: mm)

        strokeColor = disabledFormattedColor(tintColor)
        overallPathLayer.occupation = layer.occupation
        gradientLayer.occupation = layer.occupation

        trackLayer.occupation = (inset.size, layer.center)

        pathLayer.occupation = (inset.size, overallPathLayer.center)
        repLayer.occupation = (internalInset.size, overallPathLayer.center)
        repLayer2.occupation  =  (internalInset.size, overallPathLayer.center)
        numeralsLayer.occupation = (numeralInset.size, layer.center)

        trackLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.fillColor = UIColor.clearColor().CGColor


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

        gradientLayer.colors =
            [tintColor,
                tintColor.modified(withAdditionalHue: -0.08, additionalSaturation: 0.15, additionalBrightness: 0.2)]
                .map(disabledFormattedColor)
                .map{$0.CGColor}
        gradientLayer.mask = overallPathLayer
        gradientLayer.startPoint = CGPoint(x:0,y:0)
    }

    func updateTrackLayerPath() {
        let circle = UIBezierPath(
            ovalInRect: CGRect(
                origin:CGPoint(x: 0, y: 00),
                size: CGSize(width:trackLayer.size.width,
                    height: trackLayer.size.width)))
        trackLayer.lineWidth = pathWidth
        trackLayer.path = circle.CGPath

    }
    override public func layoutSubviews() {
        update()
    }
    func updatePathLayerPath() {
        let arcCenter = pathLayer.center
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.lineWidth = pathWidth
        print("start = \(headAngle / CGFloat(M_PI)), end = \(tailAngle / CGFloat(M_PI))")
        pathLayer.path = UIBezierPath(
            arcCenter: arcCenter,
            radius: trackRadius,
            startAngle: ( twoPi ) -  headAngle,
            endAngle: ( twoPi  ) -  ((tailAngle - headAngle) >= twoPi ? tailAngle - twoPi : tailAngle),
            clockwise: true).CGPath
    }


    func tlabel(str:String, color:UIColor? = nil) -> CATextLayer{
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
        let l = CATextLayer()
        l.bounds.size = CGSize(width: 30, height: 15)
        l.fontSize = f.pointSize
        l.foregroundColor =  disabledFormattedColor(color ?? tintColor).CGColor
        l.alignmentMode = kCAAlignmentCenter
        l.contentsScale = UIScreen.mainScreen().scale
        l.font = cgFont
        l.string = str

        return l
    }
    func updateHeadTailLayers() {
        let size = CGSize(width: 2 * buttonRadius, height: 2 * buttonRadius)
        let iSize = CGSize(width: 2 * iButtonRadius, height: 2 * iButtonRadius)
        let circle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y:0), size: size)).CGPath
        let iCircle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y:0), size: iSize)).CGPath
        tailLayer.path = circle
        headLayer.path = circle
        tailLayer.size = size
        headLayer.size = size
        tailLayer.position = tailPoint
        headLayer.position = headPoint
        topTailLayer.position = tailPoint
        topHeadLayer.position = headPoint
        headLayer.fillColor = UIColor.yellowColor().CGColor
        tailLayer.fillColor = UIColor.greenColor().CGColor
        topTailLayer.path = iCircle
        topHeadLayer.path = iCircle
        topTailLayer.size = iSize
        topHeadLayer.size = iSize
        topHeadLayer.fillColor = disabledFormattedColor(headBackgroundColor).CGColor
        topTailLayer.fillColor = disabledFormattedColor(tailBackgroundColor).CGColor
        topHeadLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        topTailLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let stText = tlabel("Sleep", color: disabledFormattedColor(headTextColor))
        let endText = tlabel("Wake",color: disabledFormattedColor(tailTextColor))
        stText.position = topHeadLayer.center
        endText.position = topTailLayer.center
        topHeadLayer.addSublayer(stText)
        topTailLayer.addSublayer(endText)
    }


    func updateWatchFaceNumerals() {
        numeralsLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
        let startPos = CGPoint(x: numeralsLayer.bounds.midX, y: 15)
        let origin = numeralsLayer.center
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
            l.foregroundColor = disabledFormattedColor(numeralsColor ?? tintColor).CGColor
            l.position = CGVector(from:origin, to:startPos).rotate( CGFloat(Double(i) * step)).add(origin.vector).point.checked
            numeralsLayer.addSublayer(l)
        }
    }
    func updateWatchFaceTitle(){
        let f = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        let cgFont = CTFontCreateWithName(f.fontName, f.pointSize/2,nil)
//        let titleTextLayer = CATextLayer()
        titleTextLayer.bounds.size = CGSize( width: titleTextInset.size.width, height: 50)
        titleTextLayer.fontSize = f.pointSize
        titleTextLayer.alignmentMode = kCAAlignmentCenter
        titleTextLayer.foregroundColor = disabledFormattedColor(centerTextColor ?? tintColor).CGColor
        titleTextLayer.contentsScale = UIScreen.mainScreen().scale
        titleTextLayer.font = cgFont
        //var computedTailAngle = tailAngle //+ (headAngle > tailAngle ? twoPi : 0)
        //computedTailAngle +=  (headAngle > computedTailAngle ? twoPi : 0)
        let fiveMinIncrements = 288 - Int( ((tailAngle - headAngle) / twoPi) * 12 /*hrs*/ * 12 /*5min increments*/)
        titleTextLayer.string = "\(fiveMinIncrements / 12)hr \((fiveMinIncrements % 12) * 5)min"
        titleTextLayer.position = gradientLayer.center

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
        t.strokeColor = disabledFormattedColor(minorTicksColor ?? tintColor).CGColor
        t.position = CGPoint(x: repLayer.bounds.midX, y: 10)
        repLayer.addSublayer(t)
        repLayer.position = self.bounds.center
        repLayer.bounds.size = self.internalInset.size

        repLayer2.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t2 = tick()
        t2.strokeColor = disabledFormattedColor(majorTicksColor ?? tintColor).CGColor
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
        strokeColor = disabledFormattedColor(tintColor)
    }
    override public init(frame: CGRect) {
        super.init(frame:frame)
//        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self	, attribute: .Height, multiplier: 1, constant: 0))
       // tintColor = UIColor ( red: 0.755, green: 0.0, blue: 1.0, alpha: 1.0 )
        backgroundColor = UIColor ( red: 0.1149, green: 0.115, blue: 0.1149, alpha: 0.0 )
        createSublayers()
    }


    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        //tintColor = UIColor ( red: 0.755, green: 0.0, blue: 1.0, alpha: 1.0 )
        backgroundColor = UIColor ( red: 0.1149, green: 0.115, blue: 0.1149, alpha: 0.0 )
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
        guard !disabled  else {
        		pointMover = nil
            return
        }
        
        //        touches.forEach { (touch) in
        let touch = touches.first!
        let pointOfTouch = touch.locationInView(self)
        guard let layer = self.overallPathLayer.hitTest( pointOfTouch ) else { return }
//         superview:UIView
//        while let superview = touch.gestureRecognizers{
//            guard let superview = superview as? UIPanGestureRecognizer else {  continue }
//            superview.scrollEnabled = false
//            break
//        }

        var prev = pointOfTouch
        let pp: ((CGPoint) -> Angle, Angle->()) -> (CGPoint) -> () = { g, s in
            return { p in
                let c = self.layer.center
                let computedP = CGPointMake(p.x, self.layer.bounds.height - p.y)
                let v1 = CGVector(from: c, to: computedP)
                let v2 = CGVector(angle:g( p ))

                s(clockDescretization(CGVector.signedTheta(v1, vec2: v2)))
                self.update()
            }

        }

        switch(layer){
        case headLayer:
            pointMover = pp({ _ in self.headAngle}, {self.headAngle += $0; self.tailAngle += 0})
        case tailLayer:
            pointMover = pp({_ in self.tailAngle}, {self.headAngle += 0;self.tailAngle += $0})
        case pathLayer:
            pointMover = pp({ pt in
                let x = CGVector(from: self.bounds.center, to:CGPointMake(prev.x, self.layer.bounds.height - prev.y)).theta;
                prev = pt;
                return x }, {self.headAngle += $0; self.tailAngle += $0 })
        default: break
        }



    }
    override public  func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        while var superview = self.superview{
//            guard let superview = superview as? UIScrollView else {  continue }
//            superview.scrollEnabled = true
//            break
//        }
    }
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        pointMover = nil
//        while var superview = self.superview{
//            guard let superview = superview as? UIScrollView else {  continue }
//            superview.scrollEnabled = true
//            break
//        }
//        do something
//        valueChanged = false
    }
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first, let pointMover = pointMover else { return }
//        print(touch.locationInView(self))
        pointMover(touch.locationInView(self))

        if let delegate = delegate {
            delegate.timesChanged(self, startDate: self.startDate, endDate: endDate)
        }

    }

}
