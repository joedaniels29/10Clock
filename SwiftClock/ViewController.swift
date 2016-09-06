//
//  ViewController.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 31/08/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import UIKit
import SwiftClock
class ViewController: UIViewController, ClockDelegate {
    func timesChanged(clock:Clock, startDate:NSDate,  endDate:NSDate  ) -> (){
        print("start at: \(startDate), end at: \(endDate)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        refresh()
    }
    var c:Clock?



    func injected(){
        refresh()
    }
    func refresh(){
        if let c=c{
            c.removeFromSuperview()
            
        }
        self.c = nil
        c = Clock(frame:CGRectMake(0,0, self.view.frame.width / CGFloat(arc4random_uniform(4)), self.view.frame.width))
        c!.delegate = self
        self.view.addSubview(c!)
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

