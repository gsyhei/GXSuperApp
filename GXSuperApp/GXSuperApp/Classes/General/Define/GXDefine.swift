//
//  GXDefine.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit
import HandyJSON

let SCREEN_SIZE = UIScreen.main.bounds.size

let SCREEN_WIDTH = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SCREEN_SCALE = UIScreen.main.scale

let SCREEN_MIN_WIDTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)

let STATUS_HEIGHT = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.statusBarManager?.statusBarFrame.height ?? 0

let PAGE_SIZE: Int = 20 /// 每页数量

let APP_NAME = UIApplication.appDisplayName() ?? "MarsEnergy"

typealias GXActionBlock = (() -> Void)
typealias GXActionBlockItem<T: Any> = ((T) -> Void)
typealias GXActionBlockItem2<T: Any, T1: Any> = ((T, T1) -> Void)
typealias GXActionBlockItem3<T: Any, T1: Any, T2: Any> = ((T, T1, T2) -> Void)
typealias GXActionBlockBack<T: Any> = (() -> T)
typealias GXActionBlockItemBack<T1: Any, T2: Any> = ((T1) -> T2)

let GX_YES = "YES"
let GX_NO  = "NO"

/// 活动分类
enum GXBOOL: String, HandyJSONEnum {
    /// 普通活动
    case YES = "YES"
    /// 多场次活动
    case NO = "NO"
}

///充电状态
enum GXChargingStatus: String, HandyJSONEnum {
    /// 未知
    case UNKNOWN = ""
    /// 启动中
    case STARTING = "STARTING"
    /// 充电中
    case CHARGING = "CHARGING"
    /// 停止中
    case STOPPING = "STOPPING"
    /// 充电完成
    case FINISHED = "FINISHED"
    /// 启动失败
    case START_FAILED = "START_FAILED"
}

///订单状态
enum GXOrderStatus: String, HandyJSONEnum {
    /// 未知
    case UNKNOWN = ""
    /// 充电中
    case CHARGING = "CHARGING"
    /// 占位中
    case OCCUPY = "OCCUPY"
    /// 充电完成
    case TO_PAY = "TO_PAY"
    /// 已完成
    case FINISHED = "FINISHED"
}


/// Bugly appID
let GX_BUGLY_APPID = "36156d5fa8"

/// Google api key
let GX_GOOGLE_APIKEY = "AIzaSyA5qCFvm4xtPdv2vQOt3RA12cF-8Kbcdho"

/// productIdentifier
let GX_PRODUCT_ID = "superappproduct01"
