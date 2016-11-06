//
//  ChangeContactViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/23.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class ChangeContactViewController: UIViewController {

    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var oldContactTextField: UITextField!
    @IBOutlet weak var newContactTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var getVerificationCodeBtn: UIButton!
    @IBOutlet weak var onePxLine1: UIView!
    @IBOutlet weak var onePxLine2: UIView!
    @IBOutlet weak var onePxLine3: UIView!
    
    var changeContactHUD: MBProgressHUD?
    
    var timer: NSTimer?
    var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //取消并关闭页面
    @IBAction func cancleAndClosePage(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //保存并修改联系方式
    @IBAction func saveAndChangeContact(sender: UIButton) {
        verifyVerificationCode()
    }
    //获取验证码
    @IBAction func getVerificationCode(sender: UIButton) {
        
        let oldPhoneNum = oldContactTextField.text
        if oldPhoneNum == nil || oldPhoneNum?.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            UITools.sharedInstance.shakeView(oldContactTextField)
            return
        }
        
        let urlConnection = UrlConnection(action: "user_getSMSCode.action", addCommonParameter: false)
        let parameters = ["phoneNumber" : oldPhoneNum!]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.getVerificationCodeBtn.enabled = false
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
                } else {
                    
                    UITools.sharedInstance.toast("获取验证码失败，请重试")
                }
            }
        })
    }
    
    //倒计时
    func counter() {
        if count == 0 {
            count = 60
            timer?.invalidate()
            getVerificationCodeBtn.enabled = true
            getVerificationCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
        } else {
            
            getVerificationCodeBtn.titleLabel?.text = "\(count)秒"
            getVerificationCodeBtn.setTitle("\(count)秒", forState: UIControlState.Normal)
            count -= 1
        }
    }
    
    //验证验证码
    func verifyVerificationCode() {
        
        let oldPhoneNum = oldContactTextField.text
        if oldPhoneNum == nil || oldPhoneNum?.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            UITools.sharedInstance.shakeView(oldContactTextField)
            return
        }
        let newPhoneNum = newContactTextField.text
        if newPhoneNum == nil || newPhoneNum!.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            UITools.sharedInstance.shakeView(newContactTextField)
            return
        }
        let SMSCode = verificationCodeTextField.text
        if SMSCode == nil || SMSCode!.isEmpty {
            UITools.sharedInstance.toast("请输入验证码")
            UITools.sharedInstance.shakeView(verificationCodeTextField)
            return
        }
        
        //等待动画
        changeContactHUD = UITools.sharedInstance.showLoadingAnimation()
        
        let urlConnection = UrlConnection(action: "user_verifiySMSCode.action", addCommonParameter: false)
        let parameters = ["phoneNumber" : oldContactTextField.text!, "userCode" : SMSCode!]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: false, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    self.changePhoneNum()
                } else {
                    
                    //取消等待动画
                    self.changeContactHUD!.hide(true)
                    
                    UITools.sharedInstance.toast("验证码错误")
                }
            }
        })
    }
    
    //修改电话号码
    func changePhoneNum() {
        
        let urlConnection = UrlConnection(action: "user_changePhoneNumber.action")
        let parameters = ["phoneNumber" : newContactTextField.text!]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: false, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    //取消等待动画
                    self.changeContactHUD!.hide(true)
                    UITools.sharedInstance.toast("修改成功")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    UITools.sharedInstance.toast("修改失败")
                }
            }
        })
    }
}
