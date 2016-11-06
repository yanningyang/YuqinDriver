//
//  已完成订单列表
//  DoneTableViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/29.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import MJRefresh

class DoneTableViewController: UITableViewController {

    //业务逻辑对象
    var bl =  DoingOrderBL()
    //数据列表
    var listData: NSMutableArray!
    //Order列表
    var doneOrderList = [Order]()
    //搜索HeaderView
    var searchHeaderView: CustomHeaderViewForDoneTableViewTableViewCell!
    //搜索页码
    var currentPage: Int = 1
    //总页数
    var pageCount: Int = 1
    //当前获取到的记录数
    var recordCount: Int = 0
    //搜索起始日期
    var beginDateLong: Int64?
    //搜索终止日期
    var endDateLong: Int64?
//    //搜索起始日期
//    var beginDateStr: String = "起始日期"
//    //搜索终止日期
//    var endDateStr: String = "终止日期"
    //是否正在搜索
    var isSearching: Bool = false {
        didSet {
            currentPage = 1
            doneOrderList.removeAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置tableView背景色
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clearColor()
        
        //去除多余分割线
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
//        //添加右侧BarButton
//        let rightBarBtn = UIBarButtonItem()
//        rightBarBtn.target = self
//        rightBarBtn.action = "searchDoneOderByDate"
//        rightBarBtn.title = "搜索"
//        rightBarBtn.enabled = true
//        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem = rightBarBtn

        //添加下拉刷新控件
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshTableView))
        self.tableView.mj_header.automaticallyChangeAlpha = true
        //HeaderView 搜索栏
        self.searchHeaderView = tableView.dequeueReusableCellWithIdentifier("HeaderCellIdentifierForDone") as! CustomHeaderViewForDoneTableViewTableViewCell
        
        //加载数据
        self.tableView.mj_header.beginRefreshing()
        
    }
    
    //按日期搜索
    @IBAction func searchDoneOderByDate(sender: UIButton) {
        
        if searchHeaderView.beginDate == nil {
            UITools.sharedInstance.toast("请选择开始日期")
            return
        }
        if searchHeaderView.endDate == nil {
            UITools.sharedInstance.toast("请选择终止日期")
            return
        }
        
        beginDateLong = Int64((searchHeaderView.beginDate!.timeIntervalSince1970) * 1000)
        endDateLong = Int64((searchHeaderView.endDate!.timeIntervalSince1970) * 1000)
        
        if beginDateLong != nil && endDateLong != nil {
            isSearching = true
            loadDoneOrderFromNet(isLimitedByDate: isSearching)
        }
    }
    
    //从服务器加载已执行订单
    func loadDoneOrderFromNet(isLimitedByDate isLimitedByDate: Bool) {
        
        let urlConnection = UrlConnection(action: "order_listDoneOrder.action")
        let parameters: [String : String]!
        if isLimitedByDate {
            parameters = ["pageNum" : "\(currentPage)", "fromDate" : "\(beginDateLong!)", "toDate" : "\(endDateLong!)"]
        } else {
            parameters = ["pageNum" : "\(currentPage)"]
        }
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let dataDict = value as? NSDictionary {
                self.parseDoneOrderJSONtoOrderObject(dataDict)
                self.tableView.reloadData()
                self.doneOrderList.count == 0 ? UITools.sharedInstance.showNoDataTipToView(self.view, tipStr: self.isSearching ? "此时间段内无已执行订单" : "暂无已执行订单") : UITools.sharedInstance.hideNoDataTipFromView(self.view)
            }
            self.tableView.mj_header.endRefreshing()
            
            }, failureCallBack: { error in
                self.tableView.mj_header.endRefreshing()
        })
    }

    
    //将已执行订单JSON数据转换为Order对象List
    func parseDoneOrderJSONtoOrderObject(jsonDict: NSDictionary) {
        
        let pageBean = jsonDict["pageBean"] as! NSDictionary
        pageCount = pageBean["pageCount"] as! Int
        recordCount = pageBean["recordCount"] as! Int
        let dataList = pageBean["recordList"] as! NSArray
        
        for item in dataList {
            let order = Utility.sharedInstance.parseJSONtoOrderObject(item as! NSDictionary)
            self.doneOrderList.append(order)
        }
    }
    
    //刷新列表
    func refreshTableView() {
        
        searchHeaderView.beginDate = nil
        searchHeaderView.endDate = nil
        
        currentPage = 1
        isSearching = false
        doneOrderList.removeAll()
        loadDoneOrderFromNet(isLimitedByDate: false)
    }
    
    //加载更多
    func loadMore() {
        
        currentPage += 1
        NSLog("load more %d", currentPage)
        if currentPage <= pageCount {
            loadDoneOrderFromNet(isLimitedByDate: isSearching)
        } else {
            currentPage = pageCount
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return self.doneOrderList.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomForDoneTableViewCell! = tableView.dequeueReusableCellWithIdentifier("CellIdentifierForDone", forIndexPath: indexPath) as? CustomForDoneTableViewCell
        
        let section = indexPath.section
        if section == 0 {
            
            let row = indexPath.row
            let order = self.doneOrderList[row]
            if let beginDate = order.actualBeginDate {
                cell.label1.text = Utility.sharedInstance.stringFromDate(beginDate, orderType: order.chargeMode!.rawValue)
            }
            if let endDate = order.actualEndDate {
                cell.label2.text = Utility.sharedInstance.stringFromDate(endDate, orderType: order.chargeMode!.rawValue)
            }
            cell.label3.text = order.fromAddress?.briefDescription
            cell.label4.text = order.toAddress?.briefDescription
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchHeaderView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        if doneOrderList.count != 0 && indexPath.row == doneOrderList.count-1 {
            loadMore()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailForDone" {

            let page2:DoneDetailViewController = segue.destinationViewController as! DoneDetailViewController
            if let index = self.tableView.indexPathForSelectedRow?.row where index < doneOrderList.count {
                page2.doneOrder = doneOrderList[index]
            }
        }
    }

}
