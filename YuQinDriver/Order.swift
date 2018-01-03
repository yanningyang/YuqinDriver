//
//  Order.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/26.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import Foundation

public class Order: NSObject, NSCoding {
    
    //收费模式
    static let CHARGE_MODE_DICT = ["MILE" : "按里程计费", "DAY" : "按天计费"]
    public enum ChargeMode: String {
        case MILE =     "按里程计费"
        case DAY =      "按天计费"
    }
    //订单状态
    public enum OrderStatus: String {
        case INQUEUE        = "INQUEUE"       //队列中
        case SCHEDULED      = "SCHEDULED"     //已调度
        case ACCEPTED       = "ACCEPTED"      //队列中
        case CANCELLED      = "CANCELLED"     //已取消
        case BEGIN          = "BEGIN"         //已开始
        case END            = "END"           //已结束
        case GETON          = "GETON"         //已开始
        case GETOFF         = "GETOFF"        //已结束
        case PAYED          = "PAYED"         //已支付
    }
    
    //id
    public var orderId: Int?
    //单位名称
    public var customerOrganization: String?
    //起点
    public var fromAddress: Address?
    //起点longitude
    public var fromLongitude: Double?
    //起点latitude
    public var fromLatitude: Double?
    //下车地点
    public var toAddress: Address?
    //终点longitude
    public var toLongitude: Double?
    //终点latitude
    public var toLatitude: Double?
    //计划开始日期
    public var planBeginDate: NSDate?
    //计划结束日期
    public var planEndDate: NSDate?
    //实际开始日期
    public var actualBeginDate: NSDate?
    //实际结束日期
    public var actualEndDate: NSDate?
    //联系人
    public var customerName: String?
    //联系电话
    public var customerPhoneNum: String?
    //收费模式
    public var chargeMode: ChargeMode?
    //订单状态
    public var orderStatus: OrderStatus?
    //sn
    public var sn: String?
    //目的地
    public var destination: String?
    //客户要求
    public var customerDemo: String?
    //油费
    public var refuelMoney: String?
    //洗车费
    public var washingMoney: String?
    //停车费
    public var parkingFee: String?
    //过路费
    public var toll: String?
    //食宿
    public var roomAndBoardFee: String?
    //其他费用
    public var otherFee: String?
    
    public override init() {
        super.init()
    }
    
    //NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(orderId, forKey: "orderId")
        aCoder.encodeObject(customerOrganization, forKey: "customerOrganization")
        aCoder.encodeObject(fromAddress, forKey: "fromAddress")
        aCoder.encodeObject(fromLatitude, forKey: "fromLatitude")
        aCoder.encodeObject(fromLongitude, forKey: "fromLongitude")
        aCoder.encodeObject(toAddress, forKey: "toAddress")
        aCoder.encodeObject(toLatitude, forKey: "toLatitude")
        aCoder.encodeObject(toLongitude, forKey: "toLongitude")
        aCoder.encodeObject(planBeginDate, forKey: "planBeginDate")
        aCoder.encodeObject(planEndDate, forKey: "planEndDate")
        aCoder.encodeObject(actualBeginDate, forKey: "actualBeginDate")
        aCoder.encodeObject(actualEndDate, forKey: "actualEndDate")
        aCoder.encodeObject(customerName, forKey: "customerName")
        aCoder.encodeObject(customerPhoneNum, forKey: "customerPhoneNum")
        aCoder.encodeObject(chargeMode?.rawValue, forKey: "chargeMode")
        aCoder.encodeObject(orderStatus?.rawValue, forKey: "orderStatus")
        aCoder.encodeObject(sn, forKey: "sn")
        aCoder.encodeObject(destination, forKey: "destination")
        aCoder.encodeObject(customerDemo, forKey: "customerDemo")
        aCoder.encodeObject(refuelMoney, forKey: "refuelMoney")
        aCoder.encodeObject(washingMoney, forKey: "washingMoney")
        aCoder.encodeObject(parkingFee, forKey: "parkingFee")
        aCoder.encodeObject(toll, forKey: "toll")
        aCoder.encodeObject(roomAndBoardFee, forKey: "roomAndBoardFee")
        aCoder.encodeObject(otherFee, forKey: "otherFee")
    }
    public required init?(coder aDecoder: NSCoder) {
        self.orderId = aDecoder.decodeObjectForKey("orderId") as? Int
        self.customerOrganization = aDecoder.decodeObjectForKey("customerOrganization") as? String
        self.fromAddress = aDecoder.decodeObjectForKey("fromAddress") as? Address
        self.fromLatitude = aDecoder.decodeObjectForKey("fromLatitude") as? Double
        self.fromLongitude = aDecoder.decodeObjectForKey("fromLongitude") as? Double
        self.toAddress = aDecoder.decodeObjectForKey("toAddress") as? Address
        self.toLatitude = aDecoder.decodeObjectForKey("toLatitude") as? Double
        self.toLongitude = aDecoder.decodeObjectForKey("toLongitude") as? Double
        self.planBeginDate = aDecoder.decodeObjectForKey("planBeginDate") as? NSDate
        self.planEndDate = aDecoder.decodeObjectForKey("planEndDate") as? NSDate
        self.actualBeginDate = aDecoder.decodeObjectForKey("actualBeginDate") as? NSDate
        self.actualEndDate = aDecoder.decodeObjectForKey("actualEndDate") as? NSDate
        self.customerName = aDecoder.decodeObjectForKey("customerName") as? String
        self.customerPhoneNum = aDecoder.decodeObjectForKey("customerPhoneNum") as? String
        self.chargeMode = ChargeMode(rawValue: aDecoder.decodeObjectForKey("chargeMode") as! String)
        self.orderStatus = OrderStatus(rawValue: aDecoder.decodeObjectForKey("orderStatus") as! String)
        self.sn = aDecoder.decodeObjectForKey("sn") as? String
        self.destination = aDecoder.decodeObjectForKey("destination") as? String
        self.customerDemo = aDecoder.decodeObjectForKey("customerDemo") as? String
        self.refuelMoney = aDecoder.decodeObjectForKey("refuelMoney") as? String
        self.washingMoney = aDecoder.decodeObjectForKey("washingMoney") as? String
        self.parkingFee = aDecoder.decodeObjectForKey("parkingFee") as? String
        self.toll = aDecoder.decodeObjectForKey("toll") as? String
        self.roomAndBoardFee = aDecoder.decodeObjectForKey("roomAndBoardFee") as? String
        self.otherFee = aDecoder.decodeObjectForKey("otherFee") as? String
    }
}

//地址
public class Address: NSObject, NSCoding {
    public var createTime: NSDate?
    public var lastUpdateTime: NSDate?
    public var briefDescription: String?
    public var detail: String?
    public var id: Int?
    public var location: Location?
    
    override init() {
        super.init()
    }
    
    //NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(createTime, forKey: "createTime")
        aCoder.encodeObject(lastUpdateTime, forKey: "lastUpdateTime")
        aCoder.encodeObject(briefDescription, forKey: "briefDescription")
        aCoder.encodeObject(detail, forKey: "detail")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(location, forKey: "location")
    }
    public required init?(coder aDecoder: NSCoder) {
        self.createTime = aDecoder.decodeObjectForKey("createTime") as? NSDate
        self.lastUpdateTime = aDecoder.decodeObjectForKey("lastUpdateTime") as? NSDate
        self.briefDescription = aDecoder.decodeObjectForKey("briefDescription") as? String
        self.detail = aDecoder.decodeObjectForKey("detail") as? String
        self.id = aDecoder.decodeObjectForKey("id") as? Int
        self.location = aDecoder.decodeObjectForKey("location") as? Location
    }
}

//位置
public class Location: NSObject, NSCoding {
    public var createTime: NSDate?
    public var lastUpdateTime: NSDate?
    public var id: Int?
    public var latitude: Double?
    public var longitude: Double?
    
    override init() {
        super.init()
    }
    
    //NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(createTime, forKey: "createTime")
        aCoder.encodeObject(lastUpdateTime, forKey: "lastUpdateTime")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longitude, forKey: "longitude")
    }
    public required init?(coder aDecoder: NSCoder) {
        self.createTime = aDecoder.decodeObjectForKey("createTime") as? NSDate
        self.lastUpdateTime = aDecoder.decodeObjectForKey("lastUpdateTime") as? NSDate
        self.id = aDecoder.decodeObjectForKey("id") as? Int
        self.latitude = aDecoder.decodeObjectForKey("latitude") as? Double
        self.longitude = aDecoder.decodeObjectForKey("longitude") as? Double
    }
}
