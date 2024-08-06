//
//  GXChargingLaunchStatusVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/8/6.
//

import UIKit

class GXChargingLaunchStatusVC: GXBaseViewController {
    @IBOutlet weak var failedView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Launch Failed"
        self.gx_addBackBarButtonItem()
        self.gx_addNavTopView(color: .white)
    }
    
}

extension GXChargingLaunchStatusVC {
    @IBAction func scanButtonClicked(_ sender: Any?) {
        
    }
}
