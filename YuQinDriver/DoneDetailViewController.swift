//
//  已完成订单详情
//  DoneDetailViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/29.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit

class DoneDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data: NSDictionary?
    
    var doneOrder: Order!
    //数据list
    var dataList = [Dictionary<String, String>]()
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "TableViewCellIdentifierForOrderDetail"
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CustomForDoingOrderTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomForDoingOrderTableViewCell
        
        let row = indexPath.row
        let dict = dataList[row]
        cell.label1.text = dict["label1"]
        cell.label2.text = dict["label2"]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //为表视图注册类
        tableView.registerClass(CustomForDoingOrderTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cellNib = UINib(nibName: "CustomTableViewCellForOrderDetail", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellIdentifier)
        
        loadData()
    }
    
    @IBAction func closeBtnAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadData() {
        if doneOrder != nil {
            
            dataList.removeAll()
            
            var dict1 = Dictionary<String, String>()
            dict1["label1"] = "订单号"
            dict1["label2"] = "\(doneOrder.sn!)"
            dataList.append(dict1)
            
            var dict2 = Dictionary<String, String>()
            dict2["label1"] = "单位名称"
            dict2["label2"] = doneOrder.customerOrganization
            dataList.append(dict2)
            
            var dict3 = Dictionary<String, String>()
            dict3["label1"] = "联系人"
            dict3["label2"] = doneOrder.customerName
            dataList.append(dict3)
            
            var dict4 = Dictionary<String, String>()
            dict4["label1"] = "联系电话"
            dict4["label2"] = doneOrder.customerPhoneNum
            dataList.append(dict4)
            
            var dict5 = Dictionary<String, String>()
            dict5["label1"] = "计费方式"
            dict5["label2"] = doneOrder!.chargeMode!.rawValue
            dataList.append(dict5)
            
            var dict6 = Dictionary<String, String>()
            dict6["label1"] = "起始地"
            dict6["label2"] = doneOrder.fromAddress?.briefDescription
            dataList.append(dict6)
            
            if self.doneOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                
                var dict7 = Dictionary<String, String>()
                dict7["label1"] = "下车地点"
                dict7["label2"] = doneOrder.toAddress?.briefDescription
                dataList.append(dict7)
            }
            
            var dict8 = Dictionary<String, String>()
            dict8["label1"] = "开始时间"
            if let beginDate = doneOrder!.actualBeginDate {
                dict8["label2"] = Utility.sharedInstance.stringFromDate(beginDate, orderType: self.doneOrder!.chargeMode!.rawValue)
            }
            dataList.append(dict8)
            
//            if self.doneOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
//                
//            }
            var dict9 = Dictionary<String, String>()
            dict9["label1"] = "结束时间"
            if let endDate = doneOrder!.actualEndDate {
                dict9["label2"] = Utility.sharedInstance.stringFromDate(endDate, orderType: self.doneOrder!.chargeMode!.rawValue)
            }
            dataList.append(dict9)
            
            var dict10 = Dictionary<String, String>()
            dict10["label1"] = "油费"
            dict10["label2"] = doneOrder.refuelMoney
            dataList.append(dict10)
            
            var dict11 = Dictionary<String, String>()
            dict11["label1"] = "洗车费"
            dict11["label2"] = doneOrder.washingMoney
            dataList.append(dict11)
            
            var dict12 = Dictionary<String, String>()
            dict12["label1"] = "停车费"
            dict12["label2"] = doneOrder.parkingFee
            dataList.append(dict12)
            
            var dict13 = Dictionary<String, String>()
            dict13["label1"] = "过路费"
            dict13["label2"] = doneOrder.toll
            dataList.append(dict13)
            
            var dict14 = Dictionary<String, String>()
            dict14["label1"] = "食宿费"
            dict14["label2"] = doneOrder.roomAndBoardFee
            dataList.append(dict14)
            
            var dict15 = Dictionary<String, String>()
            dict15["label1"] = "其他费用"
            dict15["label2"] = doneOrder.otherFee
            dataList.append(dict15)
            
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
