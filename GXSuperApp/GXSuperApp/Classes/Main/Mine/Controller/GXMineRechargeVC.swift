//
//  GXMineRechargeVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import CollectionKit
import MBProgressHUD
import PromiseKit
import IQKeyboardManagerSwift

class GXMineRechargeVC: GXBaseViewController {
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var selectedIndex: Int?
    private var dataSource = ArrayDataSource<Int>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: Int, index: Int) in
            view.tag = index
            view.isUserInteractionEnabled = false
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 6.0
            view.titleLabel?.font = .gx_boldFont(size: 24)
            view.setTitle("$ \(data)", for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.isSelected = (index == self.selectedIndex)
        })
        let sizeSource = { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            let width = floor((collectionSize.width - 24) / 3)
            return CGSize(width: width, height: 60)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                self.selectedIndex = tapContext.index
                self.collectionView.reloadData()
            }
        )
        provider.layout = FlowLayout(spacing: 12).inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        return CollectionView(provider: provider)
    }()
    
    private lazy var viewModel: GXMineRechargeViewModel = {
        return GXMineRechargeViewModel()
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
    
    override func viewDidDisappearPopOrDismissed() {
        super.viewDidDisappearPopOrDismissed()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.setRoundedCorners([.topLeft, .topRight], radius: 8.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = false
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
        self.dataSource.data = [10, 30, 50, 100, 200, 500]
    }
    
}

private extension GXMineRechargeVC {
    func requestWalletConsumerBalance(amount: Int) {
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestStripeConsumerPayment(amount: amount)
        }.ensure {
            MBProgressHUD.dismiss()
        }.then { model in
            GXStripePaymentManager.paymentSheetToPayment(data: model, fromVC: self)
        }.done { result in
            switch result {
            case .canceled: break
            case .completed:
                GXToast.showSuccess(text: "Payment success")
            case .failed(let error):
                GXToast.showError(text:error.localizedDescription)
            }
        }.catch { error in
            GXToast.showError(text:error.localizedDescription)
        }
    }
}

extension GXMineRechargeVC {
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.backBarButtonItemTapped()
    }
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        guard let index = self.selectedIndex else { return }
        
        let amount = self.dataSource.data[index]
        self.requestWalletConsumerBalance(amount: amount)
    }
}
