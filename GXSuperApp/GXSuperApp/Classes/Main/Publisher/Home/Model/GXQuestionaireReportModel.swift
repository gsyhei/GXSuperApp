//
//  GXQuestionaireReportModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/7.
//

import UIKit
import HandyJSON

class GXOptionreportsModel: NSObject, HandyJSON {
    var submitRate: Int = 0
    var submitNum: Int = 0
    var optionTitle: String = ""

    override required init() {}
}

class GXTopicreportsModel: NSObject, HandyJSON {
    var topicType: Int = 0
    var optionReports = [GXOptionreportsModel]()
    var topicTitle: String = ""

    override required init() {}
}

class GXQuestionaireReportData: NSObject, HandyJSON {
    var questionaireTarget: Int = 0
    var submitNum: Int = 0
    var topicReports = [GXTopicreportsModel]()
    var topicNum: Int = 0

    override required init() {}
}

class GXQuestionaireReportModel: GXBaseModel {
    var data: GXQuestionaireReportData?
}
