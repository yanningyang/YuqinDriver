//
//  HomeViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.viewControllers![1].tabBarItem.badgeValue = String(listData.count)
        
        let tabbarViewControllers = self.viewControllers
        for item in tabbarViewControllers! {
            item.tabBarController?.tabBar.tintColor = UIColor(red: 34.0/255.0, green: 189.0/255.0, blue: 246.0/255.0, alpha: 1)
            
            let item1 = item as! UINavigationController
            item1.navigationBar.barTintColor = UIColor(red: 34.0/255.0, green: 189.0/255.0, blue: 246.0/255.0, alpha: 1)
            item1.navigationBar.tintColor = UIColor.whiteColor()
            let navigationTitleAttribute: NSDictionary = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
            item1.navigationBar.titleTextAttributes = navigationTitleAttribute as? [String : AnyObject]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //检查更新通知
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUpdateTip(_:)), name: Constant.DidParserUpdateInfoXMLNotification, object: nil)
//        
//        //检查更新
//        Utility.sharedInstance.loadAndParseUpdateInfoXML(1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更新
    func showUpdateTip(notification: NSNotification) {
        
//        //判断是否已登录
//        let flag = NSUserDefaults.standardUserDefaults().boolForKey("isAlertUpdate")
//        if !flag {
//            Utility.sharedInstance.showUpdateTip(notification)
//        }
    }

}
