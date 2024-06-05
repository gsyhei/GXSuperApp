//
//  GXMinePrWithdrawDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/17.
//

import UIKit
import MBProgressHUD

class GXMinePrWithdrawDetailVC: GXBaseViewController {
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var withdrawInfoTi1Label: UILabel!
    @IBOutlet weak var withdrawInfoTi2Label: UILabel!
    @IBOutlet weak var withdrawInfo1Label: UILabel!
    @IBOutlet weak var withdrawInfo2Label: UILabel!

    private lazy var viewModel: GXMinePrWithdrawDetailViewModel = {
        return GXMinePrWithdrawDetailViewModel()
    }()
    
    class func createVC(item: GXFundjoursItem) -> GXMinePrWithdrawDetailVC {
        return GXMinePrWithdrawDetailVC.xibViewController().then {
            $0.viewModel.item = item
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestGetWithdrawDetail()
    }

    override func setupViewController() {
        self.title = "提现记录"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)

        self.statusButton.setImage(nil, for: .normal)
        self.statusButton.setTitle(nil, for: .normal)
        self.statusInfoLabel.text = nil
        self.withdrawInfo1Label.text = nil
        self.withdrawInfo2Label.text = nil

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_font(size: 15),
            .foregroundColor: UIColor.gx_drakGray,
            .paragraphStyle: paragraphStyle
        ]
        let infoTi1 = NSAttributedString(string: self.withdrawInfoTi1Label.text ?? "", attributes: titleAttributes)
        let infoTi2 = NSAttributedString(string: self.withdrawInfoTi2Label.text ?? "", attributes: titleAttributes)
        self.withdrawInfoTi1Label.attributedText = infoTi1
        self.withdrawInfoTi2Label.attributedText = infoTi2
    }
}

extension GXMinePrWithdrawDetailVC {
    func requestGetWithdrawDetail() {
        MBProgressHUD.showLoading(to: self.view)
        self.viewModel.requestGetWithdrawDetail(success: {[weak self] in
            guard let `self` = self else { return }
            MBProgressHUD.dismiss(for: self.view)
            self.updateWithdrawDetail()
        }, failure: {[weak self] error in
            MBProgressHUD.dismiss(for: self?.view)
            GXToast.showError(error, to: self?.view)
        })
    }
    func updateWithdrawDetail() {
        guard let data = self.viewModel.data else { return }
        // applyStatus提现状态 0-待处理 1-已审核 2-已拒绝
        switch data.applyStatus {
        case 0: //待处理
            self.statusButton.setTitleColor(.gx_yellow, for: .normal)
            self.statusButton.setImage(UIImage(named: "pr_withdraw_audit"), for: .normal)
            self.statusButton.setTitle("审核中", for: .normal)
            self.statusInfoLabel.text = nil
        case 1: //已审核
            self.statusButton.setTitleColor(.gx_drakGreen, for: .normal)
            self.statusButton.setImage(UIImage(named: "pr_withdraw_ok"), for: .normal)
            self.statusButton.setTitle("已通过，请等待线下打款", for: .normal)
            self.statusInfoLabel.text = nil
        case 2: //已拒绝
            self.statusButton.setTitleColor(.gx_red, for: .normal)
            self.statusButton.setImage(UIImage(named: "pr_withdraw_err"), for: .normal)
            self.statusButton.setTitle("未通过", for: .normal)
            self.statusInfoLabel.text = "未通过原因：" + data.rejectReason
        default: break
        }
        
        var info1 = data.createTime
        info1 += "\n" + String(data.userId)
        info1 += "\n" + data.nickName

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.gx_boldFont(size: 15),
            .foregroundColor: UIColor.gx_black,
            .paragraphStyle: paragraphStyle
        ]
        self.withdrawInfo1Label.attributedText = NSAttributedString(string: info1, attributes: titleAttributes)

        var info2 = "￥" + data.entrustBalance
        info2 += "\n￥" + data.withdrawalFee
        info2 += "\n" + data.alipayAccount
        info2 += "\n" + data.realName
        self.withdrawInfo2Label.attributedText = NSAttributedString(string: info2, attributes: titleAttributes)
    }
}
