//
//  GXReceiptInfoItemModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/18.
//

import UIKit
import HandyJSON

class GXReceiptInfoItemModel: NSObject, HandyJSON {
    var original_purchase_date: String = ""
    var product_id: String = ""
    var purchase_date_pst: String = ""
    var transaction_id: String = ""
    var original_transaction_id: String = ""
    var web_order_line_item_id: String = ""
    var is_in_intro_offer_period: String = ""
    var in_app_ownership_type: String = ""
    var app_account_token: String = ""
    var is_trial_period: String = ""
    var purchase_date: String = ""
    var original_purchase_date_pst: String = ""
    var subscription_group_identifier: String = ""
    var purchase_date_ms: String = ""
    var original_purchase_date_ms: String = ""
    var quantity: String = ""
    var expires_date: String = ""
    var expires_date_ms: TimeInterval = 0
    var expires_date_pst: String = ""
    
    func gx_expiresDate() -> Date {
        return Date(timeIntervalSince1970: self.expires_date_ms)
    }
    
    override required init() {}
}
