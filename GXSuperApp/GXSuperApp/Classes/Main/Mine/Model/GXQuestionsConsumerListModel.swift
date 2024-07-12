//
//  GXQuestionsConsumerListModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit
import HandyJSON

class GXQuestionsConsumerListData: NSObject, HandyJSON {
    var id: Int = 0
    var title: String = ""
    var content: String = ""
    var orderNum: Int = 0

    override required init() {}
}

class GXQuestionsConsumerListModel: GXBaseModel {
    var data: [GXQuestionsConsumerListData] = []
}
