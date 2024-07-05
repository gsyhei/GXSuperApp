//
//  GXPhotoBrowser.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/6.
//

import UIKit
import HXPhotoPicker

class GXPhotoBrowser: PhotoBrowser {
    private lazy var numberLabel: UILabel = {
        return UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44)).then {
            $0.text = "1 / 5"
            $0.textColor = .white
            $0.font = .gx_boldFont(size: 16)
            $0.textAlignment = .center
        }
    }()
    
    public init(_pageIndex: Int = 0, assets: [PhotoAsset] = [], transitionalImage: UIImage? = nil) {
        super.init(pageIndex: _pageIndex, assets: assets, transitionalImage: transitionalImage)
        
        self.previewViewController?.view.addSubview(self.numberLabel)
        self.numberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     class func show(
        _pageIndex: Int = 0,
        fromVC: UIViewController? = nil,
        transitionalImage: UIImage? = nil,
        numberOfPages: @escaping NumberOfPagesHandler,
        assetForIndex: @escaping RequiredAsset,
        transitionAnimator: TransitionAnimator? = nil,
        transitionCompletion: TransitionCompletion? = nil,
        cellForIndex: CellReloadContext? = nil,
        cellWillDisplay: ContextUpdate? = nil,
        cellDidEndDisplaying: ContextUpdate? = nil,
        viewDidScroll: ContextUpdate? = nil,
        deleteAssetHandler: AssetHandler? = nil,
        longPressHandler: AssetHandler? = nil
    ) -> GXPhotoBrowser {
        let browser = GXPhotoBrowser(_pageIndex: _pageIndex, transitionalImage: transitionalImage)
        browser.transitionAnimator = transitionAnimator
        browser.transitionCompletion = transitionCompletion
        browser.numberOfPages = numberOfPages
        browser.assetForIndex = assetForIndex
        browser.cellWillDisplay = cellWillDisplay
        browser.cellDidEndDisplaying = cellDidEndDisplaying
        browser.viewDidScroll = viewDidScroll
        browser.deleteAssetHandler = deleteAssetHandler
        browser.longPressHandler = longPressHandler
        browser.pageIndicator = nil
        browser.show(fromVC)
        browser.viewDidScroll = { (cell, index, vc) in
            guard let currVC = vc as? GXPhotoBrowser else { return }
            currVC.numberLabel.text = "\(index) / \(currVC.pageCount)"
        }
        
        return browser
    }

}
