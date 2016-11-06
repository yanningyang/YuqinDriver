//
//  CustomHeaderViewForDoneTableViewTableViewCell.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/2/3.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class CustomHeaderViewForDoneTableViewTableViewCell: UITableViewCell {

    @IBOutlet weak var beginDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    var beginDate: NSDate? {
        didSet {
            self.beginDateStr = beginDate != nil ? self.dateFormatter.stringFromDate(beginDate!) : "开始日期"
        }
    }
    var endDate: NSDate? {
        didSet {
            self.endDateStr = endDate != nil ? self.dateFormatter.stringFromDate(endDate!) : "终止日期"
        }
    }

    var beginDateStr: String = "开始日期" {
        didSet {
            beginDateBtn.setTitle(beginDateStr, forState: UIControlState.Normal)
        }
    }
    var endDateStr: String = "终止日期" {
        didSet {
            endDateBtn.setTitle(endDateStr, forState: UIControlState.Normal)
        }
    }
    
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    var viewController: UIViewController? {
        
        var next = self.superview
        while next != nil {
            let nextResponder = next?.nextResponder()
            if nextResponder is UIViewController {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }
        
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //选择日期
    @IBAction func selectDateForBtn(sender: UIButton) {
        
        let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            if sender == self.beginDateBtn {
                let beginDate = value as? NSDate
                if self.endDate != nil && beginDate?.compare(self.endDate!) == .OrderedDescending {
                    
                    UITools.sharedInstance.toast(toView: self.viewController!.view, labelText: "开始日期不能大于结束日期")
                    return
                }
                self.beginDate = beginDate
                self.beginDateStr = self.dateFormatter.stringFromDate(beginDate!)
                sender.setTitle(self.beginDateStr, forState: .Normal)
            } else {
                let endDate = value as? NSDate
                if self.beginDate != nil && endDate?.compare(self.beginDate!) == .OrderedAscending {
                    
                    UITools.sharedInstance.toast(toView: self.viewController!.view, labelText: "结束日期不能小于开始日期")
                    return
                }
                self.endDate = endDate
                self.endDateStr = self.dateFormatter.stringFromDate(endDate!)
                sender.setTitle(self.endDateStr, forState: .Normal)
            }
            return
            
            }, cancelBlock: {ActionStringCancelBlock in return}, origin: UIApplication.sharedApplication().keyWindow!)
        datePicker.tapDismissAction = TapAction.Cancel
        datePicker.setCancelButton(UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.setDoneButton(UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: nil, action: nil))
        datePicker.showActionSheetPicker()
    }
}
