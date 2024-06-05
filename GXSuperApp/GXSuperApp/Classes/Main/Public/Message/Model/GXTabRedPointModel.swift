//
//  GXTabRedPointModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/25.
//

import UIKit
import HandyJSON

class GXTabRedPointData: NSObject, HandyJSON {
    var consultationRedPoint: Bool = false
    var messageRedPoint: Bool = false
    var signRedPoint: Bool = false
    var workRedPoint: Bool = false
    var systemMessageRedPoint: Bool = false

    override required init() {}
}

class GXTabRedPointModel: GXBaseModel {
    var data: GXTabRedPointData?
}
