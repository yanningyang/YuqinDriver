//
//  LoginViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/12.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import pop
import STPopup

class LoginViewController: UIViewController, MBProgressHUDDelegate {
    
//    let IOS_VERSION = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
    
    let INTERVAL_KEYBOARD: CGFloat = 20
    var keyboardHeight: CGFloat = 250

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var bottomViewTopSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReceiveChooseCompanyNotification(_:)), name: Constant.DidReceiveChooseCompanyNotification, object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTouches(_:)))
        tapGestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 登录
    ///
    /// - parameter sender: sender
    @IBAction func login(sender: UIButton) {
        preLogin()
    }
    
    @IBAction func userNameTextField_DidEndOnExit(sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }
    @IBAction func passwordTextField_DidEndOnExit(sender: UITextField) {
        passwordTextField.resignFirstResponder()
        login(loginBtn)
    }
    
    func handleTouches(sender: UITapGestureRecognizer){
        
        if sender.locationInView(self.view).y < self.view.bounds.height - keyboardHeight {
            userNameTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
    }

    
    /// 键盘将要显示
    ///
    /// - parameter notification: 通知
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo  = notification.userInfo!
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let keyboardHeight = keyBoardBounds.size.height
        let loginBtnFrame = loginBtn.superview?.convertRect(loginBtn.frame, toView: self.view)
        let moveOffset = (loginBtnFrame!.origin.y + loginBtnFrame!.size.height + INTERVAL_KEYBOARD) - (self.view.frame.size.height - keyboardHeight)
    
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = bottomViewTopSpace.constant - moveOffset
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        bottomViewTopSpace.pop_addAnimation(anim, forKey: "up")
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = 0
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        bottomViewTopSpace.pop_addAnimation(anim, forKey: "down")
    }
    
    var userName: String?
    var password: String?
    var companyId: String?
    func preLogin() {
        
        userName = userNameTextField.text
        password = passwordTextField.text
        if userName == nil || userName!.isEmpty {
            UITools.sharedInstance.toast("请输入用户名")
            UITools.sharedInstance.shakeView(userNameTextField)
            return
        }
        if password == nil || password!.isEmpty {
            UITools.sharedInstance.toast("请输入密码")
            UITools.sharedInstance.shakeView(passwordTextField)
            return
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        companyId = userDefaults.stringForKey("companyId")
        if companyId == nil || companyId!.isEmpty {
            loadCompaniesByUsername(userName)
            return
        }
        login()
    }
    
    func login() {
        
        let urlConnection = UrlConnection(action: "user_login.action", addCommonParameter: false)
        let parameters: [String : String] = ["username" : userName!, "pwd" : password!.md5, "companyId" : companyId!]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(self.userName, forKey: "userName")
                    userDefaults.setObject(self.password?.md5, forKey: "password")
                    userDefaults.setObject(self.companyId, forKey: "companyId")
                    userDefaults.setBool(true, forKey: "isLogin")
                    userDefaults.synchronize()
                    
                    let window = UIApplication.sharedApplication().keyWindow!
                    let homeVC: HomeViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
                    window.rootViewController = homeVC
                    window.makeKeyAndVisible()
                    
                    //上传token
                    Utility.sharedInstance.updateDeviceToken()
                } else {
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.removeObjectForKey("companyId")
                    userDefaults.synchronize()
                    UITools.sharedInstance.toast("用户名或密码错误")
                }
            }
            })
    }
    
    //弹出选择所属公司窗口
    var popupVC: STPopupController!
    func popChooseCompanyVC(dataList: [[String : AnyObject]]) {
        let presentedVC = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseCompanyViewController") as! ChooseCompanyViewController
        
        presentedVC.dataList = dataList
        presentedVC.title = "请所属选择单位"
        let width = UIApplication.sharedApplication().keyWindow?.frame.size.width
        presentedVC.contentSizeInPopup = CGSizeMake(width!, 300)
        presentedVC.landscapeContentSizeInPopup = CGSizeMake(400, 200)
        presentedVC.navigationItem.hidesBackButton = true
        
        self.popupVC = STPopupController(rootViewController: presentedVC)
        self.popupVC.style = .FormSheet
        self.popupVC.presentInViewController(self)
    }
    
    func loadCompaniesByUsername(username: String!) {
        
        let urlConnection = UrlConnection(action: "user_companies.action", addCommonParameter: false)
        let parameters: [String : String] = ["username" : username]
        urlConnection.request(urlConnection.assembleUrl(parameters), successCallBack: { value in
            if let dataList = value as? [[String : AnyObject]]  {
                if dataList.count > 1 {
                    self.popChooseCompanyVC(dataList)
                } else if dataList.count == 1 {
                    self.companyId = "\(dataList.first!["id"] as! Int)"
                    self.login()
                } else {
                    self.companyId = "0"
                    self.login()
                }
            }
            }, failureCallBack: { error in
                debugPrint("\(urlConnection.action) error: \(error)")
        })
    }
    
    func didReceiveChooseCompanyNotification(notification: NSNotification) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        companyId = userDefaults.stringForKey("companyId")
        self.login()
    }
}
