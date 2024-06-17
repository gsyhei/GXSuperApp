//
//  GXRefreshNormalHeader+Add.swift
//  QROrderSystem
//
//  Created by Gin on 2021/10/12.
//

import Foundation
import GXRefresh

extension GXRefreshBaseHeader {
    func updateRefreshTitles() {
        self.textLabel.textColor = .gx_drakGray
        self.textLabel.font = .gx_font(size: 14.0)
//        /// 刷新文本
//        private(set) lazy var refreshTitles: Dictionary<State, String> = {
//            return [.idle: "下拉刷新",
//                    .pulling: "下拉可以刷新",
//                    .will: "放开立即刷新",
//                    .did: "正在刷新...",
//                    .end: "刷新完成"]
//        }()
        self.setRefreshTitles("Pull down refresh", for: .idle)
        self.setRefreshTitles("Pull down to refresh", for: .pulling)
        self.setRefreshTitles("Release to refresh", for: .will)
        self.setRefreshTitles("Loading...", for: .did)
        self.setRefreshTitles("Refresh complete", for: .end)
    }
}

extension GXRefreshBaseFooter {
    func updateRefreshTitles() {
        self.textLabel.textColor = .gx_drakGray
        self.textLabel.font = .gx_font(size: 14.0)
//        self.isHiddenNoMoreByContent = false
//        return [.idle: "点击或上拉加载更多",
//                .pulling: "上拉加载更多",
//                .will: "放开立即加载更多",
//                .did: "正在加载更多数据...",
//                .noMore: "已加载全部数据"]
        self.setRefreshTitles("Tap or pull up to load more", for: .idle)
        self.setRefreshTitles("Pull up to load more", for: .pulling)
        self.setRefreshTitles("Release to load more", for: .will)
        self.setRefreshTitles("Loading...", for: .did)
        self.setRefreshTitles("—— No more ——", for: .noMore)
    }
}
