//
//  GXChargingOrderDetailsViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import PromiseKit
import XCGLogger

class GXChargingCarShowViewModel: GXBaseViewModel {
    /// 订单ID
    var orderId: Int = 0
    
    /// 订单详情data
    var detailData: GXChargingOrderDetailData? {
        didSet {
            self.updateCountdownRequests()
        }
    }
    
    /// 倒计时计数器
    private var countdown: Int = 0
    
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    
    /// 站点充电价格
    var priceData: GXStationConsumerPriceData?
    
    /// 自动更新详情数据
    var autouUpdateDetailAction: GXActionBlockItem<Bool>?
    
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
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 钱包余额
    func requestWalletConsumerBalance() -> Promise<GXWalletConsumerBalanceModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_wallet_consumer_balance, params, .get)
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
    
}

extension GXChargingCarShowViewModel {
    func updateCountdownRequests() {
        guard let detail = self.detailData else { return }
        
        if detail.orderStatus == "CHARGING" {
            /// 先清除倒计时调用
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            /// 订单刷新倒计时
            self.perform(#selector(self.updateOrderStateNext), with: nil, afterDelay: 5)
        }
        else {
            self.autouUpdateDetailAction?(false)
        }
    }
    
    @objc func updateOrderStateNext() {
        firstly {
            self.requestOrderConsumerDetail()
        }.done { model in
            self.autouUpdateDetailAction?(true)
        }.catch { error in
            XCGLogger.info(error.localizedDescription)
        }
    }
}
