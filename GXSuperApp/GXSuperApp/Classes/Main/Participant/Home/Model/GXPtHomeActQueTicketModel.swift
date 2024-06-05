//
//  GXPtHomeActQueTicketModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import HandyJSON

class GXPtHomeActQueTicketData: NSObject, HandyJSON {
    var activityQuestionaireId: String = ""
    var broadcastTitle: String = ""
    var questionaireName: String = ""
    var ticketBroadcastId: String = ""
    var todayActivityNum: Int = 0
    var broadCastActivityId: Int = 0

    override required init() {}
}

class GXPtHomeActQueTicketModel: GXBaseModel {
    var data: GXPtHomeActQueTicketData?
}
