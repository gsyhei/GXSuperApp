//
//  GXVipVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/13.
//

import UIKit

class GXVipVC: GXBaseViewController {
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var renewButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var infoTextView: GXLinkTextView!
    @IBOutlet weak var infoTVHeightLC: NSLayoutConstraint!
    @IBOutlet weak var contentBottomLC: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
}
