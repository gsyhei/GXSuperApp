//
//  GXTicketsListViewModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import UIKit

class GXTicketsListViewModel: GXBaseViewModel {
    /// 门票状态 0-未使用 1-已使用
    var ticketStatus: Int = 0
    /// 分页
    var pageNum: Int = 1
    /// 默认展开
    var isAllOpen: Bool = true
    // MARK: - request
    /// 票列表
    var list: [GXListMyTicketItem] = []
    /// 选择索引
    var selectedIndexPaths: [IndexPath] = []

    /// 获取我的票夹
    func requestGetListMyTicket(refresh: Bool, success:@escaping((Bool) -> Void), failure:@escaping GXFailure) {
        if refresh {
            self.pageNum = 1
            self.selectedIndexPaths.removeAll()
        }
        var params: Dictionary<String, Any> = [:]
        params["ticketStatus"] = self.ticketStatus
        params["pageNum"] = self.pageNum
        params["pageSize"] = PAGE_SIZE

        let api = GXApi.normalApi(Api_CUser_ListMyTicket, params, .get)
        let cancellable = GXNWProvider.login_request(api, type: GXListMyTicketModel.self, success: {[weak self] model in
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
}
