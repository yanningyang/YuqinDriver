//
//  ChooseCompanyViewController.swift
//  YuQinDriver
//
//  Created by ksn_cn on 2016/10/26.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class ChooseCompanyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataList: [[String : AnyObject]]!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ChooseCompanyCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        let row = indexPath.row
        cell!.textLabel?.text = dataList[row]["name"] as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("\(dataList[row]["id"] as! Int)", forKey: "companyId")
        userDefaults.synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidReceiveChooseCompanyNotification, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
