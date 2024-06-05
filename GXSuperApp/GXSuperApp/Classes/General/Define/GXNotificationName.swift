//
//  GXNotficationName.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/7/17.
//

import Foundation

// MARK: 通知name

/// 登录完成
let GX_NotifName_Login = NSNotification.Name("GX_NN_Login")

/// 音乐电台播放
let GX_NotifName_MusicPlay = NSNotification.Name("GX_NotifName_MusicPlay")

/// 横向日历选择通知
let GX_NotifName_HCalendarSelected = NSNotification.Name("GX_NotifName_HCalendarSelected")

/// 竖向日历选择通知
let GX_NotifName_VCalendarSelected = NSNotification.Name("GX_NotifName_VCalendarSelected")

/// 城市定位切换通知
let GX_NotifName_ChangeCity = NSNotification.Name("GX_NotifName_ChangeCity")

/// 网络状态监听
let GX_NotifName_NetworkStatus = NSNotification.Name("GX_NotifName_NetworkStatus")

/// 获取到小红点通知
let GX_NotifName_UpdateTabRedPoint = NSNotification.Name("GX_NotifName_UpdateTabRedPoint")

/// 点击通知栏消息
let GX_NotifName_ClickNotification = NSNotification.Name("GX_NotifName_ClickNotification")

// MARK: 通知参数Key

/// 音乐电台播放 - model key
let GX_MusicPlay_ModelKey = "GX_MusicPlay_ModelKey"
/// 音乐电台播放 - 是否播放 key
let GX_MusicPlay_IsPlayKey = "GX_MusicPlay_IsPlayKey"

/// 城市定位切换通知-城市
let GX_ChangeCity_CityKey = "GX_ChangeCity_CityKey"
/// 城市定位切换通知-位置
let GX_ChangeCity_LocationKey = "GX_ChangeCity_LocationKey"
