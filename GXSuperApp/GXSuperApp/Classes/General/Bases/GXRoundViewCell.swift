//
//  GXRoundViewCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit

class GXRoundViewCell: UITableViewCell {
    var layoutSubviewsAction: GXActionBlock?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutSubviewsAction?()
    }
}
