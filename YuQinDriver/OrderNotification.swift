//
//  OrderNotification.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/4/11.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

public class OrderNotification: NSObject, NSCoding {
    public var orderId: Int?
    public var alertMsg: String?
    
    public override init() {
        super.init()
    }
    //NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(orderId, forKey: "orderId")
        aCoder.encodeObject(alertMsg, forKey: "alertMsg")
    }
    public required init?(coder aDecoder: NSCoder) {
        self.orderId = aDecoder.decodeObjectForKey("orderId") as? Int
        self.alertMsg = aDecoder.decodeObjectForKey("alertMsg") as? String
    }

}