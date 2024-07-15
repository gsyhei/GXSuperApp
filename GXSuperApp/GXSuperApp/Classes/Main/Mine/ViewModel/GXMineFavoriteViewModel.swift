//
//  GXMineFavoriteViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/14.
//

import UIKit
import PromiseKit

class GXMineFavoriteViewModel: GXBaseViewModel {
    /// 站点
    var list: [GXFavoriteConsumerListItem] = []
    
    /// 站点收藏列表
    func requesFavoriteConsumerList(isRefresh: Bool) -> Promise<(GXFavoriteConsumerListModel, Bool)> {
        return Promise { seal in
            var params: Dictionary<String, Any> = [:]
            if let coordinate = GXLocationManager.shared.currentLocation?.coordinate {
                params["lat"] = String(coordinate.latitude)
                params["lng"] = String(coordinate.longitude)
            }
            if isRefresh {
                params["pageNum"] = 1
            }
            else {
                params["pageNum"] = 1 + (self.list.count + PAGE_SIZE - 1)/PAGE_SIZE
            }
            params["pageSize"] = PAGE_SIZE
            let api = GXApi.normalApi(Api_favorite_consumer_list, params, .get)
            GXNWProvider.login_request(api, type: GXFavoriteConsumerListModel.self, success: { model in
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
    
    /// 收藏/取消收藏
    func requestFavoriteConsumerSaveDelete(indexPath: IndexPath) -> Promise<Bool> {
        let model = self.list[indexPath.section]
        var params: Dictionary<String, Any> = [:]
        params["stationId"] = model.stationId
        let api = GXApi.normalApi(Api_favorite_consumer_save, params, .post)
        return Promise { seal in
            GXNWProvider.login_request(api, type: GXFavoriteConsumerSaveModel.self, success: { model in
                let isFavorite = model.data?.favoriteFlag ?? false
                seal.fulfill(isFavorite)
            }, failure: { error in
                seal.reject(error)
            })
        }
    }
    
}
