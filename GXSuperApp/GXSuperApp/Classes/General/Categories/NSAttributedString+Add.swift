//
//  NSAttributedString+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/29.
//

import UIKit

extension NSAttributedString {

    func height(width: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: width, height: CGFLOAT_MAX),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return rect.height
    }

}
