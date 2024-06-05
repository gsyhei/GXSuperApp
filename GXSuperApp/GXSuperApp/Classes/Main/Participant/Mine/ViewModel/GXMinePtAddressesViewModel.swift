//
//  GXMinePtAddressesViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit

class GXMinePtAddressesViewModel: GXBaseViewModel {
    /// 分页
    var pageNum: Int = 1
    /// 粉丝/关注
    var list: [GXUserAddressPageItem] = []

    /// 我的地址
    func requestGetUserAddressPage(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
        }
        var params: Dictionary<String, Any> = [:]
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUserAddress_Page, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXUserAddressPageModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            if refresh { self.list.removeAll() }
            guard let data = model.data else {
                success(false); return
            }
            self.list.append(contentsOf: data.list)
            self.pageNum = data.pageNum + 1
            success(data.pageNum >= data.totalPage)
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 删除地址
    func requestAddressDeleteById(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let model = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["id"] = model.id
        let api = GXApi.normalApi(Api_CUserAddress_DeleteById, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXMinePtOrderDetailModel.self, success: { model in
            self.list.remove(at: index)
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }

    /// 设置默认地址
    func requestSetDefaultAddress(index: Int, success:@escaping(() -> Void), failure:@escaping GXFailure) {
        let model = self.list[index]
        var params: Dictionary<String, Any> = [:]
        params["id"] = model.id
        let api = GXApi.normalApi(Api_CUserAddress_SetDefaultAddress, params, .post)
        let cancellable = GXNWProvider.login_request(api, type: GXMinePtOrderDetailModel.self, success: {[weak self] model in
            guard let `self` = self else { return }
            for itemIndex in 0..<self.list.count {
                let toModel = self.list[itemIndex]
                toModel.defaultAddress = (itemIndex == index) ? 1 : 0
            }
            success()
        }, failure: failure)
        self.gx_addCancellable(cancellable)
    }
}
