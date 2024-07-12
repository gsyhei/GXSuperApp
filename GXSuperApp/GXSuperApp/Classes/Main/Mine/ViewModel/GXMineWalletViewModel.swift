//
//  GXMineStatementViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import PromiseKit

class GXMineWalletViewModel: GXBaseViewModel {
    /// 钱包余额
    var balanceData: GXWalletConsumerBalanceData?
    /// 明细列表
    var list: [GXWalletConsumerListRowsItem] = []
    
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
    /// 钱包明细
    func requestWalletConsumerList(isRefresh: Bool) -> Promise<(GXWalletConsumerListModel, Bool)> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            if isRefresh {
                params["pageNum"] = 1
            }
            else {
                params["pageNum"] = 1 + (self.list.count + PAGE_SIZE - 1)/PAGE_SIZE
            }
            params["pageSize"] = PAGE_SIZE
            let api = GXApi.normalApi(Api_wallet_consumer_list, params, .get)
            GXNWProvider.login_request(api, type: GXWalletConsumerListModel.self, success: { model in
                guard let data = model.data else {
                    seal.fulfill((model, false)); return
                }
                if isRefresh { self.list.removeAll() }
                self.list.append(contentsOf: data.rows)
                seal.fulfill((model, self.list.count >= data.total))
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
