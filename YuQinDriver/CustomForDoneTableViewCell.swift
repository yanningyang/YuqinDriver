//
//  CustomForDoneTableViewCell.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/29.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit

class CustomForDoneTableViewCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.label1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.label1.numberOfLines = 0
        self.label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.label2.numberOfLines = 0
        self.label3.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.label3.numberOfLines = 0
        self.label4.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.label4.numberOfLines = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
