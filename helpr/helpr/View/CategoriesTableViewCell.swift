//
//  CategoriesTableViewCell.swift
//  helpr
//
//  Created by walter.alvarez on 2018-11-23.
//  Copyright © 2018 helpr. All rights reserved.
//
//  cell for category items used in create post and filtering

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var lCategoryName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
