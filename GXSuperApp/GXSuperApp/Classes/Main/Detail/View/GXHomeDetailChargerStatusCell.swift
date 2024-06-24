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
        self.progressBar.setProgress(to: 0.75, animated: false)
        
        self.chargerButton.backgroundColor = .gx_lightBlue
        self.chargerButton.setTitleColor(.gx_blue, for: .normal)
        self.chargerButton.setTitle("75%", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

private extension GXHomeDetailChargerStatusCell {
    @IBAction func copyButtonClicked(_ sender: Any?) {
        
    }
}
