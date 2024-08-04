//
//  GXOrderAppealViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import PromiseKit
import HXPhotoPicker
import RxRelay

class GXOrderAppealViewModel: GXBaseViewModel {
    /// 订单详情model
    var detailCellModel: GXChargingOrderDetailCellModel?
    /// 申诉详情
    var complainData: OrderConsumerComplainDetailData?
    /// 站点充电价格
    var priceData: GXStationConsumerPriceData?
    /// 申诉描述
    var descInput = BehaviorRelay<String?>(value: nil)
    /// 申诉图片-最大9张
    var images: [PhotoAsset] = []
    /// 选择的申诉类型
    var selectedAppealTypeIds: [Int] = []
    /// isOpen
    var isOpenDetail: Bool = false
    
    /// 申诉详情
    func requestOrderConsumerComplainDetail() -> Promise<OrderConsumerComplainDetailModel?> {
        return Promise { seal in
            guard let complainId = self.detailCellModel?.item.complainId else {
                seal.fulfill(nil); return
            }
            var params: Dictionary<String, Any> = [:]
            params["complainId"] = complainId
            let api = GXApi.normalApi(Api_order_consumer_complain_detail, params, .get)
            GXNWProvider.login_request(api, type: OrderConsumerComplainDetailModel.self, success: { model in
                self.complainData = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 场站服务- 3：申诉类型
    func requestDictListAvailable() -> Promise<GXDictListAvailableModel?> {
        var params: Dictionary<String, Any> = [:]
        params["typeId"] = 3
        let api = GXApi.normalApi(Api_dict_list_available, params, .get)
        return Promise { seal in
            if GXUserManager.shared.appealTypeList.count > 0 {
                seal.fulfill(nil); return
            }
            GXNWProvider.login_request(api, type: GXDictListAvailableModel.self, success: { model in
                GXUserManager.shared.appealTypeList = model.data
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
    /// 站点充电价格
    func requestStationConsumerPrice(stationId: Int?) -> Promise<GXStationConsumerPriceModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = stationId
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
    
    /// 订单申诉
    func requestOrderConsumerComplainSave() -> Promise<GXBaseModel> {
        var params: Dictionary<String, Any> = [:]
        params["orderId"] = self.detailCellModel?.item.id
        params["typeIds"] = self.selectedAppealTypeIds
        params["reason"] = self.descInput.value ?? ""
        if self.images.count > 0 {
            params["photos"] = PhotoAsset.gx_imageUrlStrings(assets: self.images)
        }
        let api = GXApi.normalApi(Api_order_consumer_complain_save, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXBaseModel.self, success: { model in
                seal.fulfill(model)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}

extension GXOrderAppealViewModel {
    func updateDataSource(item: GXChargingOrderDetailData) {
        var rowsIndexs: [Int] = []
        /// 添加rows: 场站使用信息
        rowsIndexs.append(1)
        //"orderStatus" //订单状态；CHARGING：充电中，OCCUPY：占位中，TO_PAY：待支付，FINISHED：已完成支付
        switch item.orderStatus {
        case "CHARGING":
            /// 添加View
            break
        case "OCCUPY":
            /// 添加View
            break
        case "TO_PAY":
            /// 添加rows: Charging Bill
            rowsIndexs.append(2)
            /// 添加rows: 占位费单Idle Fee Bill
            if item.occupyFeeDetails.count > 0 {
                rowsIndexs.append(3)
            }
            /// 添加rows: 充电总费用
            rowsIndexs.append(5)
            /// 添加More、Pay
        case "FINISHED":
            /// 添加rows: Charging Bill
            rowsIndexs.append(2)
            /// 添加rows: 占位费单Idle Fee Bill
            if item.occupyFeeDetails.count > 0 {
                rowsIndexs.append(3)
            }
            /// 添加rows: 支付费用
            rowsIndexs.append(4)
            /// 添加More
        default: break
        }
        self.detailCellModel = GXChargingOrderDetailCellModel(item: item, rowsIndexs: rowsIndexs)
    }
}
