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
    
    @IBAction func colorPreviewValueChanged(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            self.view.tintColor =  UIButton(type: .system).titleColor(for: .normal)!
        case 1:
            self.view.tintColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        case 2:
            self.view.tintColor = .purple
        default:()
        }
        
     	clock.update()
    }

    @IBOutlet weak var clock: TenClock!
    

    
    @IBAction func backgroundValueChanged(_ sender: UISegmentedControl) {
        var bg:UIColor?, fg:UIColor?
        switch(sender.selectedSegmentIndex){
        case 0:
            bg = .white
            fg = .black
        case 1:
            fg = .white
            bg = .black
        default:()
        }

        _ = cells.map{
            $0.backgroundColor = bg
        }
        _ = labels.map{
            $0.textColor = fg
        }
        
    }

    @IBAction func enabledValueChanged(_ sender: AnyObject) {
        clock.disabled = !clock.disabled
    }
    @IBAction func gradientValueChanged(_ sender: AnyObject) {
        
    }
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var controls: [UISegmentedControl]!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    
    
    
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    func timesChanged(_ clock:TenClock, startDate:Date,  endDate:Date  ) -> (){
        print("start at: \(startDate), end at: \(endDate)")
		
        
    
    }
    func timesUpdated(_ clock:TenClock, startDate:Date,  endDate:Date  ) -> (){
        self.beginTime.text = dateFormatter.string(from: startDate)
        self.endTime.text = dateFormatter.string(from: endDate)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        if let x = self.tableView as? ConditionallyScrollingTableView{
            x.avoidingView = clock
            x.delaysContentTouches = false
        }
        
        clock.startDate = Date()
        clock.endDate = Date().addingTimeInterval(-60 * 60 * 8 )
        clock.update()
        clock.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
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

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

