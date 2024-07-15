//
//  GXVipVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit
import Kingfisher
import MBProgressHUD
import PromiseKit

class GXVipVC: GXBaseViewController {
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var renewButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var infoTextView: GXLinkTextView!
    @IBOutlet weak var infoTVHeightLC: NSLayoutConstraint!
    @IBOutlet weak var contentBottomLC: NSLayoutConstraint!
    @IBOutlet weak var vipImageView: UIImageView!
    @IBOutlet weak var vipImageHeightLC: NSLayoutConstraint!
    @IBOutlet weak var vipYearLabel: UILabel!

    private lazy var viewModel: GXVipViewModel = {
        return GXVipViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestParamConsumer()
    }
    
    override func setupViewController() {
        self.infoTextView.gx_setMarginZero()
        self.infoTextView.attributedText = nil
        self.infoTextView.gx_appendLink(string: "Activating implies agreement to the ")
        self.infoTextView.gx_appendLink(string: "\"Membership Service Agreement\"", color: UIColor.gx_green, urlString: "yhxy")
        self.infoTextView.gx_appendLink(string: " and ")
        self.infoTextView.gx_appendLink(string: "\"Automatic Renewal Terms\"", color: UIColor.gx_green, urlString: "yszc")
        self.infoTVHeightLC.constant = self.infoTextView.attributedText.height(width: SCREEN_WIDTH - 54)
        self.infoTextView.delegate = self
        
        let bgColors: [UIColor] = [UIColor(hexString: "#FFE7C3"), .white]
        let backImage = UIImage(gradientColors: bgColors, style: .vertical)
        self.backgroudImageView.image = backImage
        
        self.confirmButton.isEnabled = false
        self.confirmButton.setTitleColor(.white, for: .disabled)
        self.confirmButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.confirmButton.setBackgroundColor(.gx_black, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGray, for: .highlighted)
        let joinTitle = self.confirmButton.title(for: .normal) ?? "Join"
        let joinFont = self.confirmButton.titleLabel?.font ?? .gx_boldFont(size: 16)
        let joinSize = CGSize(width: joinTitle.width(font: joinFont), height: joinFont.lineHeight)
        let colors: [UIColor] = [UIColor(hexString: "#FFF8B5"), UIColor(hexString: "#CD661D")]
        if let gradientImage = UIImage(gradientColors: colors, style: .horizontal, size: joinSize) {
            let textColor = UIColor(patternImage: gradientImage)
            self.confirmButton.setTitleColor(textColor, for: .normal)
        }
        self.renewButton.isEnabled = false
        self.renewButton.setTitleColor(.white, for: .disabled)
        self.renewButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.renewButton.setBackgroundColor(.gx_black, for: .normal)
        self.renewButton.setBackgroundColor(.gx_drakGray, for: .highlighted)
        let renewTitle = self.renewButton.title(for: .normal) ?? "Renew"
        let renewFont = self.renewButton.titleLabel?.font ?? .gx_boldFont(size: 16)
        let renewSize = CGSize(width: renewTitle.width(font: renewFont), height: renewFont.lineHeight)
        if let gradientImage = UIImage(gradientColors: colors, style: .horizontal, size: renewSize) {
            let textColor = UIColor(patternImage: gradientImage)
            self.renewButton.setTitleColor(textColor, for: .normal)
        }
        
        self.updateDataSource()
    }
    
    func updateDataSource() {
        if GXUserManager.shared.isVip {
            self.navigationItem.title = "VIP for Discounts"
            self.renewButton.isHidden = false
            self.confirmButton.isHidden = true
            self.contentBottomLC.constant = 30
        }
        else {
            self.navigationItem.title = "Become a VIP"
            self.renewButton.isHidden = true
            self.confirmButton.isHidden = false
            self.contentBottomLC.constant = 90
        }
        if let params = GXUserManager.shared.paramsData {
            // params.memberDescription
            self.vipImageView.kf.setImage(with: URL(string: "https://img.zcool.cn/community/01944d5cd14772a801208f8be3cb63.jpg@1280w_1l_2o_100sh.jpg")) { result in
                switch result {
                case .success(let image):
                    self.vipImageHeightLC.constant = self.getImageViewHeight(image: image.image)
                    self.view.layoutIfNeeded()
                case .failure(_): break
                }
            }
            self.vipYearLabel.text = "$ \(params.memberFee)"
        }
    }
    
}

private extension GXVipVC {
    
    func requestParamConsumer() {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestParamConsumer()
        }.done { models in
            MBProgressHUD.dismiss()
            self.updateDataSource()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }
    
    func getImageViewHeight(image: UIImage) -> CGFloat {
        let scale = image.size.height / image.size.width
        return (SCREEN_WIDTH - 24) * scale
    }
}

extension GXVipVC: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }

    func didLinkScheme(_ scheme: String) {
        
    }
}

private extension GXVipVC {
    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.confirmButton.isEnabled = sender.isSelected
        self.renewButton.isEnabled = sender.isSelected
    }
}
