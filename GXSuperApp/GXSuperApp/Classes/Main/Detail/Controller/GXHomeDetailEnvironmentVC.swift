//
//  GXHomeDetailAroundServicesVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import CollectionKit
import HXPhotoPicker

class GXHomeDetailEnvironmentVC: GXBaseViewController {
    private var dataSource = ArrayDataSource<String>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: String, index: Int) in
            view.contentMode = .scaleAspectFill
            view.kf.setImage(with: URL(string: data), placeholder: UIImage.gx_default)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 8.0
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = collectionSize.width
            return CGSize(width: width, height: 215)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                self.showPhotoPicker(index: tapContext.index, image: tapContext.view.image)
            }
        )
        provider.layout = FlowLayout(spacing: 15.0).inset(by: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        return CollectionView(provider: provider)
    }()
    
    required init(images: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource.data = images
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Station Environment"
        self.gx_addBackBarButtonItem()
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension GXHomeDetailEnvironmentVC {
    func showPhotoPicker(index: Int, image: UIImage?) {
        PhotoBrowser.show(pageIndex: index, transitionalImage: image) {
            return self.dataSource.data.count
        } assetForIndex: { index in
            let url = URL(string:self.dataSource.data[index])
            let imageAsset = NetworkImageAsset(thumbnailURL: nil, originalURL: url, placeholder: UIImage.gx_defaultName)
            return PhotoAsset(networkImageAsset: imageAsset)
        } transitionAnimator: { index,arg  in
            let cell = self.collectionView.cell(at: index) as? UIImageView
            return cell
        }
    }
}
