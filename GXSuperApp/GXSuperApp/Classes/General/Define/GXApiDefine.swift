//
//  GXApiDefine.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

/// 基础Url
let Api_baseUrl = "http://39.108.126.187"
let Api_base1Url = "http://47.238.124.126:8081"

// MARK: - 公用第三方接口

/// 上传文件
let Api_file_upload = "/charging-auth-server/file/upload"


// MARK: - 基础数据

/// 规则协议
let Api_agreement_list = "/charging-system-server/agreement/list"

/// App最新版本
let Api_app_update_latest = "/charging-system-server/app/update/latest"

/// 场站服务
let Api_dict_list_available = "/charging-system-server/dict/list/available"

/// 系统参数
let Api_param_consumer_detail = "/charging-system-server/param/consumer/detail"

/// 常见问题
let Api_questions_consumer_list = "/charging-system-server/questions/consumer/list"


// MARK: - 登录/注册

/// 获取验证码
let Api_auth_phone_code = "/charging-auth-server/auth/phone/code"

/// 手机验证码登录
let Api_auth_phone_login = "/charging-auth-server/auth/consumer/user/phone/login"

/// Apple登录
let Api_auth_apple_login = "/auth/consumer/user/apple/login"

/// Google登录
let Api_auth_google_login = "/auth/consumer/user/google/login"

/// 用户信息
let Api_auth_user_profile = "/charging-auth-server/auth/consumer/user/profile"

/// 用户信息修改
let Api_auth_user_profile_edit = "/charging-auth-server/auth/consumer/user/profile/edit"

/// 退出登录
let Api_auth_user_logout = "/charging-auth-server/auth/consumer/user/logout"

/// 注销
let Api_auth_user_cancel = "/charging-auth-server/auth/consumer/user/cancel"

/// 用户信息-FCM令牌修改
let Api_auth_user_fcm_token = "/charging-auth-server/auth/consumer/user/fcm/token/edit"


// MARK: - 站点和桩信息

/// 站点查询
let Api_station_consumer_query = "/charging-order-server/station/consumer/query"

/// 站点详情
let Api_station_consumer_detail = "/charging-order-server/station/consumer/detail"

/// 站点充电价格
let Api_station_consumer_price = "/charging-order-server/station/consumer/price"

/// 站点枪列表
let Api_connector_consumer_list = "/charging-order-server/connector/consumer/list"

/// 站点枪详情
let Api_connector_consumer_detail = "/charging-order-server/connector/consumer/detail"

/// 枪扫二维码
let Api_connector_consumer_scan = "/charging-order-server/connector/consumer/scan"

/// 枪状态
let Api_connector_consumer_status = "/charging-order-server/connector/consumer/status"

/// 车辆-列表
let Api_vehicle_consumer_list = "/charging-order-server/vehicle/consumer/list"

/// 车辆-新增修改
let Api_vehicle_consumer_save = "/charging-order-server/vehicle/consumer/save"

/// 车辆-删除
let Api_vehicle_consumer_delete = "/charging-order-server/vehicle/consumer/delete"

/// 站点-收藏|取消收藏
let Api_favorite_consumer_save = "/charging-order-server/favorite/consumer/save"

/// 站点-收藏列表
let Api_favorite_consumer_list = "/charging-order-server/favorite/consumer/list"


// MARK: - 订单

/// 进行中的订单
let Api_order_consumer_doing = "/charging-order-server/order/consumer/doing"

/// 启动充电
let Api_order_consumer_start = "/charging-order-server/order/consumer/start"

/// 停止充电
let Api_order_consumer_stop = "/charging-order-server/order/consumer/stop"

/// 充电桩的充电状态
let Api_order_consumer_status = "/charging-order-server/order/consumer/status"

/// 订单总数
let Api_order_consumer_total = "/charging-order-server/order/consumer/total"

/// 订单列表->订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：
let Api_order_consumer_list = "/charging-order-server/order/consumer/list"

/// 订单详情
let Api_order_consumer_detail = "/charging-order-server/order/consumer/detail"

/// 订单支付
let Api_order_consumer_pay = "/charging-order-server/order/consumer/pay"

/// 订单支付-绑定的银行卡
let Api_order_consumer_pay_card = "/charging-order-server/order/consumer/pay/card"

/// 订单申诉
let Api_order_consumer_complain_save = "/charging-order-server/order/consumer/complain/save"

/// 订单申诉详情
let Api_order_consumer_complain_detail = "/charging-order-server/order/consumer/complain/detail"


// MARK: - 钱包

/// 钱包余额
let Api_wallet_consumer_balance = "/charging-wallet-server/wallet/consumer/balance"

/// 钱包明细
let Api_wallet_consumer_list = "/charging-wallet-server/wallet/consumer/list"

/// Stripe支付
let Api_stripe_consumer_payment = "/charging-wallet-server/stripe/consumer/payment"

/// 提现
let Api_withdraw_consumer_submit = "/charging-wallet-server/withdraw/consumer/submit"

/// Apple订阅-单据验证
let Api_subscribe_apple_verify_receipt = "/charging-wallet-server/subscribe/apple/verify/receipt"

/// 设置付款方式
let Api_wallet_consumer_payment_method_set = "/charging-wallet-server/wallet/consumer/payment/method/set"

/// 设置未来支付
let Api_stripe_consumer_setup_intent = "/charging-wallet-server/stripe/consumer/setup/intent"

/// 支付账号列表
let Api_stripe_consumer_payment_method_list = "/charging-wallet-server/stripe/consumer/payment/method/list"

/// 移除支付账号
let Api_stripe_consumer_payment_method_detach = "/charging-wallet-server/stripe/consumer/payment/method/detach"
