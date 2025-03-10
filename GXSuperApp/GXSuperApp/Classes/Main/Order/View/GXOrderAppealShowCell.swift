//
//  GXOrderAppealShowCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import Reusable
import CollectionKit
import HXPhotoPicker

class GXOrderAppealShowCell: UITableViewCell, NibReusable {
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsHeightLC: NSLayoutConstraint!
    private var dataSource = ArrayDataSource<String>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIImageView, data: String, index: Int) in
            view.contentMode = .scaleAspectFill
            view.kf.setImage(with: URL(string: data), placeholder: UIImage.gx_default)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            let width = floor((collectionSize.width - 24) / 3)
            return CGSize(width: width, height: width)
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
        provider.layout = FlowLayout(spacing: 12.0)
        return CollectionView(provider: provider)
    }()
    private weak var superVC: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.containerView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCell(model: OrderConsumerComplainDetailData, superVC: GXOrderAppealVC?) {
        self.superVC = superVC
        let typeNames = model.types.map { $0.name }
        self.typeNameLabel.text = typeNames.joined(separator: " | ")
        self.detailLabel.text = model.reason
        self.dataSource.data = model.photos
        self.layoutIfNeeded()
        let constant = self.getShowHeight(count: self.dataSource.data.count, rowCount: 3, spacing: 12)
        self.tagsHeightLC.constant = constant
        superVC?.tableView.beginUpdates()
        superVC?.tableView.endUpdates()
    }
}

private extension GXOrderAppealShowCell {
    
    func getShowHeight(count: Int, rowCount: Int, spacing: CGFloat) -> CGFloat {
        let cellSize = floor((SCREEN_WIDTH - 48 + spacing) / CGFloat(rowCount)) - spacing
        let column: Int = (count + rowCount - 1) / rowCount
        let height: CGFloat = cellSize * CGFloat(column) + CGFloat(column - 1) * spacing

        return height
    }
    
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
