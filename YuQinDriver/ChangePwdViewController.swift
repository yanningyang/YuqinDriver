//
//  ChangePwdViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/23.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire

class ChangePwdViewController: UIViewController {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var oldPwdTextField: UITextField!
    @IBOutlet weak var newPwdTextField: UITextField!
    @IBOutlet weak var new2PwdTextField: UITextField!
    
    @IBOutlet weak var onePxLine1: UIView!
    @IBOutlet weak var onePxLine2: UIView!
    @IBOutlet weak var onePxLine3: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //取消并关闭页面
    @IBAction func cancleAndClosePage(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //保存并修改密码
    @IBAction func saveAndChangePwd(sender: UIButton) {
        
        guard let (userName1, password1) = Utility.sharedInstance.getUserInfo(), userName = userName1, password = password1 where !userName.isEmpty && !password.isEmpty else {
            Utility.sharedInstance.logout(withToast: true)
            return
        }
        
        let oldPwd = oldPwdTextField.text?.md5
        if oldPwd == nil || oldPwd != password {
            UITools.sharedInstance.toast("旧密码不正确")
            UITools.sharedInstance.shakeView(oldPwdTextField)
            return
        }
        
        let newPwd = newPwdTextField.text
        if newPwd == nil || newPwd!.characters.count < 6 {
            UITools.sharedInstance.toast("密码不能少于6位")
            UITools.sharedInstance.shakeView(newPwdTextField)
            return
        }
        
        let newPwd2 = new2PwdTextField.text
        if newPwd2 == nil || newPwd2 != newPwd {
            UITools.sharedInstance.toast("两次输入的新密码不一致")
            UITools.sharedInstance.shakeView(new2PwdTextField)
            return
        }
        
        let urlConnection = UrlConnection(action: "user_changePassword.action")
        let parameters = ["newPwd" : newPwd!]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    //更新本地保存的密码
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.setObject(newPwd?.md5, forKey: "password")
                    userDefault.synchronize()
                    
                    //修改成功提示
                    UITools.sharedInstance.toast("修改密码成功")
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    UITools.sharedInstance.toast("修改密码失败，请重试")
                }
            }
        })
    }

}
