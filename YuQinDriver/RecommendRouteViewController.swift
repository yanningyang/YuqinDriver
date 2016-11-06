//
//  RecommendRouteViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/2/27.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//
/*
import UIKit

class RecommendRouteViewController: UIViewController, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate {
    
    class RouteAnnotation: BMKPointAnnotation {
        var type: Int32?//<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
        var degree: Int32?
    }
    
    var doingOrder: Order!
    
    var _mapView: BMKMapView?
    var _locService: BMKLocationService?
    var _routesearch: BMKRouteSearch?

    override func viewDidLoad() {
        super.viewDidLoad()

        _mapView = BMKMapView()
        _mapView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_mapView!)
        
        let views = ["_mapView" : _mapView!] as [String : AnyObject]
        let constraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[_mapView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[_mapView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        _mapView?.superview?.addConstraints(constraints1)
        _mapView?.superview?.addConstraints(constraints2)
        
//        //定位
//        _locService = BMKLocationService.init()
//        _locService?.delegate = self
//        
//        NSLog("进入普通定位态");
//        _locService?.startUserLocationService()
//        
//        _mapView?.showsUserLocation = false
//        _mapView?.userTrackingMode = BMKUserTrackingModeNone
//        _mapView?.showsUserLocation = true
        
        //设置地图中心点为重庆市
        _mapView?.centerCoordinate = CLLocationCoordinate2DMake(29.556169, 106.554003)
        
        //路线搜索
        _routesearch = BMKRouteSearch()
        
        //搜索路线
        driveRouteSearch()
    }
    
    /**
     *在地图View将要启动定位时，会调用此函数
     */
    func willStartLocatingUser() {
        NSLog("start locate")
    }
    
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        //        NSLog("heading is %@", userLocation.heading)
    }
    
    /**
     *用户位置更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        _mapView?.updateLocationData(userLocation)
        
        NSLog("didUpdateBMKUserLocation 纬度: %f, 经度: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)
    }
    
    /**
     *在地图View停止定位后，会调用此函数
     */
    func didStopLocatingUser() {
        NSLog("stop locate")
    }
    
    /**
     *定位失败后，会调用此函数
     *@param mapView 地图View
     *@param error 错误号，参考CLError.h中定义的错误号
     */
    func didFailToLocateUserWithError(error: NSError!) {
        NSLog("location error")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _mapView?.viewWillAppear()
        _mapView?.delegate = self
        _routesearch?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView?.viewWillDisappear()
        _mapView?.delegate = nil
        _routesearch?.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     *驾驶路线搜索
     */
    func driveRouteSearch() {
        
        //初始化起始节点
        let start = BMKPlanNode()
        //指定起点经纬度
        if let fromLatitude = doingOrder.fromAddress?.location?.latitude, fromLongitude = doingOrder.fromAddress?.location?.longitude {
            
            var coor1 = CLLocationCoordinate2D()
            coor1.latitude = fromLatitude
            coor1.longitude = fromLongitude
            start.pt = coor1
        }
        //指定起点名称
        start.name = doingOrder.fromAddress?.briefDescription
        //        start.cityName = "重庆市"
        
        //初始化终点节点
        let end = BMKPlanNode()
        //指定终点经纬度
        if let toLatitude = doingOrder.toAddress?.location?.latitude, toLongitude = doingOrder.toAddress?.location?.longitude {
            
            var coor2 = CLLocationCoordinate2D()
            coor2.latitude = toLatitude
            coor2.longitude = toLongitude
            end.pt = coor2
        }
        //指定终点名称
        end.name = doingOrder.toAddress?.briefDescription
        //        end.cityName = "重庆市"
        
        if let startName = start.name, endName = end.name where !startName.isEmpty && !endName.isEmpty {
            
            let drivingRouteSearchOption = BMKDrivingRoutePlanOption()
            drivingRouteSearchOption.from = start
            drivingRouteSearchOption.to = end
            let flag = (_routesearch?.drivingSearch(drivingRouteSearchOption))! as Bool
            if flag {
                NSLog("驾驶路线检索发送成功")
            } else {
                NSLog("驾驶路线检索发送失败")
            }
        }
    }
    
    func onGetDrivingRouteResult(searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        var array: [AnyObject] = NSArray(array: (_mapView?.annotations)!) as [AnyObject]
        _mapView?.removeAnnotations(array)
        array = NSArray(array: (_mapView?.overlays)!) as [AnyObject]
        _mapView?.removeOverlays(array)
        
        if(error == BMK_SEARCH_NO_ERROR) {
            let plan = result.routes[0] as! BMKDrivingRouteLine
            //计算路线方案中的路段数目
            let size = plan.steps.count
            var planPointCounts: Int32 = 0;
            for i in 0 ..< size {
                let drivingStep = plan.steps[i] as! BMKDrivingStep
                if i==0 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.starting.location
                    item.title = "起点"
                    item.type = 0
                    _mapView?.addAnnotation(item)//添加起点标注
                } else if i == size-1 {
                    let item = RouteAnnotation()
                    item.coordinate = plan.terminal.location
                    item.title = "终点"
                    item.type = 1
                    _mapView?.addAnnotation(item)//添加终点标注
                }
                let item = RouteAnnotation()
                item.coordinate = drivingStep.entrace.location
                item.title = drivingStep.entraceInstruction
                item.degree = drivingStep.direction * 30
                item.type = 4
                _mapView?.addAnnotation(item)
                
                //轨迹点总数累计
                planPointCounts += drivingStep.pointsCount
            }
            
            //添加途经点
            if (plan.wayPoints != nil) {
                for tempNode: BMKPlanNode in plan.wayPoints as! [BMKPlanNode] {
                    let item: RouteAnnotation = RouteAnnotation()
                    item.coordinate = tempNode.pt
                    item.type = 5
                    item.title = tempNode.name
                    _mapView?.addAnnotation(item)
                }
            }
            
            //轨迹点
            var temppoints = [BMKMapPoint]()
            var i = 0
            for drivingStep: BMKDrivingStep in plan.steps as! [BMKDrivingStep]{
                for k in 0..<Int(drivingStep.pointsCount) {
                    var item: BMKMapPoint = BMKMapPoint()
                    item.x = drivingStep.points[k].x
                    item.y = drivingStep.points[k].y
                    temppoints.append(item)
                    i += 1
                }
            }
            
            //通过points构建BMKPolyline
            let polyLine: BMKPolyline = BMKPolyline(points: &temppoints, count: UInt(planPointCounts))
            _mapView?.addOverlay(polyLine)
            self.mapViewFitPolyLine(polyLine)
        }
    }
    
    func getRouteAnnotationView(mapview: BMKMapView, routeAnnotation: RouteAnnotation) ->BMKAnnotationView {
        var view: BMKAnnotationView?
        switch (Int(routeAnnotation.type!)) {
        case 0:
            view = mapview.dequeueReusableAnnotationViewWithIdentifier("start_node")
            if view == nil {
                view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: "start_node")
                let imgPath = Utility.sharedInstance.getBaiduMapBundlePath("images/icon_nav_start.png")
                if imgPath != nil {
                    view?.image = UIImage(contentsOfFile: imgPath!)
                }
                view?.centerOffset = CGPointMake(0, -((view?.frame.size.height)! * 0.5))
                view?.canShowCallout = true
            }
            view?.annotation = routeAnnotation
            
            break
        case 1:
            view = mapview.dequeueReusableAnnotationViewWithIdentifier("end_node")
            if view == nil {
                view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: "end_node")
                let imgPath = Utility.sharedInstance.getBaiduMapBundlePath("images/icon_nav_end.png")
                if imgPath != nil {
                    view?.image = UIImage(contentsOfFile: imgPath!)
                }
                view?.image = UIImage(contentsOfFile: imgPath!)
                view?.centerOffset = CGPointMake(0, -((view?.frame.size.height)! * 0.5))
                view?.canShowCallout = true
            }
            view?.annotation = routeAnnotation
            
            break
        case 4:
            view = mapview.dequeueReusableAnnotationViewWithIdentifier("route_node")
            if view == nil {
                view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: "route_node")
                view?.canShowCallout = true
            } else {
                view?.setNeedsDisplay()
            }
            //            let image = UIImage(contentsOfFile: Utility.sharedInstance.getBaiduMapBundlePath("images/icon_direction.png"))
            //            view?.image = image.imageRotatedByDegrees(routeAnnotation.degree)
            //            view?.image = image
            view?.annotation = routeAnnotation
            
            break
        case 5:
            view = mapview.dequeueReusableAnnotationViewWithIdentifier("waypoint_node")
            if view == nil {
                view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: "waypoint_node")
                view?.canShowCallout = true
            } else {
                view?.setNeedsDisplay()
            }
            //            let image = UIImage(contentsOfFile: Utility.sharedInstance.getBaiduMapBundlePath("images/icon_nav_waypoint.png"))
            //            view?.image = image.imageRotatedByDegrees(routeAnnotation.degree)
            //            view?.image = image
            view?.annotation = routeAnnotation
            
            break
        default:
            break
        }
        
        return view!
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation is RouteAnnotation {
            return self.getRouteAnnotationView(mapView, routeAnnotation: annotation as! RouteAnnotation)
        }
        return nil
    }
    
    func mapView(mapView: BMKMapView!, viewForOverlay overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay is BMKPolyline {
            let polylinView: BMKPolylineView = BMKPolylineView(overlay: overlay)
            polylinView.fillColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
            polylinView.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
            polylinView.lineWidth = 6.0
            return polylinView
        }
        return nil
    }
    
    //根据polyline设置地图范围
    func mapViewFitPolyLine(polyLine: BMKPolyline) {
        var ltX: Double
        var ltY: Double
        var rbX: Double
        var rbY: Double
        if polyLine.pointCount < 1 {
            return
        }
        let pt: BMKMapPoint = polyLine.points[0]
        ltX = pt.x
        ltY = pt.y
        rbX = pt.x
        rbY = pt.y
        for i in 0..<Int(polyLine.pointCount) {
            let pt: BMKMapPoint = polyLine.points[i]
            if pt.x < ltX {
                ltX = pt.x
            }
            if pt.x > rbX {
                rbX = pt.x
            }
            if pt.y > ltY {
                ltY = pt.y
            }
            if pt.y < rbY {
                rbY = pt.y
            }
        }
//        for var i = 1; UInt(i) < polyLine.pointCount; i += 1 {
//            let pt: BMKMapPoint = polyLine.points[i]
//            if pt.x < ltX {
//                ltX = pt.x
//            }
//            if pt.x > rbX {
//                rbX = pt.x
//            }
//            if pt.y > ltY {
//                ltY = pt.y
//            }
//            if pt.y < rbY {
//                rbY = pt.y
//            }
//        }
        var rect: BMKMapRect = BMKMapRect()
        rect.origin = BMKMapPointMake(ltX, ltY)
        rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY)
        _mapView?.visibleMapRect = rect
        _mapView?.zoomLevel = (_mapView?.zoomLevel)! - 0.3
    }

}
*/
