//
//  GXApiDefine.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

// MARK: - 基础数据

/// 基础Url
let Api_baseUrl = "http://39.108.126.187"

/// App最新版本
let Api_app_update_latest = "/charging-system-server/app/update/latest"

/// 场站服务
let Api_dict_list_available = "/charging-system-server/dict/list/available"

/// 系统参数
let Api_param_consumer_detail = "/charging-system-server/param/consumer/detail"

/// 常见问题
let Api_questions_consumer_list = "/charging-system-server/param/consumer/detail"

// MARK: - 登录/注册



// MARK: - 站点和桩信息

// 站点查询
let Api_station_consumer_query = "/charging-order-server/station/consumer/query"

// 站点详情
let Api_station_consumer_detail = "/charging-order-server/station/consumer/detail"

// 站点枪列表
let Api_connector_consumer_list = "/charging-order-server/connector/consumer/list"

// 站点枪详情
let Api_connector_consumer_detail = "/charging-order-server/connector/consumer/detail"

// 枪扫二维码
let Api_connector_consumer_scan = "/charging-order-server/connector/consumer/scan"

// 车辆-列表
let Api_vehicle_consumer_list = "/charging-order-server/vehicle/consumer/list"

// 车辆-新增修改
let Api_vehicle_consumer_save = "/charging-order-server/vehicle/consumer/save"

// 车辆-删除
let Api_vehicle_consumer_delete = "/charging-order-server/vehicle/consumer/delete"
