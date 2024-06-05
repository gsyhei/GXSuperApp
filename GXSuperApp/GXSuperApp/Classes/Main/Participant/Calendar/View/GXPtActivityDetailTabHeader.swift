//
//  GXPtActivityDetailTabHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit

import GXSegmentPageView
import Reusable

class GXPtActivityDetailTabHeader: UITableViewHeaderFooterView, Reusable {

    lazy var segmentTitleView: GXSegmentTitleView = {
        let rect = CGRect(x: 0, y: 10, width: SCREEN_WIDTH, height: 34)
        return GXSegmentTitleView(frame: rect)
    }()

    private lazy var config: GXSegmentTitleView.Configuration = {
        return GXSegmentTitleView.Configuration().then {
            $0.indicatorColor = .gx_green
            $0.indicatorFixedHeight = 3.0
            $0.indicatorFixedWidth = 30.0
            $0.titleNormalFont = .gx_boldFont(size: 15)
            $0.titleSelectedFont = .gx_boldFont(size: 15)
            $0.titleNormalColor = .gx_gray
            $0.titleSelectedColor = .gx_textBlack
            $0.titleFixedWidth = 32.0 + "详情".width(font: .gx_boldFont(size: 15))
            $0.isShowBottomLine = false
            $0.isTitleZoom = false
        }
    }()

    private lazy var titles: [String] = []

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.segmentTitleView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindView(titles: [String]) {
        self.titles = titles
        self.segmentTitleView.setupSegmentTitleView(config: self.config, titles: titles)
    }

}
