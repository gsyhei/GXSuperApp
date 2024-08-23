//
//  GXHomeDetailChargerCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/23.
//

import UIKit
import Reusable

class GXHomeDetailChargerCell: UICollectionViewCell, NibReusable {
    @IBOutlet weak var chargerStatusLabel: UILabel!
    @IBOutlet weak var chargerNumLabel: UILabel!
    @IBOutlet weak var maximumPowerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 6.0
        self.progressView.isHidden = true
    }
    
    func bindCell(model: GXConnectorConsumerRowsItem?) {
        guard let model = model else { return }
        
        self.chargerNumLabel.text = model.qrcode
        self.maximumPowerLabel.text = String(format: "%gKW", Float(model.maxPower)/1000.0)
        if model.idleFlag == GX_YES {
            switch model.status {
            case "Available":
                self.backgroundColor = .gx_lightGreen
                self.chargerStatusLabel.textColor = .gx_green
                self.chargerStatusLabel.text = model.status
                self.progressView.isHidden = true
                break
            case "Charging", "Finishing":
                self.backgroundColor = .gx_lightBlue
                self.chargerStatusLabel.textColor = .gx_blue
                self.chargerStatusLabel.text = "\(model.soc)%"
                self.progressView.isHidden = false
                self.progressView.setProgress(Float(model.soc)/100.0, animated: false)
                break
            default:
                self.backgroundColor = .gx_background
                self.chargerStatusLabel.textColor = .gx_drakGray
                self.chargerStatusLabel.text = model.status
                self.progressView.isHidden = true
                break
            }
        }
        else {
            self.backgroundColor = .gx_background
            self.chargerStatusLabel.textColor = .gx_drakGray
            self.chargerStatusLabel.text = model.status
            self.progressView.isHidden = true
        }
    }
}

private extension GXHomeDetailChargerCell {
    @IBAction func copyButtonClicked(_ sender: Any?) {
        UIPasteboard.general.string = self.chargerNumLabel.text
        GXToast.showSuccess(text: "Copied to pasteboard", to: self.superview?.superview)
    }
}

