//
//  Bid.swift
//  helpr
//
//  Created by Critical on 2019-03-28.
//  Copyright © 2019 ryan.konynenbelt. All rights reserved.
//

import Foundation

class Bid {
    var amt: Float?
    var rate: String?
    var time: Float?
    var timeUnits: String?
    
    init(amount: Float, rateType: String, timeEst: Float, units: String) {
        amt = amount
        rate = rateType
        time = timeEst
        timeUnits = units
    }
}
