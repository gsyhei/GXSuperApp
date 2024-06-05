//
//  GXPublishQuestionnaireOptionHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/20.
//

import UIKit
import Reusable

class GXPublishQuestionnaireOptionHeader: UITableViewHeaderFooterView, Reusable {
    var editAction: GXActionBlockItem<GXPublishQuestionnaireOptionHeader>?
    var section: Int = 0

    private lazy var lineView: UIView = {
        return UIView(frame: .zero).then {
            $0.backgroundColor = .gx_drakGreen
        }
    }()

    private lazy var editButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            $0.setImage(UIImage(named: "a_edit_icon"), for: .normal)
            $0.addTarget(self, action: #selector(self.editButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 14.0)
        }
    }()

    private lazy var questionnaireNameLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 14.0)
        }
    }()

    private lazy var questionnaireDescLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_gray
            $0.font = .gx_font(size: 12.0)
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        self.contentView.addSubview(self.lineView)
        self.contentView.addSubview(self.editButton)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.questionnaireNameLabel)
        self.contentView.addSubview(self.questionnaireDescLabel)

        self.lineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(CGSize(width: 2, height: 12))
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.lineView)
            make.left.equalTo(self.lineView.snp.right).offset(4)
        }
        self.editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(self.lineView)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        self.questionnaireNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.lineView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        self.questionnaireDescLabel.snp.makeConstraints { make in
            make.top.equalTo(self.questionnaireNameLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
    
    func bindView(model: GXQuestionairetopicsModel, section: Int) {
        self.section = section
        self.titleLabel.text = "题目\(section + 1)"
        self.questionnaireNameLabel.text = model.topicTitle
        self.questionnaireDescLabel.text = model.topicDesc
    }
}

extension GXPublishQuestionnaireOptionHeader {
    @objc func editButtonClicked(_ sender: UIButton) {
        self.editAction?(self)
    }

}
