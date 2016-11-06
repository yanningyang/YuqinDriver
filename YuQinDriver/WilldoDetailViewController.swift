//
//  未执行订单详情
//  WilldoDetailViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire

class WilldoDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //业务逻辑对象
    var bl = TodoOrderBL()
    //上个界面传过来的数据
    var toDoOrder: Order!
    //数据list
    var dataList = [Dictionary<String, String>]()
    
    let cellIdentifier = "TableViewCellIdentifierForOrderDetail"

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var doOrderBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    //用于拨打电话
    var dialingWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //为表视图注册类
        tableView.registerClass(CustomForDoingOrderTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cellNib = UINib(nibName: "CustomTableViewCellForOrderDetail", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellIdentifier)
        
        //隐藏接受按钮
        doOrderBtn.hidden = true
        
        //加载数据
        loadData()
        
        //预加载拨打电话webView，防止第一次点击打电话按钮时卡顿
        dialingWebView = UIWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtnAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func acceptOrderAction(sender: UIButton) {
        acceptOrder()
    }
    
    func loadData() {
        if toDoOrder != nil {
            
            dataList.removeAll()
            
            var dict1 = Dictionary<String, String>()
            dict1["label1"] = "订单号"
            dict1["label2"] = "\(toDoOrder.sn!)"
            dataList.append(dict1)
            
            var dict2 = Dictionary<String, String>()
            dict2["label1"] = "单位名称"
            dict2["label2"] = toDoOrder.customerOrganization
            dataList.append(dict2)
            
            var dict3 = Dictionary<String, String>()
            dict3["label1"] = "联系人"
            dict3["label2"] = toDoOrder.customerName
            dataList.append(dict3)
            
            var dict4 = Dictionary<String, String>()
            dict4["label1"] = "联系电话"
            dict4["label2"] = toDoOrder.customerPhoneNum
            dataList.append(dict4)
            
            var dict5 = Dictionary<String, String>()
            dict5["label1"] = "计费方式"
            dict5["label2"] = toDoOrder!.chargeMode!.rawValue
            dataList.append(dict5)
            
            var dict6 = Dictionary<String, String>()
            dict6["label1"] = "起始地"
            dict6["label2"] = toDoOrder.fromAddress?.briefDescription
            dataList.append(dict6)
            
            if self.toDoOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                
                var dict7 = Dictionary<String, String>()
                dict7["label1"] = "目的地"
                dict7["label2"] = toDoOrder.toAddress?.briefDescription
                dataList.append(dict7)
            }
            
            var dict8 = Dictionary<String, String>()
            dict8["label1"] = "开始时间"
            if let beginDate = toDoOrder!.actualBeginDate {
                dict8["label2"] = Utility.sharedInstance.stringFromDate(beginDate, orderType: self.toDoOrder!.chargeMode!.rawValue)
            }
            dataList.append(dict8)
            
            if self.toDoOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                
                var dict9 = Dictionary<String, String>()
                dict9["label1"] = "结束时间"
                if let endDate = toDoOrder!.actualEndDate {
                    dict9["label2"] = Utility.sharedInstance.stringFromDate(endDate, orderType: self.toDoOrder!.chargeMode!.rawValue)
                }
                dataList.append(dict9)
            }
            
            tableView.reloadData()
            
            let todoOrderStatus = bl.getOrderStatusById(toDoOrder.orderId!)
            if todoOrderStatus != nil && todoOrderStatus == Order.OrderStatus.SCHEDULED {
                doOrderBtn.hidden = false
            } else {
                doOrderBtn.hidden = true
            }
        }
    }
    
    func dialing(sender: UIButton) {
        
        if let phoneNumStr = toDoOrder.customerPhoneNum where dialingWebView != nil && !phoneNumStr.isEmpty {
            
            Utility.sharedInstance.dialing(self, webView: dialingWebView!,phoneNumStr: phoneNumStr)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CustomForDoingOrderTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomForDoingOrderTableViewCell
        
        let row = indexPath.row
        let dict = dataList[row]
        cell.label1.text = dict["label1"]
        cell.label2.text = dict["label2"]
        if dict["label1"] == "联系电话" {
            cell.button1.hidden = false
            cell.button1.addTarget(self, action: #selector(dialing(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell.button1.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    //接受订单
    func acceptOrder() {
        
        let orderId = toDoOrder.orderId
        let urlConnection = UrlConnection(action: "order_acceptOrder.action")
        let parameters = ["orderId" : "\(orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.toDoOrder.orderStatus = Order.OrderStatus.ACCEPTED
                    self.doOrderBtn.hidden = true
                    
                    //修改本地数据
                    self.bl.modifyOrderStatusById(orderId!, status: Order.OrderStatus.ACCEPTED)
                    //发送通知
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidAcceptOrderNotification, object: nil)
                } else {
                    
                    UITools.sharedInstance.toast("请求失败，请重试")
                }
            }
        })
    }

}
