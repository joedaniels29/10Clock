//
//  ViewController.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 31/08/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import UIKit
import TenClock

class ViewController: UITableViewController, TenClockDelegate {
    
    @IBAction func colorPreviewValueChanged(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            clock.tintColor = UIColor.blueColor()
        case 1:
            clock.tintColor = UIColor.greenColor()
        case 2:
            clock.tintColor = UIColor.purpleColor()
        default:()
        }
     	clock.update()
    }

    @IBOutlet weak var clock: TenClock!
    
    
    @IBAction func backgroundValueChanged(sender: UISegmentedControl) {
        var bg:UIColor?, fg:UIColor?
        switch(sender.selectedSegmentIndex){
        case 0:
            bg = UIColor.whiteColor()
            fg = UIColor.blackColor()
        case 1:
            fg = UIColor.whiteColor()
            bg = UIColor.blackColor()
        default:()
        }

        _ = cells.map{
            $0.backgroundColor = bg
        }
        _ = labels.map{
            $0.textColor = fg
        }
        
    }

    @IBAction func enabledValueChanged(sender: AnyObject) {
        clock.disabled = !clock.disabled
    }
    @IBAction func gradientValueChanged(sender: AnyObject) {
        
    }
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    
    
    
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    func timesChanged(clock:TenClock, startDate:NSDate,  endDate:NSDate  ) -> (){
//        print("start at: \(startDate), end at: \(endDate)")
		self.beginTime.text = dateFormatter.stringFromDate(startDate)
        self.endTime.text = dateFormatter.stringFromDate(endDate)
        
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    override func viewWillAppear(animated: Bool) {
        refresh()
    }
    var c:TenClock?



    func injected(){
        refresh()
    }
    func refresh(){

        if let c=c{
            c.removeFromSuperview()
            
        }
        
        
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

