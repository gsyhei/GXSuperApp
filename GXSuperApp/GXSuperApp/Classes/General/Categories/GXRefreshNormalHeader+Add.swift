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
        self.setRefreshTitles("Tap or pull up to load more", for: .idle)
        self.setRefreshTitles("Pull up to load more", for: .pulling)
        self.setRefreshTitles("Release to load more", for: .will)
        self.setRefreshTitles("Loading...", for: .did)
        self.setRefreshTitles("一 No more 一", for: .noMore)
    }
}
