//
//  GXConfigTableHeaderFooter.swift
//  GXConfigTableViewVCSample
//
//  Created by Gin on 2023/10/31.
//

import UIKit

public class GXConfigTableHeaderFooter: UITableViewHeaderFooterView {
    public var model: GXConfigTableSectionViewModel?

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let letModel = self.model else { return }

        self.textLabel?.numberOfLines = letModel.titleNumberOfLines
        if letModel.titleNumberOfLines == 1 {
            if let letTextLabel = self.textLabel {
                var rect = letTextLabel.frame
                rect.origin.x = letModel.contentMargin
                rect.origin.y = self.contentView.frame.height - rect.height - 5.0
                letTextLabel.frame = rect
            }
            if let detailLabel = self.detailTextLabel {
                var rect = detailLabel.frame
                rect.origin.x = self.contentView.frame.width - letModel.contentMargin - rect.width
                rect.origin.y = self.contentView.frame.height - rect.height - 5.0
                detailLabel.frame = rect
            }
        }
        else {
            if let letTextLabel = self.textLabel {
                var rect = letTextLabel.frame
                rect.origin.x = letModel.contentMargin
                rect.origin.y = 0
                rect.size.height = self.contentView.frame.height
                letTextLabel.frame = rect
            }
        }
    }

    public func bind(model: GXConfigTableSectionViewModel) {
        self.model = model

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
        self.textLabel?.text = model.title
        self.detailTextLabel?.text = model.detail
    }

}
