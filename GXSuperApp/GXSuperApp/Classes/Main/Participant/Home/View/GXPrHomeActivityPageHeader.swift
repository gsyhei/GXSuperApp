//
//  GXPrHomePageHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/24.
//

import UIKit
import Reusable

class GXPrHomePageHeaderBtnCell: UICollectionViewCell, Reusable {
    override var isSelected: Bool {
        didSet {
            self.typeButton.isSelected = self.isSelected
        }
    }

    lazy var typeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.titleLabel?.font = .gx_font(size: 12)
            $0.setTitleColor(.gx_black, for: .normal)
            $0.setBackgroundColor(.white, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .selected)
            $0.layer.masksToBounds = true
            $0.isUserInteractionEnabled = false
        }
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.typeButton.layer.cornerRadius = self.frame.height/2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.typeButton)
        self.typeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GXPrHomeActivityPageHeader: UITableViewHeaderFooterView, Reusable {
    private lazy var leftLineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_green
        }
    }()
    private lazy var leftButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("即将开售", for: .normal)
            $0.setTitleColor(.gx_drakGray, for: .normal)
            $0.setTitleColor(.gx_black, for: .selected)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.contentVerticalAlignment = .bottom
            $0.addTarget(self, action: #selector(self.leftButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    private lazy var rightLineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_green
        }
    }()
    private lazy var rightButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("预售早鸟", for: .normal)
            $0.setTitleColor(.gx_drakGray, for: .normal)
            $0.setTitleColor(.gx_black, for: .selected)
            $0.titleLabel?.font = .gx_font(size: 15)
            $0.contentVerticalAlignment = .bottom
            $0.addTarget(self, action: #selector(self.rightButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var moreButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("更多活动", for: .normal)
            $0.setTitleColor(.gx_gray, for: .normal)
            $0.titleLabel?.font = .gx_font(size: 13)
            $0.setImage(UIImage(named: "a_arraw_r"), for: .normal)
            $0.addTarget(self, action: #selector(self.moreButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.backgroundColor = .gx_background
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.dataSource = self
            $0.delegate = self
            $0.allowsMultipleSelection = true
            $0.register(cellType: GXPrHomePageHeaderBtnCell.self)
        }
    }()

    weak var viewModel: GXParticipantHomeFindViewModel?
    var activityTypeList: [GXPrHomeListActivityTypeItem] = []
    var reloadPageAction: GXActionBlock?
    var reloadFilterAction: GXActionBlock?
    var reloadMoreAction: GXActionBlock?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(24)
        }

        self.contentView.addSubview(self.leftLineView)
        self.contentView.addSubview(self.rightLineView)
        self.contentView.addSubview(self.leftButton)
        self.contentView.addSubview(self.rightButton)
        self.contentView.addSubview(self.moreButton)
        self.leftButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalTo(self.collectionView.snp.top).offset(-4)
        }
        self.rightButton.snp.makeConstraints { make in
            make.left.equalTo(self.leftButton.snp.right).offset(24)
            make.bottom.equalTo(self.collectionView.snp.top).offset(-4)
        }
        self.leftLineView.snp.makeConstraints { make in
            make.left.right.equalTo(self.leftButton)
            make.bottom.equalTo(self.leftButton.snp.bottom).offset(-7)
            make.height.equalTo(7.0)
        }
        self.rightLineView.snp.makeConstraints { make in
            make.left.right.equalTo(self.rightButton)
            make.bottom.equalTo(self.leftButton.snp.bottom).offset(-7)
            make.height.equalTo(7.0)
        }
        self.moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.collectionView.snp.top).offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.moreButton.imageLocationAdjust(model: .right, spacing: 2.0)
    }

    func bindView(viewModel: GXParticipantHomeFindViewModel) {
        self.viewModel = viewModel
        
        let allItem = GXPrHomeListActivityTypeItem()
        allItem.activityTypeName = "全部"
        self.activityTypeList = [allItem] + GXActivityManager.shared.activityTypeList

        self.collectionView.reloadData()
        if viewModel.activityTypeIds.count > 0 {
            for typeId in viewModel.activityTypeIds {
                if let index = self.activityTypeList.firstIndex(where: {$0.id == typeId}) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
            }
        }
        self.selectTabType(index: viewModel.tabType - 1)
    }

    func selectTabType(index: Int) {
        if index == 0 {
            self.leftButton.isSelected = true
            self.leftButton.titleLabel?.font = .gx_boldFont(size: 18)
            self.leftLineView.isHidden = false
            self.rightButton.isSelected = false
            self.rightButton.titleLabel?.font = .gx_font(size: 15)
            self.rightLineView.isHidden = true
        }
        else {
            self.leftButton.isSelected = false
            self.leftButton.titleLabel?.font = .gx_font(size: 15)
            self.leftLineView.isHidden = true
            self.rightButton.isSelected = true
            self.rightButton.titleLabel?.font = .gx_boldFont(size: 18)
            self.rightLineView.isHidden = false
        }
    }

    @objc func leftButtonClicked(_ sender: UIButton) {
        self.selectTabType(index: 0)
        self.viewModel?.tabType = 1
        self.reloadPageAction?()
    }

    @objc func rightButtonClicked(_ sender: UIButton) {
        self.selectTabType(index: 1)
        self.viewModel?.tabType = 2
        self.reloadPageAction?()
    }

    @objc func moreButtonClicked(_ sender: UIButton) {
        self.reloadMoreAction?()
    }
}

extension GXPrHomeActivityPageHeader: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activityTypeList.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXPrHomePageHeaderBtnCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.activityTypeList[indexPath.item]
        cell.typeButton.setTitle(model.activityTypeName, for: .normal)

        return cell
    }
}

extension GXPrHomeActivityPageHeader: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = self.activityTypeList[indexPath.item]
        let width = data.activityTypeName.width(font: .gx_font(size: 12)) + 20.0

        return CGSize(width: width, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            self.reloadFilterAction?()
            return false
        }
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.viewModel?.activityTypeIds.removeAll()
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            let data = self.activityTypeList[indexPath.item]
            self.viewModel?.activityTypeIds.append(data.id)
        }
        self.reloadPageAction?()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.activityTypeIds.removeAll()
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            let data = self.activityTypeList[indexPath.item]
            self.viewModel?.activityTypeIds.append(data.id)
        }
        self.reloadPageAction?()
    }

}
