//
//  GXPtHomeMySignActivityModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit

import HandyJSON

class GXPtHomeMySignActivityData: NSObject, HandyJSON {
    var goingActivityList: [GXActivityBaseInfoData] = []
    var notStartActivityList: [GXActivityBaseInfoData] = []

    func isTabNumber() -> Int {
        var number: Int = 0
        if self.goingActivityList.count > 0 {
            number += 1
        }
        if self.notStartActivityList.count > 0 {
            number += 1
        }
        return number
    }

    func selectedIndex() -> Int? {
        if self.goingActivityList.count > 0 {
            return 0
        }
        if self.notStartActivityList.count > 0 {
            return 1
        }
        return nil
    }

    func selectedCount(index: Int) -> Int {
        if index == 0 {
            return (self.goingActivityList.count > 3) ? 3 : self.goingActivityList.count
        }
        else if index == 1 {
            return (self.notStartActivityList.count > 3) ? 3 : self.notStartActivityList.count
        }
        return 0
    }

    override required init() {}
}

class GXPtHomeMySignActivityModel: GXBaseModel {
    var data: GXPtHomeMySignActivityData?
}
