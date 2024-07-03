//
//  GXHomeDetailCell4.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit
import Reusable

class GXHomeDetailCell4: UITableViewCell, NibReusable {
    @IBOutlet weak var freeParkingLabel: UILabel!
    var addAction: GXActionBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addButtonClicked(_ sender: Any?) {
        self.addAction?()
    }
    
    
}
