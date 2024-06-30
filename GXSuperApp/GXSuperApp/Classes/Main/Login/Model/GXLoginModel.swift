//
//  GXLoginModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/29.
//

import UIKit
import HandyJSON

class GXLoginData: NSObject, HandyJSON {
    var token: String = ""
    
    required override init() {}
}

class GXLoginModel: GXBaseModel {
    var data: GXLoginData?
}
