//
//  GXBaseWarnViewController.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/12.
//

import UIKit

class GXBaseWarnViewController: GXBaseViewController {
    @IBOutlet weak var warningTopLC: NSLayoutConstraint!

    private var constant: CGFloat?
    private(set) lazy var warningView: GXApproveFailInfoView = {
        return GXApproveFailInfoView.xibView()
    }()

    /// 显示警告视图
    /// - Parameters:
    ///   - text: 警告文本
    ///   - constant: 原warningTopLC.constant
    ///   - augmentTop: warningTopLC增加的top
    ///   - augmentHeight: warningTopLC增加的height
    func gx_showWarning(text: String, topView: UIView? = nil, constant: CGFloat = 0, augmentTop: CGFloat = 0, augmentHeight: CGFloat = 0) {
        self.warningView.update(to: self.view, text: text)
        self.warningView.alpha = 0
        self.constant = constant
        if let topView = topView {
            self.view.insertSubview(self.warningView, belowSubview: topView)
            self.warningView.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(constant + augmentTop)
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(self.warningView.frame.height)
            }
        }
        else {
            self.view.addSubview(self.warningView)
            self.warningView.snp.makeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(constant + augmentTop)
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
                make.height.equalTo(self.warningView.frame.height)
            }
        }
        self.view.layoutIfNeeded()
        let warningTopConstant = self.warningView.frame.height + constant + augmentTop + augmentHeight
        UIView.animate(withDuration: 0.3) {
            self.warningView.alpha = 1
            self.warningTopLC.constant = warningTopConstant
            self.view.layoutIfNeeded()
        }
    }

    /// 隐藏移除警告视图
    func gx_hideWarning() {
        guard let constant = self.constant else { return }
        UIView.animate(withDuration: 0.3) {
            self.warningView.alpha = 0
            self.warningTopLC.constant = constant
            self.view.layoutIfNeeded()
        } completion: { finished in
            self.warningView.removeFromSuperview()
        }
    }
}
