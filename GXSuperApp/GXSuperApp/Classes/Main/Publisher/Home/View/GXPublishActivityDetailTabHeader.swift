//
//  GXPublishActivityDetailTabHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/13.
//

import UIKit
import GXSegmentPageView
import Reusable

class GXPublishActivityDetailTabHeader: UITableViewHeaderFooterView, Reusable {

    lazy var segmentTitleView: GXSegmentTitleView = {
        let rect = CGRect(x: 0, y: 10, width: SCREEN_WIDTH, height: 34)
        return GXSegmentTitleView(frame: rect, config: self.config, titles: self.titles)
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
            $0.titleFixedWidth = SCREEN_WIDTH/CGFloat(self.titles.count)
            $0.isShowBottomLine = false
            $0.isTitleZoom = false
        }
    }()

    private lazy var titles: [String] = {
        return ["详情", "地图", "成员", "问卷", "事件", "回顾", "财务", "汇报"]
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.segmentTitleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
