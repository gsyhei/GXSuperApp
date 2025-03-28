//
//  GXChargingOrderDetailsViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import PromiseKit
import XCGLogger

class GXChargingOrderDetailsViewModel: GXBaseViewModel {
    /// 订单ID
    var orderId: Int = 0
    
    /// 订单详情data
    var detailData: GXChargingOrderDetailData?
    
    /// 倒计时计数器
    private var countdown: Int = 0
    
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    
    /// 站点充电价格
    var priceData: GXStationConsumerPriceData?
    
    /// 动态cell配置
    var sectionIndexs: [[Int]] = []
    
    /// 自动更新详情数据
    var autouUpdateDetailAction: GXActionBlock?
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }

    /// 订单详情
    func requestOrderConsumerDetail() -> Promise<GXChargingOrderDetailModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_order_consumer_detail, params, .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXChargingOrderDetailModel.self, success: { model in
                self.detailData = model.data
                self.updateSectionIndexs()
                seal.fulfill(model)
            }, failure: { error in
                self.updateSectionIndexs()
                seal.reject(error)
            })
        }
    }
    
    /// 钱包余额
    func requestWalletConsumerBalance() -> Promise<GXWalletConsumerBalanceModel?> {
        let api = GXApi.normalApi(Api_wallet_consumer_balance, [:], .get)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXWalletConsumerBalanceModel.self, success: { model in
                self.balanceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 站点充电价格
    func requestStationConsumerPrice() -> Promise<GXStationConsumerPriceModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.detailData?.stationId
        let api = GXApi.normalApi(Api_station_consumer_price, params, .get)
        return Promise { seal in
            if self.priceData != nil {
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXStationConsumerPriceModel.self, success: { model in
                self.priceData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 收藏站点
    func requestFavoriteConsumerSave() -> Promise<Bool> {
        var params: Dictionary<String, Any> = [:]
        params["stationId"] = self.detailData?.stationId
        let api = GXApi.normalApi(Api_favorite_consumer_save, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXFavoriteConsumerSaveModel.self, success: { model in
                let isFavorite = model.data?.favoriteFlag ?? false
                self.detailData?.favoriteFlag = isFavorite ? GX_YES : GX_NO
                seal.fulfill(isFavorite)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 订单支付-y余额支付
    func requestOrderConsumerPay() -> Promise<GXBaseDataModel> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_order_consumer_pay, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 订单支付-绑定的银行卡
    func requestOrderConsumerPayCard() -> Promise<GXBaseDataModel> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_order_consumer_pay_card, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}

private extension GXChargingOrderDetailsViewModel {
    func updateSectionIndexs() {
        guard let detail = detailData else { return }
        
        // MARK: - 订单详情没有充电中状态，充电中不处理
        //"orderStatus": "FINISHED", //订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成支付
        var sectionCellIndexs: [[Int]] = []
        
        // 添加section 0
        let row0Indexs: [Int] = [0]
        /// 添加section: 我的车辆
        sectionCellIndexs.append(row0Indexs)
        
        // 添加section 1
        var row1Indexs: [Int] = []
        /// 添加rows: 场站使用信息
        row1Indexs.append(1)
        /// 添加rows: Charging Bill
        row1Indexs.append(2)
        
        var isOccupyCountdownNext = false
        switch detail.orderStatus {
        case .OCCUPY:
            if let occupyStartTime = GXUserManager.shared.paramsData?.occupyStartTime {
                if detail.countdown <= occupyStartTime * 60 { /// 收取占位费倒计时
                    sectionCellIndexs.append(row1Indexs)
                    
                    // 添加section 2
                    let row2Indexs: [Int] = [8]
                    /// 添加rows: 占位费倒计时
                    sectionCellIndexs.append(row2Indexs)
                    
                    self.countdown = detail.countdown
                    isOccupyCountdownNext = true
                }
                else { /// 还未开始倒计时
                    /// 添加rows: 充电总费用
                    row1Indexs.append(5)
                    sectionCellIndexs.append(row1Indexs)
                }
            }
        case .TO_PAY:
            if detail.occupyFeeDetails.count > 0 {
                /// 添加rows: 占位费单Idle Fee Bill
                row1Indexs.append(3)
            }
            /// 添加rows: 充电总费用
            row1Indexs.append(5)
            sectionCellIndexs.append(row1Indexs)
            
            // 添加section 2
            let row2Indexs: [Int] = [6]
            /// 添加rows: 余额
            sectionCellIndexs.append(row2Indexs)

        case .FINISHED:
            if detail.occupyFeeDetails.count > 0 {
                /// 添加rows: 占位费单Idle Fee Bill
                row1Indexs.append(3)
            }
            /// 添加rows: 支付费用
            row1Indexs.append(4)
            sectionCellIndexs.append(row1Indexs)
        default: break
        }
        /// 添加rows: 停车减免描述
        if detail.freeParking.count > 0 {
            // 添加section 3
            let rowIndexs: [Int] = [7]
            sectionCellIndexs.append(rowIndexs)
        }
        self.sectionIndexs = sectionCellIndexs
        
        /// 先清除倒计时调用
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        /// 倒计时判断
        if isOccupyCountdownNext {
            self.perform(#selector(self.occupyCountdownNext), with: nil, afterDelay: 1)
        }
        /// 订单刷新倒计时
        if detail.orderStatus == .OCCUPY || detail.orderStatus == .PAYMENT {
            self.perform(#selector(self.updateOrderStateNext), with: nil, afterDelay: 5)
        }
    }
    
    @objc func occupyCountdownNext() {
        self.countdown -= 1
        NotificationCenter.default.post(name: GX_NotifName_OccupyCountdown, object: self.countdown)
        self.perform(#selector(self.occupyCountdownNext), with: nil, afterDelay: 1)
    }
    
    @objc func updateOrderStateNext() {
        firstly {
            self.requestOrderConsumerDetail()
        }.done { model in
            self.autouUpdateDetailAction?()
        }.catch { error in
            XCGLogger.info(error.localizedDescription)
        }
    }
}
