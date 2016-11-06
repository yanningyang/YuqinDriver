//
//  AboutmeViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire

class AboutmeViewController: UITableViewController {
    
    @IBOutlet weak var contactPnoneNumLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
        
        //设置tableView背景色
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clearColor()
        
        if let (userName1, _) = Utility.sharedInstance.getUserInfo(), userName = userName1 where !userName.isEmpty {
            
            self.navigationItem.title = "我（\(userName)）"
        }
        
        UITools.sharedInstance.addBorderTo(logoutBtn, color: UIColor.redColor().CGColor, cornerRadius: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            
            Utility.sharedInstance.loadAndParseUpdateInfoXML(2)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            Utility.sharedInstance.logout(withToast: false)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    @IBAction func logoutBtnAction(sender: UIButton) {
        
        let alertController = UIAlertController(title: "确定退出？", message: "", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "取消", style: .Default, handler: nil)
        let ok = UIAlertAction(title: "确定", style: .Default) { alertAction in
            Utility.sharedInstance.logout(withToast: false)
        }
        alertController.addAction(cancel)
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
