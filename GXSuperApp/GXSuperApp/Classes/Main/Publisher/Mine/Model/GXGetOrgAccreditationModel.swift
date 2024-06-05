//
//  GXGetOrgAccreditationModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit
import HandyJSON

class GXGetOrgAccreditationData: NSObject, HandyJSON {
    var approveStatus: Int = 0
    var approveTime: String = ""
    var approveUserId: Int = 0
    var businessLicense: String = ""
    var createTime: String = ""
    var deleted: Int = 0
    var id: Int = 0
    var orgName: String = ""
    var rejectReason: String = ""
    var updateTime: String = ""
    var userId: Int = 0

    override required init() {}
}

class GXGetOrgAccreditationModel: GXBaseModel {
    var data: GXGetOrgAccreditationData?
}
