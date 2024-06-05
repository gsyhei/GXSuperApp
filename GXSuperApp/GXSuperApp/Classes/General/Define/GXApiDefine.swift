//
//  GXApiDefine.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

/// 基础Url
let Api_BaseUrl = "http://134.175.216.124/testapi"
let Api_WebBaseUrl = "http://134.175.216.124"
//let Api_BaseUrl = "https://heiradio.cn/api"
//let Api_WebBaseUrl = "https://heiradio.cn"

// MARK: - 文件管理接口

/// 上传单张图片
let Api_File_UploadPic = "/file/uploadPic"
/// 上传多张图片
let Api_File_UploadPics = "/file/uploadPics"

// MARK: - 埋点

/// 数据埋点入库
let Api_Click_CreateEvent = "/customer/click/createEvent"
/// 抢票播报点击
let Api_Click_Broadcast = "/phone/broadcast/click"
/// banner点击
let Api_Click_Banner = "/phone/banner/click"

// MARK: - 移动端热门城市列表

/// 城市列表
let Api_HotCity_ListCity = "/phone/hotCity/listCity"

/// 热门城市列表
let Api_HotCity_ListHotCity = "/phone/hotCity/listHotCity"

// MARK: - 移动端我的

/// 获取短信验证码
let Api_User_GetSmsCode = "/phone/user/getSmsCode"

/// 手机短信验证码登录
let Api_User_Login = "/phone/user/login"

/// 绑定手机
let Api_User_BindPhone = "/phone/user/bindPhone"

/// 获取登录用户信息
let Api_User_GetUserInfo = "/phone/user/getUserInfo"

/// 退出登录接口
let Api_User_Logout = "/phone/user/logout"

/// 注销账号
let Api_User_CancelAccount = "/phone/user/cancelAccount"

/// 本机号码一键登录
let Api_User_PhoneLogin = "/phone/user/phoneLogin"

/// 苹果登录
let Api_User_AppleLogin = "/phone/user/appleLogin"

/// 微信登录
let Api_User_WxLogin = "/phone/wxLogin/login"

/// 实名认证
let Api_User_RealNameAuth = "/phone/user/realNameAuth"

/// 注册
let Api_User_Register = "/phone/user/register"

/// 编辑个人资料
let Api_User_EditUserInfo = "/phone/user/editUserInfo"

/// 获取个人实名认证信息
let Api_User_GetRealName = "/phone/user/getRealName"

/// 补充个人信息
let Api_User_UpdateUserInfo = "/phone/user/updateUserInfo"

/// 上传头像图片
let Api_User_UploadAvatar = "/phone/user/uploadAvatar"

/// 更新头像和昵称
let Api_User_UpdateAvatarAndNickName = "/phone/user/updateAvatarAndNickName"

/// 维护cid、极光推送id
let Api_User_UpdateCid = "/phone/user/updateCid"

/// 我的钱包
let Api_User_getMyWallet = "/phone/user/getMyWallet"

/// 查看历史提现详情
let Api_User_GetWithdrawDetail = "/phone/user/getWithdrawDetail"

/// 更新用户地理位置
let Api_User_UpdateLocation = "/phone/user/updateLocation"


// MARK: - 移动端提现接口

/// 获取财务设置信息
let Api_Withdraw_GetFinanceSetting = "/phone/withdraw/getFinanceSetting"

/// 发起提现
let Api_Withdraw_CreateWithdraw = "/phone/withdraw/createWithdraw"

/// 获取提现账号
let Api_WithdrawAccount_GetWithdrawAccount = "/withdrawAccount/getWithdrawAccount"

/// 设置提现账号
let Api_WithdrawAccount_SetWithdrawAccount = "/withdrawAccount/setWithdrawAccount"

/// 获取绑定提现账号短信验证码
let Api_WithdrawAccount_GetSmsCode = "/withdrawAccount/getSmsCode"

// MARK: - 移动端消息接口

/// 用户消息
let Api_Message_ListUserMessages = "/phone/message/listUserMessages"

/// 系统消息
let Api_Message_ListSystemMessages = "/phone/message/listSystemMessages"

/// 查看详情
let Api_Message_SelectById = "/phone/message/selectById"

/// 设置已读
let Api_Message_SetReadFlag = "/phone/message/setReadFlag"

/// 获取小红点
let Api_Message_GetTabRedPoint = "/phone/message/getTabRedPoint"

/// 消息置顶
let Api_Message_SetTop = "/phone/message/setTop"

/// 删除聊天
let Api_Message_DeleteChat = "/phone/message/deleteChat"

// MARK: - 移动端消息设置接口

/// 获取消息设置详情
let Api_Msgset_GetMessageSetting = "/phone/messageSetting/getMessageSetting"

/// 消息通知设置
let Api_Msgset_SetMessageSetting = "/phone/messageSetting/setMessageSetting"


// MARK: - 关于我们

/// 关于我们
let Api_About_GetAboutUs = "/phone/aboutUs/getAboutUs"

/// 意见反馈
let Api_Feedback_Create = "/phone/feedback/createFeedback"

/// 版本更新
let Api_About_CheckVersion = "/phone/aboutUs/checkVersion"


// MARK: - 活动参与端我的接口

/// 我的票夹
let Api_CUser_ListMyTicket = "/customer/user/listMyTicket"

/// 查看其它用户主页
let Api_CUser_GetUserHomepage = "/customer/user/getUserHomepage"

/// 关注-取消关注
let Api_CUser_FollowUser = "/customer/user/followUser"

/// 一键关注
let Api_CUser_FollowUsers = "/customer/user/followUsers"

/// 可能感兴趣的人
let Api_CUser_ListMayBeInterested = "/customer/user/listMayBeInterested"

/// 关注的人发布的活动
let Api_CUser_FollowActivity = "/customer/activity/followActivity"

/// 我的粉丝
let Api_CUser_ListMyFans = "/customer/user/listMyFans"

/// 我的关注
let Api_CUser_ListMyFollows = "/customer/user/listMyFollows"

/// 我的收藏
let Api_CUser_ListMyFavorite = "/customer/user/listMyFavorite"

/// 我的订单
let Api_CUser_ListMyOrder = "/customer/user/listMyOrder"

/// 根据订单编号获取详情
let Api_COrder_SelectByOrderSn = "/customer/order/selectByOrderSn"

// MARK: - 活动参与端我的地址

/// 新增地址
let Api_CUserAddress_CreateAddress = "/customer/userAddress/createAddress"

/// 根据ID删除地址
let Api_CUserAddress_DeleteById = "/customer/userAddress/deleteById"

/// 设置默认地址
let Api_CUserAddress_SetDefaultAddress = "/customer/userAddress/setDefaultAddress"

/// 分页查询地址
let Api_CUserAddress_Page = "/customer/userAddress/page"

/// 地址详情
let Api_CUserAddress_SelectById = "/customer/userAddress/createAddress"

/// 修改地址
let Api_CUserAddress_Update = "/customer/userAddress/update"

// MARK: - 活动发布端我的接口

/// 查看其它用户主页
let Api_Activity_GetUserHomepage = "/phone/activity/getUserHomepage"

/// 我的订单
let Api_ActivityMy_MyOrders = "/phone/activityMy/myOrders"

/// 获取我的机构认证信息
let Api_ActivityMy_GetOrgAccreditation = "/phone/activityMy/getOrgAccreditation"

/// 提交机构认证
let Api_ActivityMy_SubmitOrgAccreditation = "/phone/activityMy/submitOrgAccreditation"

/// 根据手机号查询我的订单
let Api_ActivityMy_MyOrdersByPhone = "/phone/activityMy/myOrdersByPhone"

/// 根据订单编号获取详情
let Api_Order_SelectByOrderSn = "/phone/order/selectByOrderSn"

// MARK: - 获取活动类型列表

/// 获取活动类型列表
let Api_ActivityType_List = "/phone/activityType/list"

/// 获取所有活动类型列表
let Api_CActivityType_ListType = "/customer/activity/listActivityType"

// MARK: - 活动发布端活动接口

/// 活动保存草稿
let Api_Activity_SaveActivityDraft = "/phone/activity/saveActivityDraft"

/// 活动提交审核(未保存草稿)
let Api_Activity_SubmitActivityDirect = "/phone/activity/submitActivityDirect"

/// 活动提交审核(已保存草稿)
let Api_Activity_SubmitActivity = "/phone/activity/submitActivity"

/// 获取活动须知
let Api_Activity_GetActivityRuleInfo = "/phone/activity/getActivityRuleInfo"

/// 我发布的活动
let Api_Activity_ListMyActivity = "/phone/activity/listMyActivity"

/// 我协助的活动
let Api_Activity_ListAssistActivity = "/phone/activity/listAssistActivity"

/// 删除活动
let Api_Activity_Delete = "/phone/activity/delete"

/// 我的草稿
let Api_Activity_ListMyDraft = "/phone/activity/listMyDraft"

/// 获取活动基本信息
let Api_Activity_GetActivityBaseInfo = "/phone/activity/getActivityBaseInfo"

/// 活动上架/下架
let Api_Activity_SetShelfStatus = "/phone/activity/setShelfStatus"

/// 获取活动图文
let Api_Activity_GetActivityPicInfo = "/phone/activity/getActivityPicInfo"

/// 编辑活动基本信息
let Api_Activity_UpdateActivityBaseInfo = "/phone/activity/updateActivityBaseInfo"

/// 编辑活动图文介绍
let Api_Activity_UpdateActivityPicInfo = "/phone/activity/updateActivityPicInfo"

/// 获取活动地图（场地图）
let Api_Activity_GetActivityMapInfo = "/phone/activity/getActivityMapInfo"

/// 编辑活动地图（场地图）
let Api_Activity_UpdateActivityMapInfo = "/phone/activity/updateActivityMapInfo"

/// 获取活动问卷
let Api_Activity_GetActivityQuestionaireInfo = "/phone/activity/getActivityQuestionaireInfo"

/// 获取活动事件
let Api_Activity_GetActivityEventInfo = "/phone/activity/getActivityEventInfo"

/// 获取活动回顾
let Api_Activity_GetActivityReviewInfo = "/phone/activity/getActivityReviewInfo"

/// 获取活动财务
let Api_Activity_GetActivityFinanceInfo = "/phone/activity/getActivityFinanceInfo"

/// 获取活动汇报
let Api_Activity_GetActivityReportInfo = "/phone/activity/getActivityReportInfo"

/// 获取活动成员-工作人员 type 1-查询报名成员 2-查询工作人员
let Api_Activity_GetActivitySignInfo = "/phone/activity/getActivitySignInfo"

/// 添加工作人员
let Api_Activity_AddActivityStaff = "/phone/activity/addActivityStaff"

/// 编辑活动成员-报名用户核销
let Api_Activity_UpdateActivitySignInfo = "/phone/activity/updateActivitySignInfo"

/// 编辑活动成员-报名用户核销
let Api_Activity_VerifyTicket = "/phone/userTicket/verifyTicket"

/// 编辑活动成员-工作人员
let Api_Activity_UpdateActivityStaffInfo = "/phone/activity/updateActivityStaffInfo"

// MARK: - 活动发布端报名管理接口

/// 保存报名成功用户(全量用户提交)
let Api_ActivitySign_SaveSignedInfo = "/phone/activitySign/saveSignedInfo"

/// 保存报名成功用户(增量用户提交)
let Api_ActivitySign_SaveSignedInfo2 = "/phone/activitySign/saveSignedInfo2"

/// 活动报名核销(单个)
let Api_ActivitySign_VerifyActivitySignInfo = "/phone/activitySign/verifyActivitySignInfo"

// MARK: - 活动发布端问卷接口

/// 获取问卷详情
let Api_Quest_GetQuestionaireDetail = "/phone/questionaire/getQuestionaireDetail"

/// 保存问卷草稿
let Api_Quest_SaveQuestionaireDraft = "/phone/questionaire/saveQuestionaireDraft"

/// 发布问卷草稿
let Api_Quest_SubmitDraftQuestionaire = "/phone/questionaire/submitDraftQuestionaire"

/// 发布问卷
let Api_Quest_SubmitQuestionaire = "/phone/questionaire/submitQuestionaire"

/// 编辑问卷
let Api_Quest_UpdateQuestionaire = "/phone/questionaire/updateQuestionaire"

/// 上架/下架问卷
let Api_Quest_ModifyQuestionaireShelf = "/phone/questionaire/modifyQuestionaireShelf"

/// 结束问卷
let Api_Quest_StopQuestionaire = "/phone/questionaire/stopQuestionaire"

/// 问卷统计
let Api_Quest_QuestionaireReport = "/phone/questionaire/questionaireReport"

/// 问卷删除
let Api_Quest_DeleteQuestionaire = "/phone/questionaire/deleteQuestionaire"

/// 获取我发布的问卷
let Api_Quest_GetMyQuestionaireList = "/phone/questionaire/getMyQuestionaireList"

// MARK: - 活动发布端事件接口

/// 添加事件
let Api_Event_AddEvent = "/phone/event/addEvent"

/// 获取事件详情
let Api_Event_GetEventDetail = "/phone/event/getEventDetail"

/// 禁用-启用事件
let Api_Event_ModifyEventStatus = "/phone/event/modifyEventStatus"

/// 编辑事件
let Api_Event_UpdateEvent = "/phone/event/updateEvent"

/// 发送中奖消息
let Api_Event_SendAwardMessage = "/phone/event/sendAwardMessage"

// MARK: - 活动发布端回顾接口

/// 添加回顾
let Api_Review_AddReview = "/phone/review/addReview"

/// 获取回顾详情
let Api_Review_GetReviewDetail = "/phone/review/getReviewDetail"

/// 禁用-启用回顾
let Api_Review_ModifyReviewStatus = "/phone/review/modifyReviewStatus"

/// 编辑回顾
let Api_Review_UpdateReview = "/phone/review/updateReview"

/// 置顶-取消置顶回顾
let Api_Review_SetTop = "/phone/review/setTop"


// MARK: - 活动发布端物料接口

/// 添加物料
let Api_Finance_AddFinance = "/phone/finance/addFinance"

/// 获取物料详情
let Api_Finance_GetFinanceDetail = "/phone/finance/getFinanceDetail"

/// 删除物料
let Api_Finance_DeleteFinance = "/phone/finance/deleteFinance"

/// 编辑物料
let Api_Finance_UpdateFinance = "/phone/finance/updateFinance"


// MARK: - 活动发布端汇报接口

/// 添加汇报
let Api_Report_AddReport = "/phone/report/addReport"

/// 获取物料详情
let Api_Report_GetReportDetail = "/phone/report/getReportDetail"

/// 编辑汇报
let Api_Report_UpdateReport = "/phone/report/updateReport"


// MARK: - 移动端规则协议管理接口

/// 获取规则协议（协议类型 1-买票模式规则说明 2-报名模式规则说明 3-活动发布者产品协议 4-活动协助者产品协议 5-活动工作者产品协议 6-隐私政策 7-用户协议）
let Api_Home_GetRuleProtocol = "/phone/ruleProcotol/getRuleProtocol"


// MARK: ===============================================================================================================


// MARK: - 移动端首页接口（发布端）

/// 获取音乐电台
let Api_Home_GetMusicStations = "/phone/home/getMusicStations"

// MARK: - 活动参与端活动接口

/// 首页banner列表
let Api_CActivity_ListBanner = "/customer/activity/listBanner"

/// 活动日历问卷标题抢票播报
let Api_CActivity_GetActivityAndQuestionaireAndTicket = "/customer/activity/getActivityAndQuestionaireAndTicket"

/// 进行中即将开始活动
let Api_CActivity_MySignActivity = "/customer/activity/mySignActivity"

/// 活动类型列表
let Api_CActivity_ListActivityType = "/customer/activity/listActivityTypeForHome"

/// 即将开售/预售早鸟
let Api_CActivity_Page = "/customer/activity/page"

/// 活动日历
let Api_CActivity_CalendarActivity = "/customer/activity/calendarActivity"

/// 热门搜索
let Api_CActivity_ListHotSearch = "/customer/activity/listHotSearch"

/// 历史搜索
let Api_CActivity_ListSearchWords = "/customer/activity/listSearchWords"

/// 搜索活动
let Api_CActivity_SearchActivity = "/customer/activity/searchActivity"

/// 获取活动基本信息
let Api_CActivity_GetActivityBaseInfo = "/customer/activity/getActivityBaseInfo"

/// 取消/收藏 活动
let Api_CActivity_AddFavorite = "/customer/activity/addFavorite"

/// 获取活动事件(仅报名成员可见)
let Api_CActivity_GetActivityEventInfo = "/customer/activity/getActivityEventInfo"

/// 获取活动地图
let Api_CActivity_GetActivityMapInfo = "/customer/activity/getActivityMapInfo"

/// 获取活动图文
let Api_CActivity_GetActivityPicInfo = "/customer/activity/getActivityPicInfo"

/// 获取活动问卷(仅报名成员可见)
let Api_CActivity_GetActivityQuestionaireInfo = "/customer/activity/getActivityQuestionaireInfo"

/// 获取活动回顾
let Api_CActivity_GetActivityReviewInfo = "/customer/activity/getActivityReviewInfo"

/// 获取活动须知
let Api_CActivity_GetActivityRuleInfo = "/customer/activity/getActivityRuleInfo"

/// 获取活动成员-工作人员(仅报名成员可见)type 1-查询报名成员 2-查询工作人员
let Api_CActivity_GetActivitySignInfo = "/customer/activity/getActivitySignInfo"

/// 报名
let Api_CActivity_SignActivity = "/customer/activity/signActivity"

/// 日历小红点
let Api_CActivity_Calendar = "/customer/activity/calendar"

/// 举报
let Api_CReport_CreateReportViolation = "/customer/reportViolation/createReportViolation"


// MARK: - 活动参与端问卷接口

/// 问卷答题提交
let Api_CActivityQuest_SubmitQuestionaireAnswer = "/customer/activityQuestionaire/submitQuestionaireAnswer"

/// 问卷详情
let Api_CActivityQuest_GetQuestionaireDetail = "/customer/activityQuestionaire/getQuestionaireDetail"

// MARK: - 活动参与端事件接口

/// 获取事件详情
let Api_CEvent_GetEventDetail = "/customer/event/getEventDetail"

/// 事件报名参与
let Api_CEvent_SignEvent = "/customer/event/signEvent"

// MARK: - 活动参与端发起支付

/// 发起微信支付
let Api_CPay_Wechat = "/phone/wechat/dopay"

/// 发起支付宝支付
let Api_CPay_Alipay = "/phone/alipay/dopay"


// MARK: - 活动参与端咨询接口

/// 参与端获取活动咨询详情
let Api_CAChat_GetActivityChatInfo = "/customer/activityChat/getActivityChatInfo"

/// 参与端回复咨询
let Api_CAChat_CreateActivityChat = "/customer/activityChat/createActivityChat"

/// 参与端获取活动报名群详情
let Api_CAChat_GetActivitySignChatInfo = "/customer/activityChat/getActivitySignChatInfo"

/// 参与端发表报名群信息
let Api_CAChat_CreateActivitySignChat = "/customer/activityChat/createActivitySignChat"


// MARK: - 活动发布端咨询接口

/// 发布端获取活动咨询详情
let Api_PAChat_GetActivityChatInfo = "/phone/activityChat/getActivityChatInfo"

/// 发布端回复咨询
let Api_PAChat_ReplyActivityChat = "/phone/activityChat/replyActivityChat"

/// 发布端获取活动报名群消息列表
let Api_PAChat_GetActivitySignChatInfo = "/phone/activityChat/getActivitySignChatInfo"

/// 发布端回复报名群
let Api_PAChat_ReplyActivitySignChat = "/phone/activityChat/replyActivitySignChat"

/// 发布端工作群消息列表
let Api_PAChat_GetActivityWorkChatInfo = "/phone/activityChat/getActivityWorkChatInfo"

/// 发布端回复工作群
let Api_PAChat_ReplyActivityWorkChat = "/phone/activityChat/replyActivityWorkChat"
