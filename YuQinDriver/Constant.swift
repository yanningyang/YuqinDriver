//
//  Constant.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/31.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import Foundation

// APP ID
public let APP_ID = "1150258247"
//鉴权失败
public let UNAUTHORIZED = "unauthorized"
//接口参数错误
public let BAD_PARAMETER = "badParameter"
//baidu map key
public let BAIDUMAP_KEY = "OkaECjDptddOmGVad3gkfNPnKyUpO4ZS"

public class Constant {
    
    public static let MYBUNDLE_NAME = "mapapi.bundle"
    
    /// MARK -- 接口地址
    #if DEBUG
    // 开发环境
    public static let HOST_NAME = "http://101.201.31.147"
    #else
    // 生产环境
    public static let HOST_NAME = "http://oa.yuqinqiche.com"
    #endif
    
    public static let HOST_PATH = HOST_NAME + "/app"

    //检查版本地址
    public static let CheckUpdateUrl = Constant.HOST_NAME + "/apk/DriverAPPUpdate.xml"
    
    
    /// MARK -- 通知
    //从本地加载正在执行订单通知
    public static let ReloadDoingOrderFromLocalNofification = "ReloadDoingOrderFromLocalNofification"
    //从服务器加载正在执行订单通知
    public static let ReloadDoingOrderFromNetNofification = "ReloadDoingOrderFromNetNofification"
    //订单开始通知
    public static let OrderBeginNotification = "OrderBeginNotification"
    //订单结束通知
    public static let OrderEndNotification = "OrderEndNotification"
    //从服务器加载未执行订单列表通知
    public static let DidLoadWillDoOrderListFromNetNotification = "DidLoadWillDoOrderListFromNetNotification"
    //接受订单成功通知
    public static let DidAcceptOrderNotification = "DidAcceptOrderNotification"
    //签名成功通知
    public static let DidSignNotification = "DidSignNotification"
    //解析升级信息完成通知
    public static let DidParserUpdateInfoXMLNotification = "DidParserUpdateInfoXMLNotification"
    //收到远程通知
    public static let DidReceiveRemoteNotification = "DidReceiveRemoteNotification"
    //收到选择所属公司通知
    public static let DidReceiveChooseCompanyNotification = "DidReceiveChooseCompanyNotification"
    
    /// - MARK - SegueIdentifier
    public static let ShowRecommendRouteSegueIdentifier = "ShowRecommendRouteSegueIdentifier"
    public static let ShowSignatureSegueIdentifier = "ShowSignatureSegueIdentifier"
    public static let ShowOtherExpenditureSegueIdentifier = "ShowOtherExpenditureSegueIdentifier"
    
    public static let APP_UPDATE_DETAILS = "1. 进行了APP对渝勤业务系统的平台化改造；2. 新增了版本更新说明。"
}
