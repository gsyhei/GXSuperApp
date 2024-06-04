//
//  GXConfigTableRowDefaultCell.swift
//  GXConfigTableViewVCSample
//
//  Created by Gin on 2023/10/31.
//

import UIKit
import RxSwift

public class GXConfigTableRowDefaultCell: UITableViewCell {
    public var disposeBag = DisposeBag()
    public var model: GXConfigTableRowDefaultModel?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let letModel = self.model else { return }
        if self.imageView?.image != nil {
            var ivRect: CGRect = self.imageView?.frame ?? .zero
            ivRect.origin.x = letModel.contentMargin
            self.imageView?.frame = ivRect
        }

        guard letModel.isMember(of: GXConfigTableRowDefaultModel.self) else { return }
        guard letModel.style == .value1 else { return }
        guard letModel.titleNumberOfLines != letModel.detailNumberOfLines else { return }

        if let letTextLabel = self.textLabel, let letDetailLabel = self.detailTextLabel {
            if letModel.titleNumberOfLines > letModel.detailNumberOfLines {
                var detailRect = letDetailLabel.frame
                detailRect.size.height = letTextLabel.frame.height
                letDetailLabel.frame = detailRect
            }
            else {
                var textRect = letTextLabel.frame
                textRect.size.height = letDetailLabel.frame.height
                letTextLabel.frame = textRect
            }
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.accessoryView = nil
    }

    public func bind<T: GXConfigTableRowDefaultModel>(model: T) {
        self.model = model

        self.backgroundColor = model.backgroundColor
        self.indentationLevel = 2
        self.indentationWidth = model.contentMargin/CGFloat(self.indentationLevel)
        self.separatorInset = model.separatorInset
        self.selectionStyle = (model.action == nil) ? .none : .default
        self.accessoryType = (model.action == nil) ? .none : .disclosureIndicator

        if let selectedColor = model.selectedColor {
            self.selectedBackgroundView = UIView(frame: self.bounds)
            self.selectedBackgroundView?.backgroundColor = selectedColor
        }

        self.textLabel?.numberOfLines = model.titleNumberOfLines
        self.detailTextLabel?.numberOfLines = model.detailNumberOfLines

        if let titleFont = model.titleFont {
            self.textLabel?.font = titleFont
        }
        if let titleColor = model.titleColor {
            self.textLabel?.textColor = titleColor
        }
        if let detailFont = model.detailFont {
            self.detailTextLabel?.font = detailFont
        }
        if let detailColor = model.detailColor {
            self.detailTextLabel?.textColor = detailColor
        }

        model.title.bind {[weak self] text in
            self?.textLabel?.text = text
        }.disposed(by: disposeBag)

        model.detail.bind {[weak self] text in
            self?.detailTextLabel?.text = text
        }.disposed(by: disposeBag)

        model.image.bind {[weak self] image in
            self?.imageView?.image = image
        }.disposed(by: disposeBag)
    }

}
