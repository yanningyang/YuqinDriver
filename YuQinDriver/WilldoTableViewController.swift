//
//  未执行订单列表
//  WilldoTableViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import MJRefresh

class WilldoTableViewController: UITableViewController {

    //业务逻辑对象
    var bl =  TodoOrderBL()
    //Order列表
    var willdoOrderList = [Order]()
    //待执行订单ID
    var toDoOrder: Order?
    //将要执行订单“执行”按钮
    var toDoOrderExeBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置tableView背景色
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clearColor()
        
        //去除多余分割线
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //添加下拉刷新控件
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshTableView))
        self.tableView.mj_header.automaticallyChangeAlpha = true
        
        //注册订单开始通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGetOrderBeginNotification), name: Constant.OrderBeginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGetOrderAcceptedNotification), name: Constant.DidAcceptOrderNotification, object: nil)
        //远程通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onReceiveRemoteNotification(_:)), name: Constant.DidReceiveRemoteNotification, object: nil)
        
        //加载数据
        self.tableView.mj_header.beginRefreshing()
    }
    
    //从服务器加载待执行订单
    func loadWilldoOrderFromNet() {
        
        let urlConnection = UrlConnection(action: "order_listUndoOrder.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let listData = value as? NSArray  {
                
                //先清空
                self.willdoOrderList.removeAll()
                for item in listData {
                    //解析json数据
                    let order = Utility.sharedInstance.parseJSONtoOrderObject(item as! NSDictionary)
                    self.willdoOrderList.append(order)
                }
                
                self.willdoOrderList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.view, tipStr: "暂无待执行订单") : UITools.sharedInstance.hideNoDataTipFromView(self.view)
                
                //排序
                self.orderListSort()
                //写入本地数据库
                //先清空
                self.bl.removeAll()
                self.bl.create(orderList: self.willdoOrderList)
                
                //刷新列表
                self.tableView.reloadData()
                
                self.tableView.mj_header.endRefreshing()
            }
            }, failureCallBack: { error in
                self.tableView.mj_header.endRefreshing()
        })
    }
    
    //当接收到订单开始通知时调用此方法
    func onGetOrderBeginNotification() {
        
        loadWilldoOrderFromNet()
    }
    //当接收到订单已接受通知时调用此方法
    func onGetOrderAcceptedNotification() {
        
        loadWilldoOrderFromNet()
    }
    
    //当收到远程通知时调用此方法
    func onReceiveRemoteNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, aps = userInfo["aps"] as? NSDictionary {
            
            let badge = aps["badge"] as! Int
            self.tabBarItem.badgeValue =  "\(badge)"
        }
        refreshTableView()
    }
    
    //刷新列表
    func refreshTableView() {
        
        willdoOrderList.removeAll()
        loadWilldoOrderFromNet()
    }
    
    //排序，由大到小
    func orderListSort() {
        
        willdoOrderList.sortInPlace({$0.planBeginDate!.compare($1.planBeginDate!) == .OrderedAscending })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return self.willdoOrderList.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomTableViewCell! = tableView.dequeueReusableCellWithIdentifier("CellIdentifierForToDo", forIndexPath: indexPath) as? CustomTableViewCell

        let row = indexPath.row
        let order = self.willdoOrderList[row]
        cell.myLabel.text = Utility.sharedInstance.stringFromDate(order.planBeginDate!, orderType: order.chargeMode!.rawValue)
        cell.myLabel2.text = order.fromAddress?.briefDescription
        cell.myLabel3.text = order.toAddress?.briefDescription
        
        cell.acceptBtn.tag = row
        if order.orderStatus == Order.OrderStatus.SCHEDULED {
            cell.acceptBtn.hidden = false
        } else if order.orderStatus == Order.OrderStatus.ACCEPTED {
            cell.acceptBtn.hidden = true
        }
        cell.acceptBtn.addTarget(self, action: #selector(acceptOrder(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.parentViewController?.tabBarItem.badgeValue = nil
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    //接受订单
    func acceptOrder(sender: UIButton) {
        
        let orderId = willdoOrderList[sender.tag].orderId
        let urlConnection = UrlConnection(action: "order_acceptOrder.action")
        let parameters = ["orderId" : "\(orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.willdoOrderList[sender.tag].orderStatus = Order.OrderStatus.ACCEPTED
                    sender.hidden = true
                    
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
    
    //执行订单
    func doOrder() {
        
        if toDoOrder != nil {
            
            bl.create(toDoOrder!)
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constant.ReloadDoingOrderFromLocalNofification, object: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailForWillDo" {
            let page2:WilldoDetailViewController = segue.destinationViewController as! WilldoDetailViewController
            if let index = tableView.indexPathForSelectedRow?.row where index < willdoOrderList.count {
                page2.toDoOrder = willdoOrderList[index]
            }
        }
    }

}
