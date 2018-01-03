//
//  正在执行订单
//  DoingViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire

//BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate,
class DoingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//    class RouteAnnotation: BMKPointAnnotation {
//        var type: Int32?//<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
//        var degree: Int32?
//    }
    
    @IBOutlet weak var dialingBtn: UIButton!
    @IBOutlet weak var recommendRouteBtn: UIButton!
    @IBOutlet weak var getOnBtn: UIButton!
    @IBOutlet weak var getOffBtn: UIButton!
    @IBOutlet weak var beginBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var signatureBtn: UIButton!
    
    //用于拨打电话
    var dialingWebView: UIWebView?

    @IBOutlet weak var doingOrderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //正在执行订单
    var displayOrder: Order!
    //业务逻辑对象
    var doingOrderBL = DoingOrderBL()
    //业务逻辑对象
    var todoOrderBL = TodoOrderBL()
    //数据list
    var dataList = [Dictionary<String, String>]()
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
        
        //为表视图注册类
        tableView.registerClass(CustomForDoingOrderTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cellNib = UINib(nibName: "CustomTableViewCellForOrderDetail", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellIdentifier)
        
        //预加载拨打电话webView，防止第一次点击打电话按钮时卡顿
        dialingWebView = UIWebView()
        
        //初始化按钮状态
        
        doingOrderView.hidden = true
        self.beginBtn.enabled = false
        self.getOnBtn.enabled = false
        self.getOffBtn.enabled = false
        self.signatureBtn.enabled = false
        self.endBtn.enabled = false
        
        //注册通知
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadOrderFromLocalAndRefreshView", name: UIApplicationWillEnterForegroundNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadOrderFromNet", name: Constant.ReloadDoingOrderFromNetNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadOrderFromLocalAndRefreshView), name: Constant.ReloadDoingOrderFromLocalNofification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadOrderFromLocalAndRefreshView), name: Constant.DidLoadWillDoOrderListFromNetNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadOrderFromLocalAndRefreshView), name: Constant.DidAcceptOrderNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGetDidSignNotification), name: Constant.DidSignNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGetOrderBeginNotification), name: Constant.OrderBeginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onGetOrderEndNotification), name: Constant.OrderEndNotification, object: nil)
        //远程通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onReceiveRemoteNotification(_:)), name: Constant.DidReceiveRemoteNotification, object: nil)
        
        //从服务器加载正在执行订单
        loadDoingOrderFromNet()
//        //从服务器加载未执行订单
//        loadWilldoOrderFromNet()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //从服务器加载正在执行订单
        loadDoingOrderFromNet()
    }
    
    //从服务器获取正在执行订单
    func loadDoingOrderFromNet() {
        
        let urlConnection = UrlConnection(action: "order_getBeginOrder.action")
        urlConnection.request(urlConnection.assembleUrl(), showLoadingAnimation: false, successCallBack: { value in
            if let retArray = value as? NSArray  {
                //如果没有正在执行订单则加载待执行订单
                if retArray.count == 0 {
                    self.loadWilldoOrderFromNet()
                    return
                }
                
                //Order列表
                var doingOrderList = [Order]()
                for item in retArray {
                    print("DoingOrder: %@", item)
                    
                    //parse json数据
                    let order = Utility.sharedInstance.parseJSONtoOrderObject(item as! NSDictionary)
                    doingOrderList.append(order)
                }
                //写入本地数据库
                //先清空
                self.doingOrderBL.removeAll()
                self.doingOrderBL.create(orderList: doingOrderList)
                
                self.loadOrderFromLocalAndRefreshView()
            }
            })
    }
    
    /// - MARK - handle Notification
    
    //收到签名成功通知时调用此方法
    func onGetDidSignNotification() {
        signatureBtn.enabled = false
        Utility.sharedInstance.setDoingOrderSignStatus(true, forKey: "signatureOrderId-\(displayOrder.orderId!)")
    }
    
    //订单开始成功后调用此方法
    func onGetOrderBeginNotification() {
        todoOrderBL.remove(displayOrder)
        
        //从服务器加载正在执行订单
        loadDoingOrderFromNet()
    }
    
    //订单结束成功后调用此方法
    func onGetOrderEndNotification() {
        
        self.doingOrderBL.removeAll()
        
        // 更新按钮状态
        self.beginBtn.enabled = false
        self.getOnBtn.enabled = false
        self.getOffBtn.enabled = false
        self.signatureBtn.enabled = false
        self.endBtn.enabled = false
        
        // 重置订单签名状态
        Utility.sharedInstance.removeDoingOrderSignStatus(forKey: "signatureOrderId-\(displayOrder.orderId!)")
//        loadOrderFromLocalAndRefreshView()
        loadDoingOrderFromNet()
    }
    
    //当收到远程通知时调用此方法
    func onReceiveRemoteNotification(notification: NSNotification) {
        
//        if let userInfo = notification.userInfo, aps = userInfo["aps"] as? NSDictionary {
//            
//        }
        
        loadDoingOrderFromNet()
    }
    
    //加载数据并刷新界面
    func loadOrderFromLocalAndRefreshView(){
        
        if let doingOrder = doingOrderBL.findEarliestOrder() {
            
            displayOrder = doingOrder

        } else {
            if let willdoOrder = todoOrderBL.findEarliestOrder() {
                
                displayOrder = willdoOrder
            } else {
                
                doingOrderView.hidden = true
                return
            }
        }
        
        if displayOrder != nil {
            
            doingOrderView.hidden = false

            dataList.removeAll()
            
            var dict1 = Dictionary<String, String>()
            dict1["label1"] = "订单号"
            dict1["label2"] = "\(displayOrder.sn!)"
            dataList.append(dict1)
            
            var dict2 = Dictionary<String, String>()
            dict2["label1"] = "单位名称"
            dict2["label2"] = displayOrder.customerOrganization
            dataList.append(dict2)
            
            var dict3 = Dictionary<String, String>()
            dict3["label1"] = "联系人"
            dict3["label2"] = displayOrder.customerName
            dataList.append(dict3)
            
            var dict4 = Dictionary<String, String>()
            dict4["label1"] = "联系电话"
            dict4["label2"] = displayOrder.customerPhoneNum
            dataList.append(dict4)
            
            var dict5 = Dictionary<String, String>()
            dict5["label1"] = "计费方式"
            dict5["label2"] = displayOrder!.chargeMode!.rawValue
            dataList.append(dict5)
            
            var dict6 = Dictionary<String, String>()
            dict6["label1"] = "起始地"
            dict6["label2"] = displayOrder.fromAddress?.briefDescription
            dataList.append(dict6)
            
            if self.displayOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                
                var dict7 = Dictionary<String, String>()
                dict7["label1"] = "下车地点"
                dict7["label2"] = displayOrder.toAddress?.briefDescription
                dataList.append(dict7)
            }
            
            var dict8 = Dictionary<String, String>()
            dict8["label1"] = "开始时间"
            if let beginDate = displayOrder!.actualBeginDate {
                dict8["label2"] = Utility.sharedInstance.stringFromDate(beginDate, orderType: self.displayOrder!.chargeMode!.rawValue)
                
            }
            dataList.append(dict8)
            
            // 按里程计费时 显示结束时间
            if self.displayOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                
                var dict9 = Dictionary<String, String>()
                dict9["label1"] = "结束时间"
                if let endDate = displayOrder!.actualEndDate {
                    dict9["label2"] = Utility.sharedInstance.stringFromDate(endDate, orderType: self.displayOrder!.chargeMode!.rawValue)
                }
                dataList.append(dict9)
            }
            
            var dict10 = Dictionary<String, String>()
            dict10["label1"] = "用户要求"
            dict10["label2"] = displayOrder.customerDemo
            dataList.append(dict10)
            
            var dict11 = Dictionary<String, String>()
            dict11["label1"] = "目的地"
            dict11["label2"] = displayOrder.destination
            dataList.append(dict11)
            
            tableView.reloadData()
            
            //设置按钮状态
            getBtnStatus()
        }
    }
    
    //从服务器加载待执行订单
    func loadWilldoOrderFromNet() {
        
        let urlConnection = UrlConnection(action: "order_listUndoOrder.action")
        urlConnection.request(urlConnection.assembleUrl(), showLoadingAnimation: false, successCallBack: { value in
            if let listData = value as? NSArray  {
                
                //Order列表
                var willdoOrderList = [Order]()
                //先清空
                for item in listData {
                    //解析json数据
                    let order = Utility.sharedInstance.parseJSONtoOrderObject(item as! NSDictionary)
                    willdoOrderList.append(order)
                }
                
                //排序
                willdoOrderList.sortInPlace({$0.planBeginDate!.compare($1.planBeginDate!) == .OrderedAscending })
                //写入本地数据库
                //先清空
                self.todoOrderBL.removeAll()
                self.todoOrderBL.create(orderList: willdoOrderList)
                
                //发送通知
                NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidLoadWillDoOrderListFromNetNotification, object: nil)
            }
        })
    }

    //拨打电话
    func dialing(sender: UIButton) {
        if let phoneNumStr = displayOrder.customerPhoneNum where dialingWebView != nil && !phoneNumStr.isEmpty {
            
            Utility.sharedInstance.dialing(self, webView: dialingWebView!, phoneNumStr: phoneNumStr)
        }
    }
    
    /// - MARK - Button Action
    @IBAction func beginBtnAction(sender: UIButton) {
        
        let alertController = UIAlertController(title: "整个订单的第一天从车库出发时，点击“开始”。你确定吗？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { alertAction in
            
            self.beginOrder()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func customerSignature(sender: UIButton) {
        
    }
    @IBAction func getOnBtnAction(sender: UIButton) {
        
        let alertController = UIAlertController(title: "某一天的任务中，客人首次上车时，点击“上车”。你确定吗？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { alertAction in
            
            self.getOn()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func getOffBtnAction(sender: UIButton) {
        
        let alertController = UIAlertController(title: "某一天的任务中，客人下车，这一天的任务结束时，点击“下车”。你确定吗？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { alertAction in
            
            self.getOff()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func endOrder(sender: UIButton) {
        
        let alertController = UIAlertController(title: "确定结束订单？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { alertAction in
            
            self.endOrder()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //开始订单
    func beginOrder() {
        
        let urlConnection = UrlConnection(action: "order_beginOrder.action")
        let parameters = ["orderId" : "\(displayOrder.orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    //修改本地数据
                    self.displayOrder.orderStatus = Order.OrderStatus.BEGIN
                    self.doingOrderBL.modifyOrderStatusById((self.displayOrder?.orderId)!, status: Order.OrderStatus.BEGIN)
                    // 修改按钮状态
                    self.beginBtn.enabled = false
                    self.getOnBtn.enabled = true
                    self.getOffBtn.enabled = false
                    self.signatureBtn.enabled = false
                    self.endBtn.enabled = false
                    
                    //发送通知
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.OrderBeginNotification, object: nil)
                } else {
                    
                    UITools.sharedInstance.toast("执行订单失败，请重试")
                }
            }
        })
    }
    
    //客户上车
    func getOn() {
        
        let urlConnection = UrlConnection(action: "order_customerGeton.action")
        let parameters = ["orderId" : "\(displayOrder.orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.beginBtn.enabled = false
                    self.getOnBtn.enabled = false
                    self.getOffBtn.enabled = true
                    self.signatureBtn.enabled = false
                    self.endBtn.enabled = false

                } else {
                    
                    UITools.sharedInstance.toast("请求失败，请重试")
                }
            }
        })
    }
    
    //客户下车
    func getOff() {
        
        let urlConnection = UrlConnection(action: "order_customerGetoff.action")
        let parameters = ["orderId" : "\(displayOrder.orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.beginBtn.enabled = false
                    if self.displayOrder!.chargeMode!.rawValue == Order.CHARGE_MODE_DICT["MILE"] {
                        self.getOnBtn.enabled = false
                    } else {
                        self.getOnBtn.enabled = true
                    }
                    self.getOffBtn.enabled = false
                    self.signatureBtn.enabled = true
                    self.endBtn.enabled = true
                    
                } else {
                    
                    UITools.sharedInstance.toast("请求失败，请重试")
                }
            }
        })
    }
    
    //结束订单
    func endOrder() {
        
        let urlConnection = UrlConnection(action: "order_endOrder.action")
        let parameters = ["orderId" : "\(displayOrder.orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    //                            self.doingOrderBL.modifyOrderStatusById((self.displayOrder?.orderId)!, status: Order.OrderStatus.END)
                    self.doingOrderBL.removeAll()
                    
                    self.beginBtn.enabled = false
                    self.getOnBtn.enabled = false
                    self.getOffBtn.enabled = false
                    self.signatureBtn.enabled = false
                    self.endBtn.enabled = false
                    
                    //发送通知
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.OrderEndNotification, object: nil)
                } else {
                    
                    UITools.sharedInstance.toast("结束订单失败，请重试")
                }
            }
        })
    }
    
    //获取按钮状态
    func getBtnStatus() {
        
        var urlConnection = UrlConnection(action: "order_canBeginOrder.action")
        let parameters = ["orderId" : "\(displayOrder.orderId!)"]
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                self.beginBtn.enabled = status
            }
        })

        urlConnection = UrlConnection(action: "order_canEndOrder.action")
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                self.endBtn.enabled = status
            }
        })
        
        urlConnection = UrlConnection(action: "order_canCustomerGeton.action")
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                self.getOnBtn.enabled = status
            }
        })
        
        urlConnection = UrlConnection(action: "order_canCustomerGetoff.action")
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                self.getOffBtn.enabled = status
            }
        })
        
        urlConnection = UrlConnection(action: "order_canCustomerSign.action")
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                self.signatureBtn.enabled = status
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.ShowRecommendRouteSegueIdentifier {
//            let page2: RecommendRouteViewController = segue.destinationViewController as! RecommendRouteViewController
//            page2.doingOrder = displayOrder
            
        } else if segue.identifier == Constant.ShowSignatureSegueIdentifier {
            let page2: SignatureViewController = segue.destinationViewController as! SignatureViewController
            page2.doingOrder = self.displayOrder
            
        } else if segue.identifier == Constant.ShowOtherExpenditureSegueIdentifier {
            let page2: OtherExpenditureViewController = segue.destinationViewController as! OtherExpenditureViewController
            page2.doingOrder = self.displayOrder
        }
    }
}
