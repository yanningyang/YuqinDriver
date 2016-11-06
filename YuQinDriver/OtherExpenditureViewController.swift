//
//  OtherExpenditureViewController.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/9/3.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import pop

class OtherExpenditureViewController: UIViewController {
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var backgroundViewTopSpace: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat = 250
    
    var doingOrder: Order!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 键盘事件通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTouches(_:)))
        tapGestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// - MARK - handle Gesture
    func handleTouches(sender: UITapGestureRecognizer){
        
        if sender.locationInView(self.view).y < self.view.bounds.height - keyboardHeight {
            textField1.resignFirstResponder()
            textField2.resignFirstResponder()
            textField3.resignFirstResponder()
            textField4.resignFirstResponder()
            textField5.resignFirstResponder()
            textField6.resignFirstResponder()
        }
    }

    /// - MARK - Actions
    @IBAction func submitBtnAction(sender: UIButton) {
        let alertController = UIAlertController(title: "整个订单结束，将车停到车库后，点击“结束”。你确定吗？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { alertAction in
            
            self.endOrder()
        }
        let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /// - MARK - handle KeyBoardEvent
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !(textField5.isFirstResponder() || textField6.isFirstResponder()) {
            return
        }
        
        let userInfo  = notification.userInfo!
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let keyboardHeight = keyBoardBounds.size.height
        let loginBtnFrame = submitBtn.superview?.convertRect(submitBtn.frame, toView: self.view)
        let moveOffset = (loginBtnFrame!.origin.y) - (self.view.frame.size.height - keyboardHeight)
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = backgroundViewTopSpace.constant - moveOffset
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        backgroundViewTopSpace.pop_addAnimation(anim, forKey: "up")
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let userInfo  = notification.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let anim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        anim.toValue = 0
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        backgroundViewTopSpace.pop_addAnimation(anim, forKey: "down")
    }
    
    /// - MARK - Utilitys
    
    //结束订单
    func endOrder() {
        
        let text1 = textField1.text != "" ? textField1.text! : "0.0"
        let text2 = textField2.text != "" ? textField2.text! : "0.0"
        let text3 = textField3.text != "" ? textField3.text! : "0.0"
        let text4 = textField4.text != "" ? textField4.text! : "0.0"
        let text5 = textField5.text != "" ? textField5.text! : "0.0"
        let text6 = textField6.text != "" ? textField6.text! : "0.0"
        
        let urlConnection = UrlConnection(action: "order_endOrder.action")
        let parameters = ["orderId"         : String(doingOrder!.orderId!),
                          "refuelMoney"     : text1,
                          "washingFee"      : text2,
                          "parkingFee"      : text3,
                          "toll"            : text4,
                          "roomAndBoardFee" : text5,
                          "otherFee"        : text6]
        urlConnection.request(urlConnection.assembleUrl(parameters), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"] as? Bool  {
                if status {
                    
                    //发送通知
                    NSNotificationCenter.defaultCenter().postNotificationName(Constant.OrderEndNotification, object: nil)
                    // 关闭界面
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    
                    UITools.sharedInstance.toast("结束订单失败，请重试")
                }
            }
        })
        
        guard let (userName1, password1) = Utility.sharedInstance.getUserInfo(), userName = userName1, password = password1 where !userName.isEmpty && !password.isEmpty else {
            Utility.sharedInstance.logout(withToast: true)
            return
        }
    }
}
