//
//  GXHomeSearchViewModel.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/17.
//

import UIKit
import RxRelay
import GooglePlaces
import XCGLogger
import PromiseKit

class GXHomeSearchViewModel: GXBaseViewModel {
    enum SearchType {
        /// 历史
        case history
        /// 自动补全文本
        case autocomplete
        /// 搜索结果
        case result
        /// 充电站数据
        case data
    }
    /// 活动名称搜素
    var searchWord = BehaviorRelay<String?>(value: nil)
    /// 当前搜索类型
    var searchType: SearchType = .history
    /// 分页
    var pageNum: Int = 1
    /// 自动补全
    var autocompleteList: [GMSAutocompleteSuggestion] = []
    /// 地址搜素
    var placeResults: [GMSPlace] = []
    
}

extension GXHomeSearchViewModel {
    
    func requestAutocomplete() -> Promise<[GMSAutocompleteSuggestion]> {
        return Promise { seal in
            guard let searchText = self.searchWord.value else { return }
            let token = GMSAutocompleteSessionToken()
            let filter = GMSAutocompleteFilter()
            filter.origin = CLLocation(latitude: 37.7749, longitude: -122.4194)
            let request = GMSAutocompleteRequest(query: searchText)
            request.filter = filter
            request.sessionToken = token
            GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request, callback: { results, error in
                if let error = error {
                    seal.reject(error)
                } 
                else if let results = results, results.count > 0 {
                    self.autocompleteList = results
                    seal.fulfill(results)
                }
                else {
                    seal.reject(PMKError.emptySequence)
                }
            })
        }
    }
    
    func requestSearchByText() -> Promise<[GMSPlace]> {
        return Promise { seal in
            guard let searchText = self.searchWord.value else { return }
            let properties = [
                GMSPlaceProperty.name,
                GMSPlaceProperty.placeID,
                GMSPlaceProperty.coordinate,
                GMSPlaceProperty.formattedAddress,
            ].map {$0.rawValue}
            let request = GMSPlaceSearchByTextRequest(textQuery: searchText, placeProperties: properties)
            request.isOpenNow = false
            request.maxResultCount = 20
            request.rankPreference = .distance
            GMSPlacesClient.shared().searchByText(with: request) { results, error in
                if let error = error {
                    seal.reject(error)
                }
                else if let results = results, results.count > 0 {
                    self.placeResults = results
                    seal.fulfill(results)
                }
                else {
                    seal.reject(PMKError.emptySequence)
                }
            }
        }
    }
    
}
