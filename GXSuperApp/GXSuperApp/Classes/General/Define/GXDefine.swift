//
//  GXDefine.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit

let SCREEN_SIZE = UIScreen.main.bounds.size

let SCREEN_WIDTH = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SCREEN_SCALE = UIScreen.main.scale

let SCREEN_MIN_WIDTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)

let STATUS_HEIGHT = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.statusBarManager?.statusBarFrame.height ?? 0

let PAGE_SIZE: Int = 20 /// 每页数量

typealias GXActionBlock = (() -> Void)
typealias GXActionBlockItem<T: Any> = ((T) -> Void)
typealias GXActionBlockItem2<T: Any, T1: Any> = ((T, T1) -> Void)
typealias GXActionBlockItem3<T: Any, T1: Any, T2: Any> = ((T, T1, T2) -> Void)
typealias GXActionBlockBack<T: Any> = (() -> T)
typealias GXActionBlockItemBack<T1: Any, T2: Any> = ((T1) -> T2)

/// Bugly appID
let GX_BUGLY_APPKID = "36156d5fa8"

/// 存储token的key
let GX_USER_TOKEN_KEY = "GX_USER_TOKEN_KEY"

/// 存储user的key
//let GX_USER_INFO_KEY = "GX_USER_INFO_KEY"

/// 存储角色类型
let GX_ROLE_TYPE_KEY = "GX_ROLE_TYPE_KEY"

/// 存储城市的key
let GX_CITY_KEY = "GX_CITY_KEY"

/// 存储经纬度的key
let GX_LOCATION_KEY = "GX_LOCATION_KEY"

/// 存储搜索历史的key
let GX_SEARCH_HISTORY_KEY = "GX_SEARCH_HISTORY_KEY"

/// 参与者角色切换的Popover
let GX_PTSHOW_POPOVER_KEY = "GX_PTSHOW_POPOVER_KEY"

/// 发布者角色发布的Popover
let GX_PRSHOW_POPOVER_KEY = "GX_PRSHOW_POPOVER_KEY"
