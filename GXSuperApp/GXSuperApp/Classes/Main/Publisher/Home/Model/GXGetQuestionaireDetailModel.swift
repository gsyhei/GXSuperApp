//
//  GXGetQuestionaireDetailModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/18.
//

import UIKit
import HandyJSON

class GXQuestionairetopicoptionsModel: NSObject, HandyJSON {
    var createTime: String?
    var id: Int?
    var optionIndex: String?
    var optionTitle: String?
    var questionaireTopicId: Int?
    var updateTime: String?

    override required init() {}
}

class GXQuestionairetopicsModel: NSObject, HandyJSON {
    var createTime: String?
    var id: Int?
    var questionaireId: Int?
    var questionaireTopicOptions: [GXQuestionairetopicoptionsModel]?
    var topicDesc: String?
    var topicTitle: String?
    var topicType: Int?
    var updateTime: String?

    override required init() {}
}

class GXPublishQuestionaireAnswersItem: NSObject, HandyJSON {
    var createTime: String?
    var updateTime: String?
    var id: Int?
    var topicId: Int?
    var optionId: Int?
    var userId: Int?
    var questionaireId: Int?

    override required init() {}
}

class GXPublishQuestionaireDetailData: NSObject, HandyJSON {
    var activityId: Int?
    var createTime: String?
    var creatorId: Int?
    var deleted: Int?
    var id: Int?
    var questionaireDesc: String?
    var questionaireFrom: Int?
    var questionaireName: String?
    var questionairePic: String?
    var questionaireStatus: Int?
    var questionaireTarget: Int?
    var questionaireTopics: [GXQuestionairetopicsModel]?
    var questionaireAnswers: [GXPublishQuestionaireAnswersItem]?
    var rejectReason: String?
    var shelfStatus: Int?
    var updateTime: String?
    var submitFlag: Bool?
    var submitNum: Int?

    override required init() {}
}

class GXGetQuestionaireDetailModel: GXBaseModel {
    var data: GXPublishQuestionaireDetailData?
}
