//
//  GXPrHomeActivitySignHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/25.
//

import UIKit
import Reusable

class GXPrHomeActivitySignHeader: UITableViewHeaderFooterView, Reusable {
    private lazy var leftLineView: UIView = {
        return UIView().then {
            $0.backgroundColor = .gx_green
        }
    }()
    private lazy var leftButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("进行中", for: .normal)
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
            $0.setTitle("即将开始", for: .normal)
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

    var isShowAll: Bool = false
    var selectedIndex: Int = 0
    var mySignAction: GXActionBlockItem<Int>?
    var reloadMoreAction: GXActionBlock?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.leftLineView)
        self.contentView.addSubview(self.rightLineView)
        self.contentView.addSubview(self.leftButton)
        self.contentView.addSubview(self.rightButton)
        self.contentView.addSubview(self.moreButton)

        self.leftButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-4)
        }
        self.rightButton.snp.makeConstraints { make in
            make.left.equalTo(self.leftButton.snp.right).offset(24)
            make.bottom.equalToSuperview().offset(-4)
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
            make.bottom.equalTo(self.leftButton.snp.bottom).offset(-5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.moreButton.imageLocationAdjust(model: .right, spacing: 2.0)
    }
    
    func bindView(mySignIndex: Int, isShowAll: Bool) {
        self.selectTabType(index: mySignIndex, isShowAll: isShowAll)
    }

    func selectTabType(index: Int, isShowAll: Bool) {
        self.isShowAll = isShowAll
        self.selectedIndex = index
        if isShowAll {
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
        else {
            if index == 0 {
                self.leftButton.setTitle("进行中", for: .normal)
            }
            else {
                self.leftButton.setTitle("即将开始", for: .normal)
            }
            self.leftButton.isSelected = true
            self.leftButton.titleLabel?.font = .gx_boldFont(size: 18)
            self.leftLineView.isHidden = false
            self.rightButton.isHidden = true
            self.rightLineView.isHidden = true
        }
    }

    @objc func leftButtonClicked(_ sender: UIButton) {
        if self.isShowAll {
            self.selectTabType(index: 0, isShowAll: self.isShowAll)
            self.mySignAction?(0)
        }
        else {
            self.selectTabType(index: self.selectedIndex, isShowAll: self.isShowAll)
            self.mySignAction?(self.selectedIndex)
        }
    }

    @objc func rightButtonClicked(_ sender: UIButton) {
        if self.isShowAll {
            self.selectTabType(index: 1, isShowAll: self.isShowAll)
            self.mySignAction?(1)
        }
    }
    
    @objc func moreButtonClicked(_ sender: UIButton) {
        self.reloadMoreAction?()
    }
}
