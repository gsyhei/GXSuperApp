//
//  GXWalletConsumerlistModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import HandyJSON

class GXWalletConsumerListRowsItem: NSObject, HandyJSON {
    var amount: CGFloat = 0
    var linkId: String = ""
    var id: Int = 0
    var totalAmount: CGFloat = 0
    var direction: String = ""
    var type: String = ""
    var createTime: String = ""

    override required init() {}
}

class GXWalletConsumerListData: NSObject, HandyJSON {
    var total: Int = 0
    var rows = [GXWalletConsumerListRowsItem]()

    override required init() {}
}

class GXWalletConsumerListModel: GXBaseModel {
    var data: GXWalletConsumerListData?
}
