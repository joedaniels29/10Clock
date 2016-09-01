//
//  ViewController.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 31/08/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import UIKit
//: Playground - noun: a place where people can play

import UIKit
func df() -> CGFloat {
    return    CGFloat(drand48())
}
extension CALayer {
    func doDebug(){
        self.borderColor = UIColor(hue: df() , saturation: df(), brightness: 1, alpha: 1).CGColor
		self.borderWidth = 2;
        self.sublayers?.forEach({$0.doDebug()})
    }
}
extension CGRect{
    var center { return CGPoint(x:midX, y: midY)}
}

protocol ClockDelegate {
    func timesChanged(clock:Clock, startDate:NSDate,  endDate:NSDate  ) -> ()

}


//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
class Clock : UIControl{
    typealias Angle = CGFloat
    
    
    
    
    var delegate:ClockDelegate?
//overall inset. Controls all sizes.
    var insetAmount: CGFloat = 80
    
    let trackLayer = CAShapeLayer()
    let pathLayer = CAShapeLayer()
    let headLayer = CAShapeLayer()
    let tailLayer = CAShapeLayer()
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
    var headAngle: CGFloat = 0
    var tailAngle: CGFloat = 0.7 * CGFloat(M_PI)
    var internalShift: CGFloat = 5;
    var pathWidth:CGFloat = 44
    
    var trackWidth:CGFloat {return pathWidth }
    func proj(theta:Angle) -> CGPoint{
        let center = CGPointMake( self.layer.frame.midX, self.layer.frame.midY)
        return CGPointMake(center.x + trackRadius * cos(theta) - buttonRadius,
                           center.y - trackRadius * sin(theta) - buttonRadius)
    }
    
    var headPoint: CGPoint{
        return proj(headAngle)
    }
    var tailPoint: CGPoint{
        return proj(tailAngle)
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
    var trackRadius:CGFloat { return inset.height / 2}
     var buttonRadius:CGFloat { return /*44*/ pathWidth / 2 }
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
        strokeColor = tintColor
        trackLayer.frame = inset
        pathLayer.frame = inset
        repLayer.frame = internalInset
        repLayer2.frame = internalInset
//        self.layer.doDebug()
        pathLayer.lineWidth = pathWidth
        trackLayer.lineWidth = trackWidth
        
        trackLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.fillColor = UIColor.clearColor().CGColor
        updateTrackLayerPath()
        updatePathLayerPath()
        updateHeadTailLayers()
        updateWatchFaceTicks()
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
    
    func updatePathLayerPath() {
        let arcCenter = CGPoint(x: pathLayer.bounds.width / 2.0, y: pathLayer.bounds.height / 2.0)
        
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.lineWidth = pathWidth
        pathLayer.path = UIBezierPath(
            arcCenter: arcCenter,
            radius: trackRadius,
            startAngle: headAngle,
            endAngle:( 2 * CGFloat(M_PI)) - tailAngle,
            clockwise: false).CGPath
    }
    
    func updateHeadTailLayers() {
        let size = CGSize(width: 2 * buttonRadius, height: 2 * buttonRadius)
        let circle = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y:0), size: size)).CGPath
        headLayer.frame.size = size
        tailLayer.frame.size = size
//        headLayer.anchorPoint = CGPoint(x: 0.5, y: 0.6)
        
        tailLayer.frame.origin = tailPoint
        headLayer.frame.origin = headPoint
        headLayer.path = circle
        headLayer.fillColor = UIColor.yellowColor().CGColor
        tailLayer.path = circle
        tailLayer.fillColor = UIColor.greenColor().CGColor
        
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
        repLayer.position = repLayer.superlayer!.position
        repLayer.bounds.size = self.internalInset.size
        
        repLayer2.sublayers?.forEach({$0.removeFromSuperlayer()})
        let t2 = tick()
        t2.strokeColor = tintColor.CGColor
        t2.lineWidth = 2
        t2.position = CGPoint(x: repLayer2.bounds.midX, y: 10)
        repLayer2.addSublayer(t2)
        repLayer2.position = repLayer2.superlayer!.position
        repLayer2.bounds.size = self.internalInset.size
    }
    var pointerLength: CGFloat = 0.0

    
    
    func createSublayers() {
        layer.addSublayer(repLayer2)
        layer.addSublayer(repLayer)
        layer.addSublayer(trackLayer)
        layer.addSublayer(pathLayer)
        layer.addSublayer(headLayer)
        layer.addSublayer(tailLayer)
        update()
        strokeColor = tintColor
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self	, attribute: .Height, multiplier: 1, constant: 0))
        tintColor = UIColor ( red: 0.8581, green: 0.0, blue: 1.0, alpha: 1.0 )
        backgroundColor = UIColor.lightGrayColor()
        createSublayers()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self	, attribute: .Height, multiplier: 1, constant: 0))
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
    
    
    var pointMover:(CGPoint) ->()?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        touches.forEach { (touch) in
        var touch = touches.first!
        guard let layer = self.layer.hitTest( touch.locationInView(self) ) else { return }

        
        switch(layer){
        	case headLayer:
                pointMover = { p in
                    var c = self.layer.frame.center
                    var v = CGPoint(p.x-c.x, p.y-c.y)
                    
                    CGPoint(c.x + (v.x / sqrt(pow(v.x,2)+pow(v.y,2))+ self.pathRadius ))
                    
            }
        case tailLayer:break
        case pathLayer:break
        default: break
        }
            
            
            
        }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        guard let touch = touches.first,  layer = self.layer.hitTest(touch.locationInView(self)) else { return }
            

        
        if let delegate = delegate where valueChanged {
            
        }
        
        valueChanged = false
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch(layer){
        case headLayer:
            tou
        case tailLayer:break
        case pathLayer:break
            
        }
    }

   }




var str = "Hello, playground"
let view = Clock(frame:CGRectMake(0,0,500, 500))


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        refresh()
    }
    func injected(){
        refresh()
    }
    var c:Clock?
    func refresh(){
        if let c=c{
            c.removeFromSuperview()
            
        }
        self.c = nil
        c = Clock(frame:CGRectMake(0,0,self.view.frame.width, self.view.frame.width))
        self.view.addSubview(c!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

