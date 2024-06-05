//
//  GXTagsView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/2/27.
//

import UIKit

class GXTagsView: UIView {
    private static let font = UIFont.gx_font(size: 10)
    private static let tagsTitle = ["VIP", "机构认证", "官方认证", "达人"]

    func updateTags(isVip: Bool = false,
                    isJg: Bool = false,
                    isGf: Bool = false,
                    isDr: Bool = false) -> CGFloat {
        self.removeAllSubviews()
        var left: CGFloat = 0
        let height: CGFloat = self.frame.height
        if isVip {
            let width = GXTagsView.tagsTitle[0].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[0]
                $0.textColor = .gx_yellow
                $0.layer.borderColor = UIColor.gx_yellow.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        if isJg {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[1].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[1]
                $0.textColor = .gx_blue
                $0.layer.borderColor = UIColor.gx_blue.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        if isGf {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[2].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[2]
                $0.textColor = .gx_blue
                $0.layer.borderColor = UIColor.gx_blue.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        if isDr {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[3].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[3]
                $0.textColor = UIColor(hexString: "#8A38F5")
                $0.layer.borderColor = UIColor(hexString: "#8A38F5").cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        return left
    }
    
    func updateAllTags(isVip: Bool = false,
                       isJg: Bool = false,
                       isGf: Bool = false,
                       isDr: Bool = false) {
        self.removeAllSubviews()
        var left: CGFloat = 0
        let height: CGFloat = self.frame.height
        if isVip {
            let width = GXTagsView.tagsTitle[0].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[0]
                $0.textColor = .gx_yellow
                $0.layer.borderColor = UIColor.gx_yellow.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        if isJg {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[1].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[1]
                $0.textColor = .gx_blue
                $0.layer.borderColor = UIColor.gx_blue.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
        if isGf {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[2].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[2]
                $0.textColor = .gx_blue
                $0.layer.borderColor = UIColor.gx_blue.cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }

        let title = "实名"
        let width = title.width(font: GXTagsView.font) + 10
        let label = UILabel().then {
            $0.layer.borderWidth = 1.0
            $0.layer.masksToBounds = true
            $0.textAlignment = .center
            $0.font = GXTagsView.font
            $0.text = title
            $0.textColor = .gx_yellow
            $0.layer.borderColor = UIColor.gx_yellow.cgColor
            $0.layer.cornerRadius = height/2
            $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
        }
        self.addSubview(label)
        left += width

        if isDr {
            if left > 0 { left += 4.0 }
            let width = GXTagsView.tagsTitle[3].width(font: GXTagsView.font) + 10
            let label = UILabel().then {
                $0.layer.borderWidth = 1.0
                $0.layer.masksToBounds = true
                $0.textAlignment = .center
                $0.font = GXTagsView.font
                $0.text = GXTagsView.tagsTitle[3]
                $0.textColor = UIColor(hexString: "#8A38F5")
                $0.layer.borderColor = UIColor(hexString: "#8A38F5").cgColor
                $0.layer.cornerRadius = height/2
                $0.layer.frame = CGRect(x: left, y: 0, width: width, height: height)
            }
            self.addSubview(label)
            left += width
        }
    }
}
