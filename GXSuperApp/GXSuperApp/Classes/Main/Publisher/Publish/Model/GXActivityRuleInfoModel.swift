//
//  GXActivityRuleInfoModel.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/8.
//

import UIKit
import HandyJSON

class GXActivityRuleInfoData: NSObject, HandyJSON {
    var dressCode: String = ""
    var normalBenefits: String = ""
    var ruleContent: String = ""
    var vipBenefits: String = ""

    override required init() {}

    func compositeText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_boldFont(size: 17),
            .foregroundColor: UIColor.gx_black,
            .paragraphStyle: paragraphStyle
        ]
        let greenAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 15),
            .foregroundColor: UIColor.gx_drakGreen
        ]

        let conParagraphStyle = NSMutableParagraphStyle()
        conParagraphStyle.lineBreakMode = .byWordWrapping
        conParagraphStyle.hyphenationFactor = 1.0
        conParagraphStyle.lineSpacing = 2.0
        let contentAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 15),
            .foregroundColor: UIColor.gx_black,
            .paragraphStyle: conParagraphStyle
        ]
        let lineParagraphStyle = NSMutableParagraphStyle()
        lineParagraphStyle.lineSpacing = 10.0
        let lineAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 4),
            .paragraphStyle: lineParagraphStyle
        ]

        if self.dressCode.count > 0 {
            let titleAtt = NSAttributedString(string: "活动要求", attributes: titleAttributes)
            attributedString.append(titleAtt)
            let dressCodeAtt = NSAttributedString(string: "\n" + self.dressCode, attributes: contentAttributes)
            attributedString.append(dressCodeAtt)
        }
        if self.normalBenefits.count > 0 || self.vipBenefits.count > 0 {
            if attributedString.length > 0 {
                let lineAtt = NSAttributedString(string: " \n\n", attributes: lineAttributes)
                attributedString.append(lineAtt)
            }
            let flAtt = NSAttributedString(string: "福利", attributes: titleAttributes)
            attributedString.append(flAtt)
            if self.normalBenefits.count > 0 {
                let nbTitleAtt = NSAttributedString(string: "\n" + "普通用户福利：", attributes: greenAttributes)
                attributedString.append(nbTitleAtt)
                let nbAtt = NSAttributedString(string: self.normalBenefits, attributes: contentAttributes)
                attributedString.append(nbAtt)
            }
            if self.vipBenefits.count > 0 {
                let vbTitleAtt = NSAttributedString(string: "\n" + "VIP用户福利：", attributes: greenAttributes)
                attributedString.append(vbTitleAtt)
                let nbAtt = NSAttributedString(string: self.vipBenefits, attributes: contentAttributes)
                attributedString.append(nbAtt)
            }
        }
        if self.ruleContent.count > 0 {
            if attributedString.length > 0 {
                let lineAtt = NSAttributedString(string: " \n\n", attributes: lineAttributes)
                attributedString.append(lineAtt)
            }
            let titleAtt = NSAttributedString(string: "注意事项", attributes: titleAttributes)
            attributedString.append(titleAtt)
            let rcAtt = NSAttributedString(string: "\n" + self.ruleContent, attributes: contentAttributes)
            attributedString.append(rcAtt)
        }
        return attributedString
    }
}

class GXActivityRuleInfoModel: GXBaseModel {
    var data: GXActivityRuleInfoData?
}
