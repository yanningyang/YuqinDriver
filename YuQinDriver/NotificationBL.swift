//
//  NotificationDAO.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/4/11.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

public class NotificationBL {
    public init() {}
    
    public func create(model: OrderNotification) -> Int {
        let dao: NotificationDAO = NotificationDAO.sharedInstance
        dao.create(model)
        return 0
    }
    
    public func create(list list: [OrderNotification]) -> Int {
        let dao: NotificationDAO = NotificationDAO.sharedInstance
        dao.create(list: list)
        return 0
    }
    
    public func remove(model: OrderNotification) -> Int {
        let dao: NotificationDAO = NotificationDAO.sharedInstance
        dao.remove(model)
        return 0
    }
    
    public func removeAll() -> Int {
        let dao: NotificationDAO = NotificationDAO.sharedInstance
        dao.removeAll()
        return 0
    }
    
    public func findAll() -> NSMutableArray {
        let dao: NotificationDAO = NotificationDAO.sharedInstance
        return dao.findAll()
    }
}