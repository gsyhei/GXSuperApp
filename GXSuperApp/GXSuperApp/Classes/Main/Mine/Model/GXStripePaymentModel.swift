//
//  GXStripePaymentModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/4.
//

import UIKit
import HandyJSON

class GXStripePaymentData: NSObject, HandyJSON {
    var id: String = ""
    var publishableKey: String = ""
    var clientSecret: String = ""
    var ephemeralKey: String = ""
    var customer: String = ""
    
    override required init() {}
}

class GXStripePaymentModel: GXBaseModel {
    var data: GXStripePaymentData?
}
