//
//  GXActivityTypeListView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/11/30.
//

import UIKit

class GXActivityTypeListView: UIView {
    var list: [GXActivityTypeItem] = []
    var selectItem: GXActivityTypeItem? = nil
    var selectedAction: GXActionBlockItem<Int?>?

    func updateList(list: [GXActivityTypeItem], typeId: Int? = nil, viewWidth: CGFloat = SCREEN_WIDTH) -> CGFloat {
        self.removeAllSubviews()
        self.list = list
        if let letTypeID = typeId {
            self.selectItem = self.list.filter({ $0.id == letTypeID }).first
        }
//        else {
//            self.selectItem = self.list.first
//            self.selectedAction?(self.selectItem?.id)
//        }

        let column: Int = 3
        let space: CGFloat = 8.0
        let width: CGFloat = (viewWidth - 32.0 - CGFloat(column-1)*space) / CGFloat(column)
        let height: CGFloat = 32.0

        var frameHeight: CGFloat = 0
        for index in 0..<list.count {
            let row: Int = index % column, section: Int = index / column
            let top: CGFloat = CGFloat(section) * (space + height)
            let left: CGFloat = CGFloat(row) * (space + width)
            
            let item = list[index]
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: left, y: top, width: width, height: height)
            button.setTitle(item.activityTypeName, for: .normal)
            button.setTitleColor(.gx_textBlack, for: .normal)
            button.setBackgroundColor(.white, for: .normal)
            button.setBackgroundColor(.gx_green, for: .highlighted)
            button.setBackgroundColor(.gx_green, for: .selected)
            button.titleLabel?.font = .gx_font(size: 15)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 2.0
            button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
            button.tag = index
            button.isSelected = (item == self.selectItem)
            self.addSubview(button)

            if index == list.count - 1 {
                frameHeight = button.bottom
            }
        }

        return frameHeight
    }

    func setSelected(typeId: Int?) {
        if let letTypeID = typeId {
            self.selectItem = self.list.filter({ $0.id == letTypeID }).first
        }
        else {
            self.selectItem = self.list.first
        }
        if let item = self.selectItem {
            if let index = self.list.firstIndex(of: item) {
                self.setSelected(index: index)
            }
        }
    }

    func setSelected(index: Int) {
        self.subviews.forEach { (subview) in
            if let btn = subview as? UIButton {
                if btn.tag == index {
                    btn.isSelected = true
                }
                else {
                    btn.isSelected = false
                }
            }
        }
    }

    @objc func buttonClicked(_ sender: UIButton) {
        self.setSelected(index: sender.tag)
        self.selectItem = self.list[sender.tag]
        self.selectedAction?(self.selectItem?.id)
    }

}
