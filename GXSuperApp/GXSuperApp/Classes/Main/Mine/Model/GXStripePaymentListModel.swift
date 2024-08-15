//
//  GXStripePaymentListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/15.
//

import UIKit

class GXStripePaymentListDataItem: GXBaseModel {
    var paymentMethodId: String = ""
    var last4: String = ""
    var type: String = ""
}

class GXStripePaymentListModel: GXBaseModel {
    var data: [GXStripePaymentListDataItem] = []
}
