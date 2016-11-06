//
//  UrlConnection.swift
//  YuQinDriver
//
//  Created by ksn_cn on 2016/10/27.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD

// 除登录接口之外
public class UrlConnection {
    let host_path = Constant.HOST_NAME + "/app"
    var action: String!
    var commonUrl: String!
    var addCommonParameter: Bool
    
    // 添加公共参数
    init(action: String, addCommonParameter: Bool = true) {
        self.action = action
        self.addCommonParameter = addCommonParameter
        
        if addCommonParameter {
            let (userName, password, companyId) = Utility.sharedInstance.getUserInfo1()
            guard userName != nil && password != nil && companyId != nil && !userName!.isEmpty && !password!.isEmpty && !companyId!.isEmpty else {
                Utility.sharedInstance.logout(withToast: true)
                return
            }
            
            var parameters = [String : String]()
            parameters["username"] = userName!
            parameters["pwd"] = password!
            parameters["companyId"] = companyId!
            
            commonUrl = host_path + "/\(self.action)" + "?" + encodeUrlParameters(parameters)
        } else {
            commonUrl = host_path + "/\(self.action)"
        }
    }
    
    func assembleUrl(parameters: [String : String] = [ : ]) -> String {
        if parameters.keys.count == 0 {
            return self.commonUrl
        }
        
        let queryString = encodeUrlParameters(parameters)
        
        if self.addCommonParameter {
            return self.commonUrl + "&" + queryString
        } else {
            return self.commonUrl + "?" + queryString
        }
    }
    
    func encodeUrlParameters(parameters: [String : String]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sort(<) {
            components.append((escape(key), escape(parameters[key]!)))
        }
        
        return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
    }
    
    /**
     Returns a percent-escaped string following RFC 3986 for a query string key or value.
     
     RFC 3986 states that the following characters are "reserved" characters.
     
     - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
     - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
     
     In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
     query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
     should be percent-escaped in the query string.
     
     - parameter string: The string to be percent-escaped.
     
     - returns: The percent-escaped string.
     */
    public func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        if #available(iOS 8.3, OSX 10.10, *) {
            escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
                let range = startIndex..<endIndex
                
                let substring = string.substringWithRange(range)
                
                escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
    
    func request(url: String, showLoadingAnimation: Bool = false, successCallBack: (AnyObject) -> (), failureCallBack: (AnyObject) -> () = {_ in return}) {
        
        var HUD: MBProgressHUD!
        if showLoadingAnimation {
            //等待动画
            HUD = UITools.sharedInstance.showLoadingAnimation()
        }
        
        Alamofire.request(.GET, url)
            .responseJSON { response in
                
                print("\(self.action) request: \(response.request)")
                
                if showLoadingAnimation {
                    //取消等待动画
                    HUD.hide(true)
                }
                
                switch (response.result) {
                case .Success(let value):
                    print("\(self.action) result: \(value)")
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            print("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            print("\(url) 参数错误")
                        }
                        
                    } else {
                        successCallBack(value)
                    }
                case .Failure(let error):
                    print("\(self.action) error: \(error)")
                    failureCallBack(error)
                }
        }
    }
}
