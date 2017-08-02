//
//  ThemeTableViewCell.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addIcon: UIImageView!
    @IBOutlet weak var nameLabelLeftCons: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
            nameLabel.textColor = UIColor.white
            contentView.backgroundColor = UIColor.colorFromHex(0x1D2328)
            homeIcon.image = UIImage.init(named: "Menu_Icon_Home_Highlight")

        } else {
            nameLabel.font = UIFont.systemFont(ofSize: 15)
            nameLabel.textColor = UIColor.colorFromHex(0x95999D)
            contentView.backgroundColor = UIColor.clear
            homeIcon.image = UIImage.init(named: "Menu_Icon_Home")
        }
    }

}
