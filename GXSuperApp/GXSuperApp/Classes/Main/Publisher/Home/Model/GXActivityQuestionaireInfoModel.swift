//
//  GXActivityQuestionaireInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/17.
//

import UIKit
import HandyJSON

class GXActivityquestionairesData: NSObject, HandyJSON {
    var list: [GXPublishQuestionaireDetailData] = []
    var pageNum: Int = 0
    var pageSize: Int = 0
    var total: Int = 0
    var totalPage: Int = 0

    override required init() {}
}

class GXActivityQuestionaireInfoData: NSObject, HandyJSON {
    var activityQuestionaires: GXActivityquestionairesData?

    override required init() {}
}

class GXActivityQuestionaireInfoModel: GXBaseModel {
    var data: GXActivityQuestionaireInfoData?
}

class GXMyQuestionaireModel: GXBaseModel {
    var data: [GXPublishQuestionaireDetailData] = []
}
