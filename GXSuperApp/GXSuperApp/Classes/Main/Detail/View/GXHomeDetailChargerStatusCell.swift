//
//  GXHomeDetailChargerStatusCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable

class GXHomeDetailChargerStatusCell: UITableViewCell, NibReusable {
    @IBOutlet weak var chargerButton: UIButton!
    @IBOutlet weak var chargerNumLabel: UILabel!
    @IBOutlet weak var maximumPowerLabel: UILabel!
    
    private lazy var progressBar: GXCircleProgressBar = {
        return GXCircleProgressBar(frame: CGRect(x: 0, y: 0, width: 44, height: 44), lineWidth: 3.0)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        
        self.chargerButton.addSubview(self.progressBar)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: GXConnectorConsumerRowsItem?) {
        guard let model = model else { return }
        
        self.chargerNumLabel.text = model.qrcode
        self.maximumPowerLabel.text = "\(model.maxPower)KW"
        if model.idleFlag == GX_YES {
            switch model.status {
            case "Available", "Preparing":
                self.chargerButton.backgroundColor = .gx_lightGreen
                self.chargerButton.setTitleColor(.gx_green, for: .normal)
                self.chargerButton.setTitle("Idle", for: .normal)
                self.chargerButton.setImage(nil, for: .normal)
                self.progressBar.isHidden = true
                break
            case "Charging", "Finishing":
                self.chargerButton.backgroundColor = .gx_lightBlue
                self.chargerButton.setTitleColor(.gx_blue, for: .normal)
                self.chargerButton.setTitle("\(model.soc)%", for: .normal)
                self.chargerButton.setImage(nil, for: .normal)
                self.progressBar.isHidden = false
                self.progressBar.setProgress(to: CGFloat(model.soc)/100.0, animated: false)
                break
            default: 
                self.chargerButton.backgroundColor = .gx_background
                self.chargerButton.setTitleColor(.gx_drakGray, for: .normal)
                self.chargerButton.setTitle(nil, for: .normal)
                self.chargerButton.setImage(UIImage(named: "details_list_ic_fault"), for: .normal)
                self.progressBar.isHidden = true
                break
            }
        }
        else {
            self.chargerButton.backgroundColor = .gx_background
            self.chargerButton.setTitleColor(.gx_drakGray, for: .normal)
            self.chargerButton.setTitle(nil, for: .normal)
            self.chargerButton.setImage(UIImage(named: "details_list_ic_fault"), for: .normal)
            self.progressBar.isHidden = true
        }
    }
}

private extension GXHomeDetailChargerStatusCell {
    @IBAction func copyButtonClicked(_ sender: Any?) {
        UIPasteboard.general.string = self.chargerNumLabel.text
        GXToast.showSuccess(text: "Copied to pasteboard", to: self.superview?.superview)
    }
}
