//
//  SignatureViewController.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/29.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit
import Alamofire
import PPSSignatureView

class SignatureViewController: UIViewController {

    @IBOutlet weak var delSignature: UIButton!
    @IBOutlet weak var signatureViewUnderlay: UIView!
    @IBOutlet weak var saveAndUploadImage: UIButton!
    
    @IBOutlet weak var getOnMileLabel: UILabel!
    @IBOutlet weak var getOffMileLabel: UILabel!
    @IBOutlet weak var serviceMileLabel: UILabel!
    
    var signatureView: PPSSignatureView!
    
    var doingOrder: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signatureView = PPSSignatureView(frame: signatureViewUnderlay.bounds, context: EAGLContext(API: EAGLRenderingAPI.OpenGLES2))
        signatureView.translatesAutoresizingMaskIntoConstraints = false
        signatureViewUnderlay.addSubview(signatureView)
     
        let views = ["signatureView" : signatureView!] as [String : AnyObject]
        let constraints1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[signatureView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        let constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[signatureView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views)
        signatureView?.superview?.addConstraints(constraints1)
        signatureView?.superview?.addConstraints(constraints2)
        
        saveAndUploadImage.addTarget(self, action: #selector(onClickSaveAndUploadImage), forControlEvents: .TouchUpInside)
        
        //取消左边缘右滑时，当前ViewController pop出栈
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        //获取里程信息
        getMileInfo()
    }
    
    //保存签名团片到本地
    func saveSignatureToLocal() ->String? {
        
        if !signatureView.hasSignature {
            UITools.sharedInstance.toast("请签名后再上传")
            return nil
        }
        
        if let orderId = doingOrder.orderId {
            
            let path = "\(orderId).jpg"
            let jpgPath: String = NSTemporaryDirectory().stringByAppendingString(path)
            
            //            UIImagePNGRepresentation(signatureView.signatureImage)?.writeToFile(pngPath as String, atomically: true)
            if let data = UIImageJPEGRepresentation(signatureView.signatureImage, 1.0) where signatureView.signatureImage != nil && data.writeToFile(jpgPath as String, atomically: true){
                
                NSLog("订单: \(orderId) 保存签名到本地成功")
                return jpgPath
            }
            
            NSLog("订单: \(orderId) 保存签名到本地失败")
        }
        
        return nil
    }

    @IBAction func delSignature(sender: UIButton) {
        signatureView.erase()
    }
    
    override func viewWillDisappear(animated: Bool) {
        signatureView.erase()
    }
    
    // 获取里程
    func getMileInfo() {
        
        guard let (userName1, password1) = Utility.sharedInstance.getUserInfo(), userName = userName1, password = password1 where !userName.isEmpty && !password.isEmpty else {
            Utility.sharedInstance.logout(withToast: true)
            return
        }
        
        let parameters = ["username" : userName, "pwd" : password, "orderId" : String(doingOrder.orderId!)]
        let url = Constant.HOST_PATH + "/order_getMileInfo.action"
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                print("get mile info request: \(response.request)")
                print("get mile info result: \(response.result)")
                
                switch (response.result) {
                case .Success(let value):
                    
                    print("get mile info result value: \(value)")
                    
                    guard let data = value as? NSDictionary else {
                        print("获取里程信息失败")
                        return
                    }
                    if let status = data["status"] as? String {
                        if status == UNAUTHORIZED {
                            print("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            print("\(url) 参数错误")
                        }
                        
                    } else {
                    
//                        if let getonMile = data["getonMile"] as? Int {
//                            self.getOnMileLabel.text = "上车里程：\(getonMile) km"
//                        }
//                        if let getoffMile = data["getoffMile"] as? Int {
//                            self.getOffMileLabel.text = "下车里程：\(getoffMile) km"
//                        }
                        if let serviceMile = data["serviceMile"] as? Int {
                            self.serviceMileLabel.text = "服务里程：\(serviceMile) km"
                        }

                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
                
        }
    }
    
    // 上传签名
    func onClickSaveAndUploadImage() {
        
        let path = saveSignatureToLocal()
        if path == nil {
            return
        }
        
        let (userName, password, companyId) = Utility.sharedInstance.getUserInfo1()
        let orderId = doingOrder.orderId
        guard orderId != nil && userName != nil && password != nil && companyId != nil && !userName!.isEmpty && !password!.isEmpty && !companyId!.isEmpty else {
            Utility.sharedInstance.logout(withToast: true)
            return
        }
        
        //显示等待动画
        let HUD = UITools.sharedInstance.showLoadingAnimation()
        
        let url = Constant.HOST_PATH + "/signature_upload.action"
        
        Alamofire.upload(
            Method.POST,
            url,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: path!), name: "upload")
                multipartFormData.appendBodyPart(data: "".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "title")
                multipartFormData.appendBodyPart(data: userName!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "username")
                multipartFormData.appendBodyPart(data: password!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "pwd")
                multipartFormData.appendBodyPart(data: companyId!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "companyId")
                multipartFormData.appendBodyPart(data: "\(orderId!)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: "orderId")
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        print("signature_upload.action Request: ", response.request)
                        print("signature_upload.action Response: ", response.response)
                        
                        //取消等待动画
                        HUD.hide(true)
                        
                        switch response.result {
                        case .Success(let value):
                            print("Signature Upload Result: ", value)
                            if value["status"] == UNAUTHORIZED {
                                NSLog("\(url) 无权限")
                            } else if value["status"] == BAD_PARAMETER {
                                NSLog("\(url) 参数错误")
                                
                            } else if value["status"] == 1 {
                                
                                //修改本地数据
                                let userDefault = NSUserDefaults.standardUserDefaults()
                                userDefault.setBool(true, forKey: "\(orderId)")
                                userDefault.synchronize()
                                //上传成功提示
                                UITools.sharedInstance.toast("上传签名成功")
                                //发送签名上传成功通知
                                NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidSignNotification, object: nil)
                                //关闭签名界面
                                self.navigationController?.popViewControllerAnimated(true)
                            } else if value["status"] == 0 {
                                
                                UITools.sharedInstance.toast("上传签名失败")
                            }
                            
                        case .Failure(let error):
                            NSLog("Signature Upload Error: %@", error)
                            
                            UITools.sharedInstance.toast("上传签名失败")
                        }
                        
                    }
                case .Failure(let encodingError):
                    print("Signature Upload encodingError: %@", encodingError)
                    
                    //取消等待动画
                    HUD.hide(true)
                    UITools.sharedInstance.toast("上传签名失败")
                }
                
            }
        )
    }

}
