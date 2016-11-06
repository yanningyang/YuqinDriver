//
//  OrderBL.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/27.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import Foundation

public class DoingOrderBL {
    
    public init() {
        
    }
    
    //插入Order方法
    public func create(model: Order) -> Int {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        dao.create(model)
        return 0
    }
    
    //批量插入Order方法
    public func create(orderList list: [Order]) -> Int {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        dao.create(orderList: list)
        return 0
    }
    
    //删除Order方法
    public func remove(model: Order) -> Int {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        dao.remove(model)
        return 0
    }
    
    //删除全部Order方法
    public func removeAll() -> Int {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        dao.removeAll()
        return 0
    }
    
    //查询所有数据方法
    public func findAll() -> NSMutableArray {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        return dao.findAll()
    }
    
    //查询时间最早订单
    public func findEarliestOrder() -> Order? {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        let allOrder = dao.findAll()
        if allOrder.count > 0 {
            return allOrder.objectAtIndex(0) as? Order
        }
        return nil
    }
    
    //修改订单状态
    public func modifyOrderStatusById(orderId: Int, status: Order.OrderStatus) -> Int {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        dao.modifyOrderStatusById(orderId, status: status)
        return 0
    }
    
    //获取订单状态
    public func getOrderStatusById(orderId: Int) ->Order.OrderStatus? {
        let dao: DoingOrderDAO = DoingOrderDAO.sharedInstance
        let status = dao.findById(orderId)?.orderStatus
        return status
    }
    
}