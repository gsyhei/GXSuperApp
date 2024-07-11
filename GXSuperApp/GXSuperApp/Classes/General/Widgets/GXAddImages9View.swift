//
//  GXAddImagesView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/4.
//

import UIKit
import Reusable
import HXPhotoPicker


class GXAddButton9Cell: UICollectionViewCell, Reusable {

    lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setBackgroundColor(.gx_lightGreen, for: .normal)
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 80.0, height: 80.0))
            $0.setImage(UIImage(named: "order_image_ic_add"), for: .normal)
            $0.isUserInteractionEnabled = false
        }
    }()

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.addButton.backgroundColor = .gx_lightGray
            } else {
                self.addButton.backgroundColor = self.contentView.backgroundColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .gx_background
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 4.0

        self.contentView.addSubview(self.addButton)
        self.addButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GXAddImage9Cell: UICollectionViewCell, Reusable {
    var closeAction: GXActionBlockItem<GXAddImage9Cell>?

    lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.backgroundColor = .gx_drakGray
            $0.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            $0.setImage(UIImage(systemName: "xmark"), for: .normal)
            $0.tintColor = .white
            $0.addTarget(self, action: #selector(self.closeButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var imageView: UIImageView = {
        return UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 80.0, height: 80.0))).then {
            $0.backgroundColor = .white
            $0.contentMode = .scaleAspectFill
        }
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.closeButton.setRoundedCorners([.bottomLeft], radius: 4.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.contentView.backgroundColor = .gx_lightGray
            } else {
                self.contentView.backgroundColor = .gx_background
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .gx_background
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 4.0

        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentView.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func closeButtonClicked(_ sender: UIButton?) {
        self.closeAction?(self)
    }

    func setPhotoAsset(asset: PhotoAsset) {
        self.imageView.image = .gx_defaultActivityIcon
        if (asset.phAsset != nil) {
            asset.requestImage(compressionScale: 0.3) {[weak self] image, _ in
                self?.imageView.image = image
            }
        }
        else {
            asset.getImage(compressionQuality: 0.3) {[weak self] image in
                self?.imageView.image = image
            }
        }
    }
}

class GXAddImages9View: UIView {

    var images: [PhotoAsset] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var addBackgroudColor: UIColor = .gx_background
    var maxAddCount: Int = 1
    var closeAction: GXActionBlockItem<CGFloat>?
    var addAction: GXActionBlock?
    var previewAction: ((Int, GXAddImage9Cell) -> Void)?

    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.dragDelegate = self
            $0.dropDelegate = self
            $0.register(cellType: GXAddImage9Cell.self)
            $0.register(cellType: GXAddButton9Cell.self)
        }
    }()

    func getShowHeight() -> CGFloat {
        var count: Int = 1
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount {
                count = self.images.count + 1
            } else {
                count = self.images.count
            }
        }
        let cellSize = self.getCellSize()
        let column: Int = (count + GXAddImagesViewMaxColumn - 1) / GXAddImagesViewMaxColumn
        let height: CGFloat = cellSize * CGFloat(column) + CGFloat(column - 1) * GXAddImagesViewCellSpace

        return height
    }
    
    private func getCellSize() -> CGFloat {
        return floor((self.collectionView.width + GXAddImagesViewCellSpace) / CGFloat(GXAddImagesViewMaxColumn)) - GXAddImagesViewCellSpace
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }

    private func createSubviews() {
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func deleteIndexPath(cell: UICollectionViewCell) {
        guard let cellIndexPath = self.collectionView.indexPath(for: cell) else { return }
        if self.images.count == self.maxAddCount {
            self.collectionView.performBatchUpdates({
                self.images.remove(at: cellIndexPath.row)
                self.collectionView.deleteItems(at: [cellIndexPath])
                let lastIndexPath = IndexPath(item: self.images.count, section: 0)
                self.collectionView.insertItems(at: [lastIndexPath])
                self.closeAction?(self.getShowHeight())
            })
        }
        else {
            self.collectionView.performBatchUpdates({
                self.images.remove(at: cellIndexPath.row)
                self.collectionView.deleteItems(at: [cellIndexPath])
                self.closeAction?(self.getShowHeight())
            })
        }
    }
    private func previewIndexPath(cell: GXAddImage9Cell) {
        guard let cellIndexPath = self.collectionView.indexPath(for: cell) else { return }
        self.previewAction?(cellIndexPath.item, cell)
    }

    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        return self.collectionView.cellForItem(at: indexPath)
    }
}

private let GXAddImagesViewCellSpace: CGFloat = 12.0
private let GXAddImagesViewMaxColumn: Int = 3
extension GXAddImages9View: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount {
                return self.images.count + 1
            }
            return self.images.count
        }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount && indexPath.row == self.images.count {
                let cell: GXAddButton9Cell = collectionView.dequeueReusableCell(for: indexPath)
                cell.contentView.backgroundColor = self.addBackgroudColor
                return cell
            }
            else {
                let cell: GXAddImage9Cell = collectionView.dequeueReusableCell(for: indexPath)
                cell.setPhotoAsset(asset: self.images[indexPath.row])
                cell.closeAction = {[weak self] closeCell in
                    self?.deleteIndexPath(cell: closeCell)
                }
                return cell
            }
        }
        else {
            if self.images.count == 0 {
                let cell: GXAddButton9Cell = collectionView.dequeueReusableCell(for: indexPath)
                cell.contentView.backgroundColor = self.addBackgroudColor
                return cell
            }
            else {
                let cell: GXAddImage9Cell = collectionView.dequeueReusableCell(for: indexPath)
                cell.setPhotoAsset(asset: self.images[indexPath.row])
                cell.closeAction = {[weak self] closeCell in
                    self?.deleteIndexPath(cell: closeCell)
                }
                return cell
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = self.getCellSize()
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return GXAddImagesViewCellSpace
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return GXAddImagesViewCellSpace
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        if self.images.count < self.maxAddCount && indexPath.row == self.images.count {
            return false
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceImage = self.images[sourceIndexPath.item]
        self.images.remove(at: sourceIndexPath.item)
        self.images.insert(sourceImage, at: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount && indexPath.row == self.images.count {
                self.addAction?()
            }
            else {
                guard let cell = collectionView.cellForItem(at: indexPath) as? GXAddImage9Cell else { return }
                self.previewAction?(indexPath.row, cell)
            }
        }
        else {
            if self.images.count == 0 {
                self.addAction?()
            }
            else {
                guard let cell = collectionView.cellForItem(at: indexPath) as? GXAddImage9Cell else { return }
                self.previewAction?(indexPath.row, cell)
            }
        }
    }
}

extension GXAddImages9View: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider.init()
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if let sourceIndexPath = session.items.first?.localObject as? IndexPath {
            if self.images.count < self.maxAddCount && sourceIndexPath.row == self.images.count {
                return false
            }
            return true
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let sourceIndexPath = session.items.first?.localObject as? IndexPath {
            if self.images.count < self.maxAddCount && sourceIndexPath.row == self.images.count {
                return UICollectionViewDropProposal.init(operation: .forbidden, intent: .insertAtDestinationIndexPath)
            }
        }
        if destinationIndexPath != nil && self.images.count < self.maxAddCount && destinationIndexPath!.row == self.images.count {
            return UICollectionViewDropProposal.init(operation: .forbidden, intent: .insertAtDestinationIndexPath)
        }
        var dropProposal: UICollectionViewDropProposal
        if session.localDragSession != nil {
            dropProposal = UICollectionViewDropProposal.init(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            dropProposal = UICollectionViewDropProposal.init(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
        return dropProposal
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath,
           let sourceIndexPath = coordinator.items.first?.sourceIndexPath {
            collectionView.isUserInteractionEnabled = false
            collectionView.performBatchUpdates {
                let sourceImage = self.images[sourceIndexPath.item]
                self.images.remove(at: sourceIndexPath.item)
                self.images.insert(sourceImage, at: destinationIndexPath.item)
                collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            } completion: { (isFinish) in
                collectionView.isUserInteractionEnabled = true
            }
            if let dragItem = coordinator.items.first?.dragItem {
                coordinator.drop(dragItem, toItemAt: destinationIndexPath)
            }
        }
    }

}
