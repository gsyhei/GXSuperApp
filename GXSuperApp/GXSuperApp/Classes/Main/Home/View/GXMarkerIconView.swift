//
//  GXMarkerIconView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit

class GXMarkerIconView: UIView {
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!

    class func createIconView() -> GXMarkerIconView {
        return GXMarkerIconView.xibView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 69, height: 50)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.gx_lightGray.cgColor
    }
    
    func updateNumber(usNumber: String, tslNumber: String) {
        self.usNumberLabel.text = usNumber
        let usWidth = usNumber.width(font: self.usNumberLabel.font)
        
        self.tslNumberLabel.text = tslNumber
        let tslWidth = usNumber.width(font: self.tslNumberLabel.font)
        
        let width = max(usWidth, tslWidth)
        self.frame.size.width = width + 58
    }
    
}
