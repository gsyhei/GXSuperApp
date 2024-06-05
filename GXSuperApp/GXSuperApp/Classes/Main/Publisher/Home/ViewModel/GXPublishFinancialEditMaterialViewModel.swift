//
//  GXPublishFinancialEditMaterialViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/23.
//

import UIKit
import RxRelay

class GXPublishFinancialEditMaterialViewModel: GXBaseViewModel {
    /// 活动data
    var activityData: GXActivityBaseInfoData!
    /// 物料ID
    var materialId: Int?
    /// 物料data
    var data: GXActivityfinancesListItem? {
        didSet {
            guard let item = data else { return }

            self.materialId = item.id
            self.materialName.accept(item.materialName)
            self.materialNumber.accept("\(item.quantity)")
            self.unitPrice.accept(String(format: "%.2f", item.unitPrice))
            self.totalPrice.accept(String(format: "%.2f", item.totalPrice))
        }
    }
    /// 物料名称
    var materialName = BehaviorRelay<String?>(value: nil)
    /// 数量
    var materialNumber = BehaviorRelay<String?>(value: "1")
    /// 单价
    var unitPrice = BehaviorRelay<String?>(value: "0.00")
    /// 小计
    var totalPrice = BehaviorRelay<String?>(value: nil)

    func requestSaveFinance(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        if let materialId = self.materialId {
            self.requestUpdateFinance(id: materialId, success: success, failure: failure)
        } else {
            self.requestAddFinance(success: success, failure: failure)
        }
    }

}

private extension GXPublishFinancialEditMaterialViewModel {
    func requestAddFinance(success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let materialData = GXActivityfinancesListItem()
        materialData.creatorId = GXUserManager.shared.user?.id ?? 0
        materialData.activityId = self.activityData.id
        materialData.materialName = self.materialName.value ?? ""
        materialData.quantity = NSDecimalNumber(string: self.materialNumber.value).intValue
        materialData.unitPrice = NSDecimalNumber(string: self.unitPrice.value).floatValue
        materialData.totalPrice = NSDecimalNumber(string: self.totalPrice.value).floatValue

        guard let params = materialData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Finance_AddFinance, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            if let materialId = model.data as? Int {
                self.materialId = materialId
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    func requestUpdateFinance(id: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let materialData = GXActivityfinancesListItem()
        materialData.creatorId = GXUserManager.shared.user?.id ?? 0
        materialData.activityId = self.activityData.id
        materialData.id = id
        materialData.materialName = self.materialName.value ?? ""
        materialData.quantity = NSDecimalNumber(string: self.materialNumber.value).intValue
        materialData.unitPrice = NSDecimalNumber(string: self.unitPrice.value).floatValue
        materialData.totalPrice = NSDecimalNumber(string: self.totalPrice.value).floatValue

        guard let params = materialData.toJSON() else { return }
        let api = GXApi.normalApi(Api_Finance_UpdateFinance, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXBaseDataModel.self, success: { model in
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
