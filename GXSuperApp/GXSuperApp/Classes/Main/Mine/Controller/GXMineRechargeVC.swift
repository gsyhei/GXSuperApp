//
//  GXMineRechargeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import CollectionKit

class GXMineRechargeVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var confirmButton: UIButton!

    private var dataSource = ArrayDataSource<String>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.tag = index
            view.isUserInteractionEnabled = false
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 6.0
            view.titleLabel?.font = .gx_boldFont(size: 24)
            view.setTitle(data, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = floor((collectionSize.width - 24) / 3)
            return CGSize(width: width, height: 60)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                tapContext.view.isSelected = !tapContext.view.isSelected
            }
        )
        provider.layout = FlowLayout(spacing: 12).inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        return CollectionView(provider: provider)
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.setRoundedCorners([.topLeft, .topRight], radius: 8.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.gx_addBackBarButtonItem()
        
        let colors: [UIColor] = [.gx_green, .white]
        let gradientImage = UIImage(gradientColors: colors, style: .vertical, size: CGSize(width: 20, height: 10))
        self.topImageView.image = gradientImage

        self.confirmButton.setBackgroundColor(.gx_green, for: .normal)
        self.confirmButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        self.containerView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.bottom.equalToSuperview()
        }
        self.dataSource.data = ["$ 10", "$ 20", "$ 50", "$ 100", "$ 150", "$ 200", "$ 500"]
    }

}

private extension GXMineRechargeVC {
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    @IBAction func confirmButtonClicked(_ sender: UIButton) {

    }
}
