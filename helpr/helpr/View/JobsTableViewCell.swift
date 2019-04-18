//
//  JobsTableViewCell.swift
//  helpr
//
//  Created by walter alvarez and adrian parcioaga on 2018-11-04.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit
class JobsTableViewCell: UITableViewCell {
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

