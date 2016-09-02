//
//  ViewController.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 31/08/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import UIKit

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

