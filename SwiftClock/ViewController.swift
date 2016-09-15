//
//  ViewController.swift
//  SwiftClock
//
//  Created by Joseph Daniels on 31/08/16.
//  Copyright © 2016 Joseph Daniels. All rights reserved.
//

import UIKit
import TenClock
class TenClockCell : UITableViewCell{
    
    @IBOutlet weak var clock: TenClock!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    static func estHeight() -> CGFloat{
        return 200
    }
}
class GradientCell : UITableViewCell{
    
    @IBOutlet weak var clock: TenClock!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    static func estHeight() -> CGFloat{
        return 200
    }
}
class BackgroundCell : UITableViewCell{
    
    @IBOutlet weak var clock: TenClock!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    static func estHeight() -> CGFloat{
        return 200
    }
}

class ColorCell : UITableViewCell{
    
    @IBOutlet weak var clock: TenClock!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var beginTime: UILabel!
    static func estHeight() -> CGFloat{
        return 200
    }
}

class ViewController: UITableViewController, TenClockDelegate {
    
    weak var tenClockCell:TenClockCell?
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return classForIndexPath(indexPath).estHeight()
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func classForIndexPath(indexPath: NSIndexPath) -> AnyClass {
        switch indexPath.row{
        case 0: return ColorCell.self
            case 1: return BackgroundCell.self
            case 2: return GradientCell.self
            case 3: return TenClockCell.self
        default: fatalError()
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(classForIndexPath(indexPath)),
                                                               forIndexPath: indexPath)
        switch cell{
        case let cell as TenClockCell:
            cell.clock.delegate = self
        		self.tenClockCell = cell
        default: ()
        }
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    func timesChanged(clock:TenClock, startDate:NSDate,  endDate:NSDate  ) -> (){
//        print("start at: \(startDate), end at: \(endDate)")
		self.tenClockCell?.beginTime.text = dateFormatter.stringFromDate(startDate)
        self.tenClockCell?.endTime.text = dateFormatter.stringFromDate(endDate)
        
    
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

