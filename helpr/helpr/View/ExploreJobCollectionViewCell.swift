//
//  ExploreJobCollectionViewCell.swift
//  helpr
//
//  Created by Critical on 2019-03-12.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import UIKit

class ExploreJobCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var jobPic: UIImageView!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var jobCategory: UILabel!
    @IBOutlet weak var jobDistance: UILabel!
    @IBOutlet weak var jobPostedTime: UILabel!
    var job : Job!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        jobPic.addBlackGradientLayerInBackground(frame: self.bounds, colors: [.clear, .black])
    }
}

extension UIView{
    // For insert layer in Foreground
    func addBlackGradientLayerInForeground(frame: CGRect, colors:[UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        self.layer.addSublayer(gradient)
    }
    // For insert layer in background
    func addBlackGradientLayerInBackground(frame: CGRect, colors:[UIColor]){
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map{$0.cgColor}
        gradient.opacity = 0.7
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        self.layer.insertSublayer(gradient, at: 0)
    }
}
