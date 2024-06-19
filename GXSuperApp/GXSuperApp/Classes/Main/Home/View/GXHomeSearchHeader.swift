//
//  GXHomeSearchHeader.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit
import Reusable
import PromiseKit

class GXHomeSearchHeader: UITableViewHeaderFooterView, Reusable {
    private lazy var deleteButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setImage(UIImage(named: "search_list_ic_delete"), for: .normal)
            $0.contentHorizontalAlignment = .right
            $0.addTarget(self, action: #selector(self.deleteButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    
    private lazy var iconIView: UIImageView = {
        return UIImageView(image: UIImage(named: "search_list_ic_history"))
    }()
    
    private lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_textBlack
            $0.font = .gx_semiBoldFont(size: 18)
        }
    }()
    var deleteAction: GXActionBlock?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = .white
        
        self.contentView.addSubview(self.iconIView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.deleteButton)
        
        self.iconIView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.iconIView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(44)
        }
    }
    
    @objc func deleteButtonClicked(_ sender: Any?) {
        self.deleteAction?()
    }

    func updateHeader(name: String, iconName: String, isShowButton: Bool = false){
        self.nameLabel.text = name
        self.iconIView.image = UIImage(named: iconName)
        self.deleteButton.isHidden = !isShowButton
    }
    
}
