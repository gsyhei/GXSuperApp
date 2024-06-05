//
//  GXParticipantHomeDtBannerCell.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import Reusable
import GXBanner

class GXParticipantHomeDtBannerCell: UITableViewCell, Reusable {
    lazy var banner: GXBanner = {
        let frame: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 96)
        return GXBanner(frame: frame, margin: 12, lineSpacing: 12).then {
            $0.backgroundColor = UIColor.gx_background
            $0.pageControl.currentPageIndicatorTintColor = .gx_green
            $0.autoTimeInterval = 5.0
            $0.isAutoPlay = true
            $0.dataSource = self
            $0.delegate = self
            $0.register(classCellType: GXParticipantHomeDtBannerConCell.self)
        }
    }()
    private var bannerList: [GXPtHomeListBannerItem] = []
    var bannerAction: GXActionBlockItem<GXPtHomeListBannerItem>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.contentView.backgroundColor = .gx_background
        self.contentView.addSubview(self.banner)
        self.banner.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindCell(list: [GXPtHomeListBannerItem]) {
        self.bannerList = list
        self.banner.reloadData()
    }
}

extension GXParticipantHomeDtBannerCell: GXBannerDataSource, GXBannerDelegate {
    // MARK: - GXBannerDataSource
    func numberOfItems() -> Int {
        return self.bannerList.count
    }
    func banner(_ banner: GXBanner, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXParticipantHomeDtBannerConCell = banner.dequeueReusableCell(for: indexPath)
        let model = self.bannerList[indexPath.item]
        cell.bindCell(model: model)

        return cell
    }
    // MARK: - GXBannerDelegate
    func banner(_ banner: GXBanner, didSelectItemAt indexPath: IndexPath) {
        NSLog("didSelectItemAt %d", indexPath.row)
        let model = self.bannerList[indexPath.item]
        self.bannerAction?(model)
    }
}
