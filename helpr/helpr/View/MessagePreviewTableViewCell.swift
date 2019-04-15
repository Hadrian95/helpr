//
//  MessageTableViewCell.swift
//  helpr
//
//  Created by adrian.parcioaga on 2019-02-05.
//  Copyright © 2019 helpr. All rights reserved.
//

import UIKit

class MessagePreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var ivProfilePic: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBidAmt: UILabel!
    @IBOutlet weak var lblMsgTime: UILabel!
    @IBOutlet weak var lblMsgPreview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ivProfilePic.layer.cornerRadius = ivProfilePic.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
