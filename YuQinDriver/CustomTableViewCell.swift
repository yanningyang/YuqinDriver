//
//  CustomTableViewCell.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 15/12/13.
//  Copyright © 2015年 ChongQing University. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myLabel2: UILabel!
    @IBOutlet weak var myLabel3: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.myLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.myLabel.numberOfLines = 0
        self.myLabel2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.myLabel2.numberOfLines = 0
        self.myLabel3.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.myLabel3.numberOfLines = 0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    @IBAction func executingOrder(sender: UIButton) {
//    }
}
