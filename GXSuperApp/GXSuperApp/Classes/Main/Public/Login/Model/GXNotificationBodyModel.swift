//
//  GXNotificationBodyModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/5.
//

import UIKit
import HandyJSON

class GXNotificationBodyModel: NSObject, HandyJSON {
    ///活动id
    var activityId: Int = 0
    ///日标id 事件/问卷/咨询的id
    var targetId: Int = 0
    ///消息端 1-活动参与者端 2-活动发布者端
    var targetType: Int = 0
    /**
     * 消息类型 1-活动咨询消息 2-活动回顾信息 3-活动咨询消息回复 4-报名成功 5-参与者获奖信息
     *        6-活动问卷 7-工作汇报 8-禁用活动 9-禁用活动用户端 10-审核活动通过
     *        11-参与者端活动（从微信分享页打开app）
     */
    var messageType: Int = 0

    override required init() {}
}
