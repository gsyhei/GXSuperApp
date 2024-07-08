//
//  GXChargingOrderDetailsViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import PromiseKit

class GXChargingOrderDetailsViewModel: GXBaseViewModel {
    /// 订单ID
    var orderId: Int = 0
    
    /// 订单详情data
    var detailData: GXChargingOrderDetailData? {
        didSet {
            self.updateSectionIndexs()
        }
    }
    
    /// 动态cell配置
    var sectionIndexs: [[Int]] = [
        [0],
        [1, 2, 3, 4, 5],
        [6],
        [7],
        [8]
    ]
    
    
    let mockString = "{\"success\":true,\"code\":200,\"msg\":\"success\",\"data\":{\"id\":21,\"orderNo\":1802534546537844736,\"stationId\":2,\"stationName\":\"站点1\",\"pointId\":1,\"pointIdStr\":\"sin\",\"connectorId\":2,\"connectorIdStr\":\"2\",\"qrcode\":\"1800793239574417408\",\"startTime\":\"2024-06-16 22:51:41\",\"endTime\":\"2024-06-16 22:55:37\",\"occupyStartTime\":\"2024-06-16 22:56:37\",\"occupyEndTime\":\"2024-06-16 23:15:40\",\"carNumber\":\"AK123456\",\"orderStatus\":\"OCCUPY\",\"meterTotal\":0.16,\"powerFee\":0.1,\"serviceFee\":0.04,\"occupyFee\":3.06,\"totalFee\":3.2,\"actualFee\":3.2,\"payTime\":\"2024-06-27 06:49:36\",\"payType\":\"BALANCE\",\"chargingFeeDetails\":[{\"periodStart\":\"06:51:41\",\"periodEnd\":\"06:55:37\",\"periodType\":\"ORDINARY\",\"meter\":0.16,\"electricPrice\":0.62,\"servicePrice\":0.22,\"totalFee\":0.13}],\"occupyFreePeriod\":\"2024-06-17 06:55:00 2024-06-17 06:55:00\",\"occupyFeeDetails\":[{\"periodStart\":\"06:56:00\",\"periodEnd\":\"15:40:00\",\"minutes\":18,\"price\":0.17,\"fee\":3.06}],\"exemptType\":\"\",\"complainAvailable\":false,\"complainId\":\"\",\"freeParking\":\"这里是免费停车介绍\",\"chargingDuration\":\"\",\"power\":0,\"voltage\":0,\"current\":0,\"soc\":0,\"countdown\":\"\",\"occupyFlag\":\"YES\",\"occupyPrice\":0.17}}"
    /// 枪扫二维码
    func requestOrderConsumerDetail() -> Promise<GXChargingOrderDetailModel?> {
        var params: Dictionary<String, Any> = [:]
        params["id"] = self.orderId
        let api = GXApi.normalApi(Api_order_consumer_detail, params, .get)
//        return Promise { seal in
//            GXNWProvider.login_request(api, type: GXChargingOrderDetailModel.self, success: { model in
//                self.detailData = model.data
//                seal.fulfill(model)
//            }, failure: { error in
//                seal.reject(error)
//            })
//        }
        return Promise { seal in
            let model = GXChargingOrderDetailModel.deserialize(from: self.mockString)
            self.detailData = model?.data
            seal.fulfill(model)
        }
    }
    
}

extension GXChargingOrderDetailsViewModel {
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
        
        switch detail.orderStatus {
        case "OCCUPY":
            if let occupyStartTime = GXUserManager.shared.paramsData?.occupyStartTime, detail.countdown > 0 {
                if detail.countdown <= occupyStartTime * 60 { /// 收取占位费倒计时
                    sectionCellIndexs.append(row1Indexs)
                    
                    // 添加section 2
                    let row2Indexs: [Int] = [8]
                    /// 添加rows: 占位费倒计时
                    sectionCellIndexs.append(row2Indexs)
                    
                    /// 添加rows: 停车减免描述
                    if detail.freeParking.count > 0 {
                        // 添加section 3
                        let row3Indexs: [Int] = [7]
                        sectionCellIndexs.append(row3Indexs)
                    }
                }
                else { /// 还未开始倒计时
                    /// 添加rows: 充电总费用
                    row1Indexs.append(5)
                    sectionCellIndexs.append(row1Indexs)
                }
            }
            else { /// 产生占位费
                /// 添加rows: 占位费单
                row1Indexs.append(3)
                /// 添加rows: 占位费
                row1Indexs.append(9) //占位费总计
                sectionCellIndexs.append(row1Indexs)
                
                /// 添加rows: 停车减免描述
                if detail.freeParking.count > 0 {
                    // 添加section 2
                    let row2Indexs: [Int] = [7]
                    sectionCellIndexs.append(row2Indexs)
                }
            }
        case "TO_PAY":
            if detail.occupyFeeDetails.count > 0 {
                /// 添加rows: 占位费单
                row1Indexs.append(3)
            }
            /// 添加rows: 充电总费用
            row1Indexs.append(5)
            sectionCellIndexs.append(row1Indexs)
            
            // 添加section 2
            let row2Indexs: [Int] = [6]
            /// 添加rows: 余额
            sectionCellIndexs.append(row2Indexs)

        case "FINISHED":
            if detail.occupyFeeDetails.count > 0 {
                /// 添加rows: 占位费单
                row1Indexs.append(3)
            }
            /// 添加rows: 支付费用
            row1Indexs.append(4)
            sectionCellIndexs.append(row1Indexs)

            /// 添加rows: 停车减免描述
            if detail.freeParking.count > 0 {
                // 添加section 2
                let row2Indexs: [Int] = [7]
                sectionCellIndexs.append(row2Indexs)
            }
        default: break
        }
        self.sectionIndexs = sectionCellIndexs
    }
    
}
