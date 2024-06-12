//
//  GXSelectedMarkerInfoView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit
import CollectionKit

class GXSelectedMarkerInfoView: UIView {
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var topTagsView: GXTagsView!
    @IBOutlet weak var bottomTagsView: GXTagsView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var usNumberBgView: UIView!
    @IBOutlet weak var tslNumberBgView: UIView!
    @IBOutlet weak var usNumberImgView: UIImageView!
    @IBOutlet weak var tslNumberImgView: UIImageView!
    @IBOutlet weak var usNumberLabel: UILabel!
    @IBOutlet weak var tslNumberLabel: UILabel!
    weak var superVC: UIViewController?
    var closeAction: GXActionBlock?
    
    private var dataSource = ArrayDataSource<String>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: String, index: Int) in
            view.image = UIImage(named: "demo_car")
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 8.0
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = floor((collectionSize.width - 12) / 3)
            return CGSize(width: width, height: collectionSize.height)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }

            }
        )
        provider.layout = RowLayout(spacing: 6.0)
        return CollectionView(provider: provider)
    }()
    
    @discardableResult
    class func showSelectedMarkerInfoView(to vc: UIViewController) -> GXSelectedMarkerInfoView {
        let infoView = GXSelectedMarkerInfoView.xibView().then {
            $0.superVC = vc
            $0.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 285 + UIWindow.gx_safeAreaInsets.bottom)
        }
        infoView.show(style: .sheetBottom, backgoundTapDismissEnable: false, usingSpring: true)
        return infoView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(145)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(70)
        }
        self.dataSource.data = ["", "", "", "", ""]
        
        self.navigateButton.setBackgroundColor(.white, for: .normal)
        self.navigateButton.setBackgroundColor(.gx_background, for: .highlighted)
        self.scanButton.setBackgroundColor(.gx_green, for: .normal)
        self.scanButton.setBackgroundColor(.gx_lightGreen, for: .highlighted)
        
        self.topTagsView.updateTitles(titles: ["Convenience store", "Toilet"], width: SCREEN_WIDTH - 48, isShowFristLine: false)
        self.bottomTagsView.updateTitles(titles: ["Parking discount", "Idle fee $0.17 / min"], width: SCREEN_WIDTH - 60, isShowFristLine: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12)
        self.leftLineView.setRoundedCorners([.topRight, .bottomRight], radius: 2.0)
    }
}

extension GXSelectedMarkerInfoView {
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.hide(animated: true)
        self.closeAction?()
    }
    
    @IBAction func navigateButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        
    }
    
}
