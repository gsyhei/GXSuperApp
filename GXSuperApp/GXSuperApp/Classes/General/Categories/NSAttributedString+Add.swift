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
    
    func width() -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: CGFLOAT_MAX, height: CGFLOAT_MAX),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return rect.width
    }

}


extension NSAttributedString {
    enum StationType {
    case tsl
    case us
    }
    
    class func gx_stationAttrText(type: StationType, isSelected: Bool, count: Int, maxCount: Int, fontSize: CGFloat = 13) -> NSAttributedString {
        let countFont: UIFont = .gx_boldFont(size: fontSize)
        let maxCountFont: UIFont = .gx_font(size: fontSize)
        var countTextColor: UIColor, maxCountTextColor: UIColor
        if isSelected {
            countTextColor = .white
            maxCountTextColor = .white
        }
        else {
            if count == maxCount {
                countTextColor = .gx_drakGray
                maxCountTextColor = .gx_drakGray
            }
            else {
                if type == .tsl {
                    countTextColor = .gx_drakRed
                    maxCountTextColor = .gx_markerLightRed
                }
                else {
                    countTextColor = .gx_blue
                    maxCountTextColor = .gx_markerLightBlue
                }
            }
        }
        
        let attributedString = NSMutableAttributedString()
        let numberText = String(format: "%d", count)
        let numAttributes: [NSAttributedString.Key : Any] = [
            .font: countFont,
            .foregroundColor: countTextColor
        ]
        let numberAttrStr = NSAttributedString(string: numberText, attributes: numAttributes)
        attributedString.append(numberAttrStr)
        
        let centerText = " / "
        let centerAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: fontSize - 1),
            .baselineOffset: 1,
            .foregroundColor: maxCountTextColor
        ]
        let centerAttrStr = NSAttributedString(string: centerText, attributes: centerAttributes)
        attributedString.append(centerAttrStr)

        let maxNumberText = String(format: "%d", maxCount)
        let maxNumAttributes: [NSAttributedString.Key : Any] = [
            .font: maxCountFont,
            .foregroundColor: maxCountTextColor
        ]
        let maxNumAttrStr = NSAttributedString(string: maxNumberText, attributes: maxNumAttributes)
        attributedString.append(maxNumAttrStr)
        
        return attributedString
    }
    
    class func gx_strikethroughText(_ text: String, color: UIColor, font: UIFont) -> NSAttributedString {
        let attrDic: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSNumber(value: 1),
            .foregroundColor: color,
            .font: font
        ]
        return NSAttributedString(string: text, attributes: attrDic)
    }
    
}
