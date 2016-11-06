//
//  NotificationDAO.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/4/11.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

public class NotificationDAO {
    
    static let sharedInstance = NotificationDAO()
    //私有化init方法，保证单例
    private init(){
        createEditableCopyOfDatabaseIfNeeded()
    }
    
    //保存数据文件名
    let DB_FILE_NAME = "Notification.archive"
    let ARCHIVE_KEY = "Notification"
    
    //保存数据列表
    var listData: NSMutableArray!
    
    //写数据库队列（串行执行）
    let SERIAL_QUEUE_WRITE_DB = dispatch_queue_create("com.yuqin.car.writeNotification", DISPATCH_QUEUE_SERIAL)
    
    //插入订单
    public func create(model: OrderNotification) ->Int {
        
        dispatch_sync(SERIAL_QUEUE_WRITE_DB) {
            
            let path = self.applicationDocumentsDirectoryFile()
            let array = self.findAll()
            array.addObject(model)
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(array, forKey: self.ARCHIVE_KEY)
            archiver.finishEncoding()
            
            data.writeToFile(path, atomically: true)
        }
        
        return 0
    }
    
    //批量插入订单
    public func create(list list: [OrderNotification]) ->Int {
        
        dispatch_sync(SERIAL_QUEUE_WRITE_DB) {
            
            let path = self.applicationDocumentsDirectoryFile()
            let array = self.findAll()
            
            for item in list {
                
                array.addObject(item)
            }
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(array, forKey: self.ARCHIVE_KEY)
            archiver.finishEncoding()
            
            data.writeToFile(path, atomically: true)
        }
        
        return 0
    }
    
    //删除订单
    public func remove(model: OrderNotification) ->Int {
        
        dispatch_sync(SERIAL_QUEUE_WRITE_DB) {
            
            let path = self.applicationDocumentsDirectoryFile()
            let array = self.findAll()
            
            for item in array {
                
                let order = item as! Order
                
                if order.orderId == model.orderId {
                    
                    array.removeObject(order)
                    
                    let data = NSMutableData()
                    let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
                    archiver.encodeObject(array, forKey: self.ARCHIVE_KEY)
                    archiver.finishEncoding()
                    
                    data.writeToFile(path, atomically: true)
                    break
                }
            }
        }
        
        return 0
    }
    
    //删除所有订单
    public func removeAll() ->Int {
        
        dispatch_sync(SERIAL_QUEUE_WRITE_DB) {
            
            let path = self.applicationDocumentsDirectoryFile()
            let array = self.findAll()
            
            array.removeAllObjects()
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(array, forKey: self.ARCHIVE_KEY)
            archiver.finishEncoding()
            
            data.writeToFile(path, atomically: true)
        }
        
        return 0
    }
    
    //查询所有
    public func findAll() ->NSMutableArray {
        
        let path = self.applicationDocumentsDirectoryFile()
        var listData = NSMutableArray()
        
        let data = NSData(contentsOfFile: path)!
        
        if data.length > 0 {
            let archiver = NSKeyedUnarchiver(forReadingWithData: data)
            listData = archiver.decodeObjectForKey(ARCHIVE_KEY) as! NSMutableArray
            archiver.finishDecoding()
        }
        
        return listData
    }
    
    //按主键查询
    public func findById(orderId: Int) -> OrderNotification? {
        
        let path = self.applicationDocumentsDirectoryFile()
        var listData = NSMutableArray()
        
        let data = NSData(contentsOfFile: path)!
        
        if data.length > 0 {
            let archiver = NSKeyedUnarchiver(forReadingWithData: data)
            listData = archiver.decodeObjectForKey(ARCHIVE_KEY) as! NSMutableArray
            archiver.finishDecoding()
            
            for item in listData {
                let order = item as! OrderNotification
                
                if order.orderId == orderId {
                    return order
                }
            }
        }
        
        return nil
    }
    
    func createEditableCopyOfDatabaseIfNeeded() {
        let fileManager = NSFileManager.defaultManager()
        let writableDBPath = self.applicationDocumentsDirectoryFile()
        let dbexits = fileManager.fileExistsAtPath(writableDBPath)
        if (dbexits != true) {
            let array = NSMutableArray()
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(array, forKey: ARCHIVE_KEY)
            archiver.finishEncoding()
            
            data.writeToFile(writableDBPath, atomically: true)
        }
    }
    
    func applicationDocumentsDirectoryFile() ->String {
        let documentDirectoty: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = documentDirectoty[0].stringByAppendingPathComponent(DB_FILE_NAME) as String
        return path
    }
}