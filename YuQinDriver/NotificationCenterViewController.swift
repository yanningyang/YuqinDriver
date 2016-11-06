//
//  NotificationCenterViewController.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/4/11.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class NotificationCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notificationList = [OrderNotification]()
    let bl = NotificationBL()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadDataFromLocal), name: Constant.DidReceiveRemoteNotification, object: nil)
        
//        //添加右侧BarButton
//        let rightBarBtn = UIBarButtonItem()
//        rightBarBtn.target = self
//        rightBarBtn.action = #selector()
//        rightBarBtn.title = "搜索"
//        rightBarBtn.enabled = true
//        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem = rightBarBtn
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension

        loadDataFromLocal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadDataFromLocal() {
        
        notificationList.removeAll()
        
        let dataList = bl.findAll()
        for item in dataList {
            let orderNotification = item as! OrderNotification
            notificationList.append(orderNotification)
        }
        
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellForNotification", forIndexPath: indexPath) as! NotificationTableViewCell
        
        let row = indexPath.row
        let notification = notificationList[row]
        cell.label.text = notification.alertMsg
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}