//
//  GXMineCell2.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/12.
//

import UIKit
import Reusable
import CollectionKit

class GXMineCell2ItemView: UIView {
    var index: Int = 0
    lazy var button: UIButton = {
        return UIButton(type: .custom).then {
            $0.contentVerticalAlignment = .top
            $0.contentHorizontalAlignment = .center
        }
    }()
    lazy var label: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_font(size: 14)
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubveiws()
    }
    
    func createSubveiws() {
        self.addSubview(self.button)
        self.addSubview(self.label)
        self.button.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        self.label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct GXMineCell2ItemModel {
    var imageName: String
    var title: String
    init(imageName: String, title: String) {
        self.imageName = imageName
        self.title = title
    }
}

class GXMineCell2: UITableViewCell, NibReusable {
    @IBOutlet weak var containerView: UIView!
    private var dataSource = ArrayDataSource<GXMineCell2ItemModel>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: GXMineCell2ItemView, data: GXMineCell2ItemModel, index: Int) in
            view.label.text = data.title
            view.button.tag = index
            view.button.setImage(UIImage(named: data.imageName), for: .normal)
            view.button.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        })
        let sizeSource = { (index: Int, data: GXMineCell2ItemModel, collectionSize: CGSize) -> CGSize in
            let width = floor(collectionSize.width / 4)
            return CGSize(width: width, height: collectionSize.height/2)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource
        )
        provider.layout = FlowLayout(spacing: 0).inset(by: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        return CollectionView(provider: provider)
    }()
    private var action: GXActionBlockItem<Int>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.containerView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindCell(models: [GXMineCell2ItemModel], action: GXActionBlockItem<Int>?) {
        self.dataSource.data = models
        self.action = action
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        let index = sender.tag
        self.action?(index)
    }
    
}
