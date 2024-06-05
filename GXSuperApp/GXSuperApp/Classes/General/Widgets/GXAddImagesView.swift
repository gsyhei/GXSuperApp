//
//  GXAddImagesView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/4.
//

import UIKit
import Reusable
import HXPhotoPicker


class GXAddButtonCell: UICollectionViewCell, Reusable {

    lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.backgroundColor = .white
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
            $0.setTitle("+", for: .normal)
            $0.setTitleColor(.hex(hexString: "#A6A6A6"), for: .normal)
            $0.titleLabel?.font = .gx_font(size: 34)
            $0.isUserInteractionEnabled = false
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 4.0
        }
    }()

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.addButton.backgroundColor = .gx_lightGray
            } else {
                self.addButton.backgroundColor = .white
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.addButton)
        self.addButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(GXAddImagesButtonCellHeight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GXAddImageCell: UICollectionViewCell, Reusable {
    var closeAction: GXActionBlockItem<GXAddImageCell>?

    lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.backgroundColor = .gx_drakGray
            $0.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            $0.setImage(UIImage(systemName: "xmark"), for: .normal)
            $0.tintColor = .white
            $0.addTarget(self, action: #selector(self.closeButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var imageView: UIImageView = {
        return UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 100))).then {
            $0.backgroundColor = .white
            $0.contentMode = .scaleAspectFill
        }
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.contentView.backgroundColor = .gx_lightGray
            } else {
                self.contentView.backgroundColor = .white
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .white
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 4.0

        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.contentView.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func closeButtonClicked(_ sender: UIButton?) {
        self.closeAction?(self)
    }

    func setPhotoAsset(asset: PhotoAsset) {
        self.imageView.image = UIImage.gx_defaultActivityIcon
        if (asset.phAsset != nil) {
            asset.requestImage() {[weak self] image, _ in
                self?.imageView.image = image
            }
        }
        else {
            asset.getImage() {[weak self] image in
                self?.imageView.image = image
            }
        }
    }
}

class GXAddImagesView: UIView {

    var images: [PhotoAsset] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var maxAddCount: Int = 1
    var closeAction: GXActionBlockItem<CGFloat>?
    var addAction: GXActionBlock?
    var previewAction: ((Int, GXAddImageCell) -> Void)?

    lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.dragDelegate = self
            $0.dropDelegate = self
            $0.register(cellType: GXAddImageCell.self)
            $0.register(cellType: GXAddButtonCell.self)
        }
    }()

    func getShowHeight() -> CGFloat {
        var height: CGFloat = 0.0
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount {
                let count = self.images.count + 1
                height = GXAddImagesViewCellHeight * CGFloat(self.images.count) + GXAddImagesButtonCellHeight
                height += CGFloat(count - 1) * GXAddImagesViewCellSpace
            } else {
                let count = self.images.count
                height = GXAddImagesViewCellHeight * CGFloat(count) + CGFloat(count - 1) * GXAddImagesViewCellSpace
            }
        }
        else {
            if self.images.count == 0 {
                height = GXAddImagesButtonCellHeight
            } else {
                height = GXAddImagesViewCellHeight
            }
        }
        return height
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
    private func previewIndexPath(cell: GXAddImageCell) {
        guard let cellIndexPath = self.collectionView.indexPath(for: cell) else { return }
        self.previewAction?(cellIndexPath.item, cell)
    }

    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        return self.collectionView.cellForItem(at: indexPath)
    }
}

private let GXAddImagesButtonCellHeight: CGFloat = 80.0
private let GXAddImagesViewCellHeight: CGFloat = 206
private let GXAddImagesViewCellSpace: CGFloat = 8.0
extension GXAddImagesView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
                let cell: GXAddButtonCell = collectionView.dequeueReusableCell(for: indexPath)
                return cell
            }
            else {
                let cell: GXAddImageCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.setPhotoAsset(asset: self.images[indexPath.row])
                cell.closeAction = {[weak self] closeCell in
                    self?.deleteIndexPath(cell: closeCell)
                }
                return cell
            }
        }
        else {
            if self.images.count == 0 {
                let cell: GXAddButtonCell = collectionView.dequeueReusableCell(for: indexPath)
                return cell
            }
            else {
                let cell: GXAddImageCell = collectionView.dequeueReusableCell(for: indexPath)
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
        if self.maxAddCount > 1 {
            if self.images.count < self.maxAddCount && indexPath.row == self.images.count {
                return CGSize(width: collectionView.width, height: GXAddImagesButtonCellHeight)
            }
            else {
                return CGSize(width: collectionView.width, height: GXAddImagesViewCellHeight)
            }
        }
        else {
            if self.images.count == 0 {
                return CGSize(width: collectionView.width, height: GXAddImagesButtonCellHeight)
            }
            else {
                return CGSize(width: collectionView.width, height: GXAddImagesViewCellHeight)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return GXAddImagesViewCellSpace
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
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
                guard let cell = collectionView.cellForItem(at: indexPath) as? GXAddImageCell else { return }
                self.previewAction?(indexPath.row, cell)
            }
        }
        else {
            if self.images.count == 0 {
                self.addAction?()
            }
            else {
                guard let cell = collectionView.cellForItem(at: indexPath) as? GXAddImageCell else { return }
                self.previewAction?(indexPath.row, cell)
            }
        }
    }
}

extension GXAddImagesView: UICollectionViewDragDelegate, UICollectionViewDropDelegate {

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
