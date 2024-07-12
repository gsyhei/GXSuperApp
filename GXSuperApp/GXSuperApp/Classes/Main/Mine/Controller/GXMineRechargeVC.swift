//
//  GXMineRechargeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit

class GXMineRechargeVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = ""
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .white]
        let gradientImage = UIImage(gradientColors: colors, style: .obliqueDown, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage
    }

}
