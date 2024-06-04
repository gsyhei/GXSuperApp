//
//  GXConfigTableRowButtonCell.swift
//  GXConfigTableViewVCSample
//
//  Created by Gin on 2023/11/1.
//

import UIKit
import RxSwift

public class GXConfigTableRowButtonCell: UITableViewCell {
    public var disposeBag = DisposeBag()
    public var model: GXConfigTableRowDefaultModel?
    
    public lazy var button: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = self.contentView.bounds
        btn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        btn.isUserInteractionEnabled = false
        
        return btn
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.button)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.accessoryView = nil
    }
    
    public func bind<T: GXConfigTableRowButtonModel>(model: T) {
        self.model = model
        
        self.button.titleLabel?.numberOfLines = model.titleNumberOfLines
        if let titleFont = model.titleFont {
            self.button.titleLabel?.font = titleFont
        }
        
        if let titleColor = model.titleColor {
            self.button.setTitleColor(titleColor, for: .normal)
        }

        model.title.bind {[weak self] text in
            self?.button.setTitle(text, for: .normal)
        }.disposed(by: disposeBag)
        
        model.image.bind {[weak self] image in
            self?.button.setImage(image, for: .normal)
        }.disposed(by: disposeBag)
    }

}
