//
//  Utility.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/29.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD

public class Utility: NSObject {
    
    static let sharedInstance = Utility()
    //私有化init方法，保证单例
    private override init(){}
    
    //获取登录用户的帐号密码
    public func getUserInfo() ->(String?, String?)? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let userName = userDefault.objectForKey("userName") as? String
        let password = userDefault.objectForKey("password") as? String
        return (userName, password)
    }
    //获取登录用户的帐号密码
    public func getUserInfo1() ->(String?, String?, String?) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let userName = userDefault.objectForKey("userName") as? String
        let password = userDefault.objectForKey("password") as? String
        let companyId = userDefault.objectForKey("companyId") as? String
        return (userName, password, companyId)
    }
    
    //获取正在执行订单的签名状态
    public func getDoingOrderSignStatus(forKey key: String) -> Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let isSigned = userDefault.boolForKey(key)
        return isSigned
    }
    
    //保存正在执行订单的签名状态
    public func setDoingOrderSignStatus(isSigned: Bool, forKey key: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(isSigned, forKey: key)
    }
    
    //删除正在执行订单的签名状态
    public func removeDoingOrderSignStatus(forKey key: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey(key)
    }
    
    //获取旧deviceToken
    public func getOldDeviceToken() -> String? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let deviceToken = userDefault.stringForKey("oldDeviceToken")
        return deviceToken
    }
    
    //获取新deviceToken
    public func getNewDeviceToken() -> String? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let deviceToken = userDefault.stringForKey("newDeviceToken")
        return deviceToken
    }
    
    //保存deviceToken
    public func setOldDeviceToken(deviceToken: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(deviceToken, forKey: "oldDeviceToken")
    }
    
    //保存deviceToken
    public func setNewDeviceToken(deviceToken: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(deviceToken, forKey: "newDeviceToken")
    }
    
    //注销
    public func logout(withToast isToast: Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "userName")
        userDefaults.setObject(nil, forKey: "password")
        userDefaults.setBool(false, forKey: "isLogin")
        userDefaults.synchronize()
        
        //业务逻辑对象
        let doingOrderBL = DoingOrderBL()
        //业务逻辑对象
        let todoOrderBL = TodoOrderBL()
        doingOrderBL.removeAll()
        todoOrderBL.removeAll()
        
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        window.backgroundColor = UIColor.whiteColor()
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        
        if isToast {
            UITools.sharedInstance.toast("用户名密码失效，请重新登录")
        }
    }
    
    //注销
    public func logout() {

        let newDeviceToken = ""
        
        let urlConnection = UrlConnection(action: "user_updateDeviceToken.action")
        let parameters = ["deviceToken" : newDeviceToken]
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.logout(withToast: false)
                    
                } else {
                    
                }
            }
        })
    }
    
    //拨打电话
    public func dialing(vc: UIViewController, webView: UIWebView, phoneNumStr: String) {
        if !phoneNumStr.isEmpty {
            
            let phoneNumFormatStr = NSMutableString.init(string: "tel://\(phoneNumStr)") as String
            //方法1（有弹出提示）
//            let dialingWebView = UIWebView()
            webView.loadRequest(NSURLRequest(URL: NSURL(string: phoneNumFormatStr)!))
            vc.view.addSubview(webView)
            
            //方法2（无弹出提示）
//            UIApplication.sharedApplication().openURL(NSURL(string: phoneNumFormatStr)!)
        }
    }
    
    //获取Baidu资源路径
    public func getBaiduMapBundlePath(filename: String) ->String? {
        var ret: String?
        let myBundlePath: String = (NSBundle.mainBundle().resourcePath?.stringByAppendingString("/" + Constant.MYBUNDLE_NAME))!
        let libBundle: NSBundle = NSBundle(path: myBundlePath)!
        if !filename.isEmpty {
            ret = (libBundle.resourcePath?.stringByAppendingString("/" + filename))!
        }
        return ret
    }
    
    //JSONparser
    public func getJSONObjectFromLocalFile(filePath: String) ->NSDictionary? {
        
        let path = NSBundle.mainBundle().pathForResource(filePath, ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        
        do {
            let jsonObj: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            return jsonObj
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        
        return nil
    }
    
    //将订单JSON对象转换为Order对象
    public func parseJSONtoOrderObject(jsonDict: NSDictionary) ->Order {
        
        let order = Order()
        if let orderId = jsonDict["orderId"] as? Int {
            order.orderId = orderId
        }
        if let sn = jsonDict["sn"] as? String {
            order.sn = sn
        }
        if let customerOrganization = jsonDict["customerOrganization"] as? String {
            order.customerOrganization = customerOrganization
        }
        
        //起始地址
        if let fromAddressDescription = jsonDict["fromAddress"] as? String {
            let fromAddress = Address()
            fromAddress.briefDescription = fromAddressDescription
            order.fromAddress = fromAddress
        }
//        if let fromAddressDict = jsonDict["fromAddress"] as? NSDictionary {
//            
//            let fromAddress = Address()
//            if let createTime = fromAddressDict["createTime"] as? Double {
//                
//                fromAddress.createTime = getNSDateFromTimestampWithMSPrecision(createTime)
//            }
//            if let lastUpdateTime = fromAddressDict["lastUpdateTime"] as? Double {
//                
//                fromAddress.lastUpdateTime = getNSDateFromTimestampWithMSPrecision(lastUpdateTime)
//            }
//            if let description = fromAddressDict["description"] as? String {
//                
//                fromAddress.briefDescription = description
//            }
//            if let detail = fromAddressDict["detail"] as? String {
//                
//                fromAddress.detail = detail
//            }
//            if let id = fromAddressDict["id"] as? Int {
//            
//                fromAddress.id = id
//            }
//            
//            let fromAddressLocation = Location()
//            if let fromLocationDict = fromAddressDict["location"] as? NSDictionary {
//            
//                fromAddressLocation.id = fromLocationDict["id"] as? Int
//                fromAddressLocation.latitude = fromLocationDict["latitude"] as? Double
//                fromAddressLocation.longitude = fromLocationDict["longitude"] as? Double
//            }
//            
//            fromAddress.location = fromAddressLocation
//            order.fromAddress = fromAddress
//        }
//        
//        if let fromLatitude = jsonDict["fromLatitude"] as? Double {
//            
//            order.fromLatitude = fromLatitude
//        }
//        if let fromLongitude = jsonDict["fromLongitude"] as? Double {
//            
//            order.fromLongitude = fromLongitude
//        }
        
        //目的地址
        if let toAddressDescription = jsonDict["toAddress"] as? String {
            let toAddress = Address()
            toAddress.briefDescription = toAddressDescription
            order.toAddress = toAddress
        }
//        if let toAddressDict = jsonDict["toAddress"] as? NSDictionary {
//            
//            let toAddress = Address()
//            if let createTime = toAddressDict["createTime"] as? Double {
//            
//                toAddress.createTime = getNSDateFromTimestampWithMSPrecision(createTime)
//            }
//            if let lastUpdateTime = toAddressDict["lastUpdateTime"] as? Double {
//                
//                toAddress.lastUpdateTime = getNSDateFromTimestampWithMSPrecision(lastUpdateTime)
//            }
//            if let description = toAddressDict["description"] as? String {
//            
//                toAddress.briefDescription = description
//            }
//            if let detail = toAddressDict["detail"] as? String {
//            
//                toAddress.detail = detail
//            }
//            if let id = toAddressDict["id"] as? Int {
//            
//                toAddress.id = id
//            }
//            
//            let toAddressLocation = Location()
//            if let toLocationDict = toAddressDict["location"] as? NSDictionary {
//            
//                toAddressLocation.id = toLocationDict["id"] as? Int
//                toAddressLocation.latitude = toLocationDict["latitude"] as? Double
//                toAddressLocation.longitude = toLocationDict["longitude"] as? Double
//            }
//            
//            toAddress.location = toAddressLocation
//            order.toAddress = toAddress
//        }
//        
//        if let toLatitude = jsonDict["toLatitude"] as? Double {
//            
//            order.toLatitude = toLatitude
//        }
//        if let toLongitude = jsonDict["toLongitude"] as? Double {
//            
//            order.toLongitude = toLongitude
//        }
        
        if let date = jsonDict["planBeginDate"] as? Double {
            
            order.planBeginDate = getNSDateFromTimestampWithMSPrecision(date)
        }
        if let date = jsonDict["planEndDate"] as? Double {
            
            order.planEndDate = getNSDateFromTimestampWithMSPrecision(date)
        }
        if let date = jsonDict["actualBeginDate"] as? Double {
            
            order.actualBeginDate = getNSDateFromTimestampWithMSPrecision(date)
        }
        if let date = jsonDict["actualEndDate"] as? Double {
            
            order.actualEndDate = getNSDateFromTimestampWithMSPrecision(date)
        }
        
        if let customerName = jsonDict["customerName"] as? String {
            
            order.customerName = customerName
        }
        if let customerPhoneNum = jsonDict["customerPhone"] as? String {
            
            order.customerPhoneNum = customerPhoneNum
        }
        
        if let chargeMode = jsonDict["chargeMode"] as? String {
            
            order.chargeMode = Order.ChargeMode(rawValue: Order.CHARGE_MODE_DICT[chargeMode]!)
        }
        if let orderStatus = jsonDict["status"] as? String {
            
            order.orderStatus = Order.OrderStatus(rawValue: orderStatus)
        }
        
        return order
    }
    
    /// 将精确到毫秒的时间戳转换为NSDate对象
    public func getNSDateFromTimestampWithMSPrecision(timestamp: Double) ->NSDate {
        return NSDate(timeIntervalSince1970: timestamp / 1000)
    }
    
    /// 弹出Alert
    func popAlerView(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(ok)
        
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            rootViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /// 弹出更新提示
    func showUpdateTip(notification: NSNotification) {
        
        guard let updateInfo = notification.object as? UpdateInfo else {
            return
        }
        
        guard let localVersion = getLocalVersion() else {
            return
        }
        
        if Double(localVersion) < Double(updateInfo.version!) {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(false, forKey: "isShowUpdateItems")
            userDefaults.synchronize()
            
            popUpdateAlerView(localVersion, newVersion: updateInfo.version!, appId: APP_ID)
        } else if updateInfo.checkUpdateType == 1 {
            // 显示更新内容
            showUpdateItems(notification)
        } else if updateInfo.checkUpdateType == 2 {
            UITools.sharedInstance.toast("已是最新版本")
        }
    }
    
    /// 弹出更新内容
    func showUpdateItems(notification: NSNotification) {
        
        guard let localVersion = getLocalVersion() else {
            return
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let newVersion = userDefaults.stringForKey("newVersion") else {
            return
        }
        
        if Double(localVersion) == Double(newVersion) {
            
            let isShowUpdateItems = userDefaults.boolForKey("isShowUpdateItems")
            if !isShowUpdateItems {
                
                userDefaults.setBool(true, forKey: "isShowUpdateItems")
                popAlerView("本次更新说明", message: Constant.APP_UPDATE_DETAILS)
            }
        }
    }
    
    /// 检查更新Info并解析
    func loadAndParseUpdateInfoXML(checkUpdateType: Int) {
        
        let url = Constant.CheckUpdateUrl
        
        Alamofire.request(.GET, url)
            .responseData() {response in
                
                print("Check Update Request: ", response.request)
                
                switch (response.result) {
                case .Success(let value):
                    
                    print("Check Update Success value: \(value)")
                    if let data = response.data {
                        UpdateInfoXmlParser.sharedInstance.start(data, checkUpdateType: checkUpdateType)
                    }
                    
                case .Failure(let error):
                    
                    NSLog("Check Update Fail Error: %@", error)
                }
        }
    }
    
    //获取本地版本
    func getLocalVersion() ->String? {
        
        if let infoDict = NSBundle.mainBundle().infoDictionary {
            
            let appName = infoDict["CFBundleDisplayName"] as! String
            let appVersion = infoDict["CFBundleShortVersionString"] as! String
            let appBuild = infoDict["CFBundleVersion"] as! String
            
            NSLog("local version appName:%@, appVersion:%@, appBuild:%@", appName, appVersion, appBuild)
            
            return appVersion
            
        } else {
            NSLog("获取本地版本失败")
            return nil
        }
    }
    //弹出更新Alert
    func popUpdateAlerView(oldVersion: String, newVersion: String, appId: String) {
        
        let message = "当前的版本是:\(oldVersion)，发现新版本:\(newVersion)，是否更新？"
        let alertController = UIAlertController(title: "更新提醒", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "现在更新", style: UIAlertActionStyle.Default) { alertAction in
            
            //跳转到iTunes
            if let url = NSURL(string: "https://itunes.apple.com/cn/app/id\(appId)?mt=8") {
                
                UIApplication.sharedApplication().openURL(url)
            }
        }
        let cancel = UIAlertAction(title: "下次再说", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            rootViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //上传token
    func updateDeviceToken() {
        
        let newDeviceToken = getNewDeviceToken()
        
        if newDeviceToken == nil {
            return
        }
        
        if !(NSUserDefaults.standardUserDefaults().boolForKey("isLogin")) {
            return
        }
        
        let urlConnection = UrlConnection(action: "user_updateDeviceToken.action")
        let parameters = ["deviceType" : "ios", "deviceToken" : newDeviceToken!]
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    self.setOldDeviceToken(newDeviceToken!)
                } else {
                    debugPrint("Update Device Token Failed")
                }
            }
        })
    }
    
    // 格式化时间
    public func stringFromDate(date: NSDate, orderType: String) -> String {
        //日期格式化
        let dateFormatter = NSDateFormatter()
        // 按天计费不显示时分信息
        if orderType == Order.CHARGE_MODE_DICT["DAY"] {
            dateFormatter.dateFormat = "yyyy/MM/dd"
        } else {
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        }
    
        return dateFormatter.stringFromDate(date)
    }
}
