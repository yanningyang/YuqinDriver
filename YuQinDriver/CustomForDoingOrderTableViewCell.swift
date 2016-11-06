//
//  CustomForDoingOrderTableViewCell.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/2/28.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import UIKit

class CustomForDoingOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var button1: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button1.hidden = true
        self.label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.label2.numberOfLines = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
