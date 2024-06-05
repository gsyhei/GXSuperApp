//
//  GXRoleUtil.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit

class GXRoleUtil: NSObject {
    // 角色类型 1-发布者 2-管理员 3-核销票 4-客服

    /// 角色权限- 发布者
    class func isPublisher(roleType: String?) -> Bool {
        guard let type = roleType else { return false }

        if type.contains(find: "1") {
            return true
        }
        return false
    }

    /// 角色权限- 管理员/发布者
    class func isAdmin(roleType: String?) -> Bool {
        guard let type = roleType else { return false }

        if type.contains(find: "1") {
            return true
        }
        else if type.contains(find: "2") {
            return true
        }
        return false
    }

    /// 角色权限- 管理员
    class func isOneAdmin(roleType: String?) -> Bool {
        guard let type = roleType else { return false }

        if type.contains(find: "2") {
            return true
        }
        return false
    }

    /// 角色权限- 核销票
    class func isTeller(roleType: String?) -> Bool {
        guard let type = roleType else { return false }

        if type.contains(find: "3") {
            return true
        }
        return false
    }

    /// 角色权限- 客服
    class func isService(roleType: String?) -> Bool {
        guard let type = roleType else { return false }

        if type.contains(find: "4") {
            return true
        }
        return false
    }

    /// 角色权限- 工作人员
    class func isStaff(roleType: String?) -> Bool {
        guard let type = roleType else { return false }
        
        if GXRoleUtil.isAdmin(roleType: type) {
            return true
        }
        if GXRoleUtil.isTeller(roleType: type) {
            return true
        }
        if GXRoleUtil.isService(roleType: type) {
            return true
        }
        return false
    }

    /// 角色权限- 删除权限
    class func remove(old roleType: String, type: String) -> String {
        var roleTypeArr: [String] = roleType.components(separatedBy: ",")
        roleTypeArr.removeAll(where: { $0 == type })

        return roleTypeArr.joined(separator: ",")
    }

    /// 角色权限- 添加权限
    class func append(old roleType: String, type: String) -> String {
        var roleTypeArr: [String] = roleType.components(separatedBy: ",")
        roleTypeArr.append(type)

        return roleTypeArr.joined(separator: ",")
    }

}
