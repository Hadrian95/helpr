//
//  HomeTableViewCell.swift
//  helpr
//
//  Created by adrian.parcioaga on 2018-10-30.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var jobPic: UIImageView!
    @IBOutlet weak var jobCategory: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobPostedTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
