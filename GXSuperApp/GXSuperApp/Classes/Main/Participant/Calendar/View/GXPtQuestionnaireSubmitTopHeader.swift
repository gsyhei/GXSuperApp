//
//  GXPtQuestionnaireSubmitTopHeader.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/31.
//

import UIKit
import Reusable
import Kingfisher

class GXPtQuestionnaireSubmitTopHeader: UITableViewHeaderFooterView, Reusable {
    private lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_boldFont(size: 18.0)
            $0.numberOfLines = 0
        }
    }()

    private lazy var detailLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_black
            $0.font = .gx_font(size: 14.0)
            $0.numberOfLines = 0
        }
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.backgroundView = nil
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)

        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        self.detailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindView(model: GXPublishQuestionaireDetailData?) {
        guard let data = model else { return }
        self.titleLabel.text = data.questionaireName
        self.detailLabel.text = data.questionaireDesc
    }

}
