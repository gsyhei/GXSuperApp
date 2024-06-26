//
//  GXSelectedMarkerInfoView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/8.
//

import UIKit
import CollectionKit
import GXAlert_Swift

class GXSelectedMarkerInfoView: UIView {
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var leftLineImgView: UIImageView!
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
    var model: GXStationConsumerRowsModel?
    var closeAction: GXActionBlock?
    
    deinit {
        NSLog("GXSelectedMarkerInfoView deinit")
    }
    
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
    
    class func menuHeight() -> CGFloat {
        return 285 + UIWindow.gx_safeAreaInsets.bottom
    }
    
    @discardableResult
    class func showSelectedMarkerInfoView(to vc: UIViewController, model: GXStationConsumerRowsModel?) -> GXSelectedMarkerInfoView {
        if !Thread.isMainThread {
            assertionFailure()
        }
        let infoView = GXSelectedMarkerInfoView.xibView().then {
            $0.superVC = vc
            $0.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: menuHeight())
            $0.bindView(model: model)
        }
        UIWindow.gx_frontWindow?.addSubview(infoView)
        infoView.showMenu()
        
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
        self.navigateButton.setBackgroundColor(.white, for: .normal)
        self.navigateButton.setBackgroundColor(.gx_background, for: .highlighted)
        self.scanButton.setBackgroundColor(.gx_green, for: .normal)
        self.scanButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        
        let gradientColors: [UIColor] = [.gx_green, UIColor(hexString: "#278CFF")]
        self.leftLineImgView.image = UIImage(gradientColors: gradientColors, style: .vertical, size: CGSize(width: 4, height: 14))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12)
        self.leftLineImgView.setRoundedCorners([.topRight, .bottomRight], radius: 2.0)
    }
    
    func showMenu() {
        let windowRect = UIWindow.gx_frontWindow?.frame ?? CGRect(origin: .zero, size: SCREEN_SIZE)
        var frame = self.frame
        frame.origin.y = windowRect.height
        self.frame = frame
        frame.origin.y = windowRect.height - self.frame.height
        UIView.animate(.promise, duration: 0.3, options: .curveEaseOut) {
            self.frame = frame
        }
    }

    func hideMenu() {
        let windowRect = UIWindow.gx_frontWindow?.frame ?? CGRect(origin: .zero, size: SCREEN_SIZE)
        var frame = self.frame
        frame.origin.y = windowRect.height
        UIView.animate(.promise, duration: 0.3, options: .curveEaseOut) {
            self.frame = frame
        }.done { finished in
            self.removeFromSuperview()
        }
    }
    
    func bindView(model: GXStationConsumerRowsModel?) {
        guard let model = model else { return }
        self.model = model
        
        // 名称
        self.nameLabel.text = model.name
        // 站点服务
        let titles = model.aroundFacilitiesList.compactMap { $0.name }
        self.topTagsView.updateTitles(titles: titles, width: SCREEN_WIDTH - 48, isShowFristLine: false)
        // 电费
        self.priceLabel.text = "$ \(model.electricFee)"
        
        // 充电枪信息
        if model.teslaIdleCount == model.teslaCount {
            self.tslNumberBgView.backgroundColor = .gx_background
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_disable")
        }
        else {
            self.tslNumberBgView.backgroundColor = .gx_lightRed
            self.tslNumberImgView.image = UIImage(named: "home_map_ic_tesla_normal")
        }
        if model.usIdleCount == model.usCount {
            self.usNumberBgView.backgroundColor = .gx_background
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_disable")
        }
        else {
            self.usNumberBgView.backgroundColor = .gx_lightBlue
            self.usNumberImgView.image = UIImage(named: "home_map_ic_us_normal")
        }
        let tslAttrText: NSAttributedString = .gx_stationAttrText(type: .tsl, isSelected: false, count: model.teslaIdleCount, maxCount: model.teslaCount)
        self.tslNumberLabel.attributedText = tslAttrText
        let usAttrText: NSAttributedString = .gx_stationAttrText(type: .us, isSelected: false, count: model.usIdleCount, maxCount: model.usCount)
        self.usNumberLabel.attributedText = usAttrText
        
        // 停车减免、服务费
        let occupyFeeInfo = "Idle fee $\(model.occupyFee) / min"
        self.bottomTagsView.updateTitles(titles: [model.freeParking, occupyFeeInfo], width: SCREEN_WIDTH - 60, isShowFristLine: true)
        // 站点图片
        self.dataSource.data = model.aroundServicesArr
        // 距离
        let distance: Float = Float(model.distance)/1000.0
        self.distanceLabel.text = String(format: "%.1fkm", distance)
    }
}

extension GXSelectedMarkerInfoView {
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.hideMenu()
        self.closeAction?()
    }
    
    @IBAction func navigateButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        
    }
    
}
