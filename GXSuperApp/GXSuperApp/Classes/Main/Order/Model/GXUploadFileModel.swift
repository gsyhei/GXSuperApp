//
//  GXUploadFileModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import HandyJSON

class GXUploadFileData: HandyJSON {
    var path: String = ""
    
    required init() {}
}

class GXUploadFileModel: GXBaseModel {
    var data: GXUploadFileData?
}
