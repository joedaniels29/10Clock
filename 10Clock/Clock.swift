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
    func timesChanged(clock:TenClock, startDate:Date,  endDate:Date  ) -> ()

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

    var tailAngle: CGFloat = 0.7 * CGFloat(M_PI) {
        didSet{
            if (tailAngle  > headAngle + fourPi){
                tailAngle -= fourPi
            } else if (tailAngle  < headAngle ){
                tailAngle += fourPi
            }

        }
    }


    public var numeralsColor:UIColor? = UIColor.darkGray
    public var minorTicksColor:UIColor? = UIColor.lightGray
    public var majorTicksColor:UIColor? = UIColor.blue
    public var centerTextColor:UIColor? = UIColor.darkGray

    public var titleColor = UIColor.lightGray
    public var titleGradientMask = false

    //disable scrol on closest superview for duration of a valid touch.
    var disableSuperviewScroll = false

    public var headBackgroundColor = UIColor.white
    public var tailBackgroundColor = UIColor.white

    public var headTextColor = UIColor.black
    public var tailTextColor = UIColor.black

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
        return CGPoint(x: center.x + trackRadius * cos(theta),
                       y: center.y - trackRadius * sin(theta) )
    }

    var headPoint: CGPoint{
        return proj(theta: headAngle)
    }
    var tailPoint: CGPoint{
        return proj(theta: tailAngle)
    }

    lazy internal var calendar = Calendar.current
    
    func toDate(val:CGFloat)-> Date {
        var comps = DateComponents()
        comps.minute = Int(val)
        return calendar.date(byAdding: comps, to: Date().startOfDay)!
//        return calendar.date(byAdding: comps as DateComponents, to: Date().startOfDay, options: .init(rawValue:0))!
    }
    public var startDate: Date{
        get{return angleToTime(angle: headAngle) }
        set{ headAngle = timeToAngle(date: newValue) }
    }
    public var endDate: Date{
        get{return angleToTime(angle: tailAngle) }
        set{ tailAngle = timeToAngle(date: newValue) }
    }

    var internalRadius:CGFloat {
        return internalInset.height
    }
    var inset:CGRect{
        return self.layer.bounds.insetBy(dx: insetAmount, dy: insetAmount)
    }
    var internalInset:CGRect{
        let reInsetAmount = trackWidth / 2 + internalShift
        return self.inset.insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var numeralInset:CGRect{
        let reInsetAmount = trackWidth / 2 + internalShift + internalShift
        return self.inset.insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var titleTextInset:CGRect{
        let reInsetAmount = trackWidth.checked / 2 + 4 * internalShift
        return self.inset.insetBy(dx: reInsetAmount, dy: reInsetAmount)
    }
    var trackRadius:CGFloat { return inset.height / 2}
    var buttonRadius:CGFloat { return /*44*/ pathWidth / 2 }
    var iButtonRadius:CGFloat { return /*44*/ buttonRadius - buttonInset }
    var strokeColor: UIColor {
        get {
            return UIColor(cgColor: trackLayer.strokeColor!)
        }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.withAlphaComponent(0.1).cgColor
            pathLayer.strokeColor = strokeColor.cgColor
        }
    }


    // input a date, output: 0 to 4pi
    func timeToAngle(date: Date) -> Angle{
        let units : Set<Calendar.Component> = [.hour, .minute]
        let components = self.calendar.dateComponents(units, from: date)
        let min = Double(  60 * components.hour! + components.minute! )

        return medStepFunction(val: CGFloat(M_PI_2 - ( min / (12 * 60)) * 2 * M_PI), stepSize: CGFloat( 2 * M_PI / (12 * 60 / 5)))
    }

    // input an angle, output: 0 to 4pi
    func angleToTime(angle: Angle) -> Date{
        let dAngle = Double(angle)
        let min = CGFloat(((M_PI_2 - dAngle) / (2 * M_PI)) * (12 * 60))
        let startOfToday = Date().startOfDay

        return self.calendar.date(byAdding: Calendar.Component.minute, value: Int(medStepFunction(val: min, stepSize: 5/* minute steps*/)), to: startOfToday)!
    }
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        update()
    }
    public func update() {
        let mm = min(self.layer.bounds.size.height, self.layer.bounds.size.width)
        CATransaction.begin()
        self.layer.size = CGSize(width: mm, height: mm)

        strokeColor = disabledFormattedColor(color: tintColor)
        overallPathLayer.occupation = layer.occupation
        gradientLayer.occupation = layer.occupation

        trackLayer.occupation = (inset.size, layer.center)

        pathLayer.occupation = (inset.size, overallPathLayer.center)
        repLayer.occupation = (internalInset.size, overallPathLayer.center)
        repLayer2.occupation  =  (internalInset.size, overallPathLayer.center)
        numeralsLayer.occupation = (numeralInset.size, layer.center)

        trackLayer.fillColor = UIColor.clear.cgColor
        pathLayer.fillColor = UIColor.clear.cgColor


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
                .map{$0.cgColor}
        gradientLayer.mask = overallPathLayer
        gradientLayer.startPoint = CGPoint(x:0,y:0)
    }

    func updateTrackLayerPath() {
        let circle = UIBezierPath(
            ovalIn: CGRect(
                origin:CGPoint(x: 0, y: 00),
                size: CGSize(width:trackLayer.size.width,
                    height: trackLayer.size.width)))
        trackLayer.lineWidth = pathWidth
        trackLayer.path = circle.cgPath

    }
    override public func layoutSubviews() {
        update()
    }
    func updatePathLayerPath() {
        let arcCenter = pathLayer.center
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.lineWidth = pathWidth
        print("start = \(headAngle / CGFloat(M_PI)), end = \(tailAngle / CGFloat(M_PI))")
        pathLayer.path = UIBezierPath(
            arcCenter: arcCenter,
            radius: trackRadius,
            startAngle: ( twoPi  ) -  ((tailAngle - headAngle) >= twoPi ? tailAngle - twoPi : tailAngle),
            endAngle: ( twoPi ) -  headAngle,
            clockwise: true).cgPath
    }


    func tlabel(str:String, color:UIColor? = nil) -> CATextLayer{
        let f = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        let cgFont = CTFontCreateWithName(f.fontName as CFString?, f.pointSize/2,nil)
        let l = CATextLayer()
        l.bounds.size = CGSize(width: 30, height: 15)
        l.fontSize = f.pointSize
        l.foregroundColor =  disabledFormattedColor(color: color ?? tintColor).cgColor
        l.alignmentMode = kCAAlignmentCenter
        l.contentsScale = UIScreen.main.scale
        l.font = cgFont
        l.string = str

        return l
    }
    func updateHeadTailLayers() {
        let size = CGSize(width: 2 * buttonRadius, height: 2 * buttonRadius)
        let iSize = CGSize(width: 2 * iButtonRadius, height: 2 * iButtonRadius)
        let circle = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y:0), size: size)).cgPath
        let iCircle = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y:0), size: iSize)).cgPath
        tailLayer.path = circle
        headLayer.path = circle
        tailLayer.size = size
        headLayer.size = size
        tailLayer.position = tailPoint
        headLayer.position = headPoint
        topHeadLayer.position = headPoint
        headLayer.fillColor = UIColor.yellow.cgColor
        tailLayer.fillColor = UIColor.green.cgColor
        topHeadLayer.path = iCircle
        topHeadLayer.size = iSize
        topHeadLayer.fillColor = disabledFormattedColor(color: headBackgroundColor).cgColor
        topHeadLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let endText = tlabel(str: "Wake",color: disabledFormattedColor(color: tailTextColor))
        endText.position = topHeadLayer.center
        topHeadLayer.addSublayer(endText)
//        topTailLayer.addSublayer(stText)
    }


    func updateWatchFaceNumerals() {
        numeralsLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let f = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        let cgFont = CTFontCreateWithName(f.fontName as CFString?, f.pointSize/2,nil)
        let startPos = CGPoint(x: numeralsLayer.bounds.midX, y: 15)
        let origin = numeralsLayer.center
        let step = (2 * M_PI) / 12
        for i in (1 ... 12){
            let l = CATextLayer()
            l.bounds.size = CGSize(width: i > 9 ? 18 : 8, height: 15)
            l.fontSize = f.pointSize
            l.alignmentMode = kCAAlignmentCenter
            l.contentsScale = UIScreen.main.scale
            //            l.foregroundColor
            l.font = cgFont
            l.string = "\(i)"
            l.foregroundColor = disabledFormattedColor(color: numeralsColor ?? tintColor).cgColor
            l.position = CGVector(from:origin, to:startPos).rotate( CGFloat(Double(i) * step)).add(origin.vector).point.checked
            numeralsLayer.addSublayer(l)
        }
    }
    func updateWatchFaceTitle(){
        let f = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        let cgFont = CTFontCreateWithName(f.fontName as CFString?, f.pointSize/2,nil)
//        let titleTextLayer = CATextLayer()
        titleTextLayer.bounds.size = CGSize( width: titleTextInset.size.width, height: 50)
        titleTextLayer.fontSize = f.pointSize
        titleTextLayer.alignmentMode = kCAAlignmentCenter
        titleTextLayer.foregroundColor = disabledFormattedColor(color: centerTextColor ?? tintColor).cgColor
        titleTextLayer.contentsScale = UIScreen.main.scale
        titleTextLayer.font = cgFont
        //var computedTailAngle = tailAngle //+ (headAngle > tailAngle ? twoPi : 0)
        //computedTailAngle +=  (headAngle > computedTailAngle ? twoPi : 0)
        let fiveMinIncrements = Int( ((tailAngle - headAngle) / twoPi) * 12 /*hrs*/ * 12 /*5min increments*/)
        titleTextLayer.string = "\(fiveMinIncrements / 12)hr \((fiveMinIncrements % 12) * 5)min"
        titleTextLayer.position = gradientLayer.center

    }
    func tick() -> CAShapeLayer{
        let tick = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0,y:-3))
        path.addLine(to: CGPoint(x:0,y:3))
        tick.path  = path.cgPath
        tick.bounds.size = CGSize(width: 6, height: 6)
        return tick
    }

    func updateWatchFaceTicks() {
        repLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t = tick()
        t.strokeColor = disabledFormattedColor(color: minorTicksColor ?? tintColor).cgColor
        t.position = CGPoint(x: repLayer.bounds.midX, y: 10)
        repLayer.addSublayer(t)
        repLayer.position = self.bounds.center
        repLayer.bounds.size = self.internalInset.size

        repLayer2.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t2 = tick()
        t2.strokeColor = disabledFormattedColor(color: majorTicksColor ?? tintColor).cgColor
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
        update()
        strokeColor = disabledFormattedColor(color: tintColor)
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
        set { self.setValue(value: newValue, animated: false) }
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
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disabled  else {
        		pointMover = nil
            return
        }
        
        //        touches.forEach { (touch) in
        let touch = touches.first!
        let pointOfTouch = touch.location(in: self)
        guard let layer = self.overallPathLayer.hitTest( pointOfTouch ) else { return }
//         superview:UIView
//        while let superview = touch.gestureRecognizers{
//            guard let superview = superview as? UIPanGestureRecognizer else {  continue }
//            superview.scrollEnabled = false
//            break
//        }

        var prev = pointOfTouch
        let pp: (@escaping(CGPoint) -> Angle, @escaping(Angle)->()) -> (CGPoint) -> () = { g, s in
            return { p in
                let c = self.layer.center
                let computedP = CGPoint(x: p.x, y: self.layer.bounds.height - p.y)
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
                let x = CGVector(from: self.bounds.center, to:CGPoint(x: prev.x, y: self.layer.bounds.height - prev.y)).theta;
                prev = pt;
                return x }, {self.headAngle += $0; self.tailAngle += $0 })
        default: break
        }



    }
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        while var superview = self.superview{
        //            guard let superview = superview as? UIScrollView else {  continue }
        //            superview.scrollEnabled = true
        //            break
        //        }

    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pointMover = nil
        //        while var superview = self.superview{
        //            guard let superview = superview as? UIScrollView else {  continue }
        //            superview.scrollEnabled = true
        //            break
        //        }
        //        do something
        //        valueChanged = false
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let pointMover = pointMover else { return }
//        print(touch.locationInView(self))
        pointMover(touch.location(in: self))

        if let delegate = delegate {
            delegate.timesChanged(clock: self, startDate: self.startDate, endDate: endDate)
        }

    }

}
