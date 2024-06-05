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
    }
}

extension GXRefreshBaseFooter {
    func updateRefreshTitles() {
        self.setRefreshTitles("已经到底咯~", for: .noMore)
        self.textLabel.textColor = .gx_drakGray
        self.textLabel.font = .gx_font(size: 12.0)
    }
}
