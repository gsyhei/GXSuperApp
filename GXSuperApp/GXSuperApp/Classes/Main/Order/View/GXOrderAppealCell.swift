//
//  GXOrderAppealCell.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/11.
//

import UIKit
import Reusable
import HXPhotoPicker
import RxRelay
import RxSwift
import RxCocoaPlus
import CollectionKit

class GXOrderAppealCell: UITableViewCell, NibReusable {
    let disposeBag = DisposeBag()
    var resDisposeBag = DisposeBag()

    @IBOutlet weak var descTV: GXTextView!
    @IBOutlet weak var descNumLabel: UILabel!
    @IBOutlet weak var feedbackAddView: GXAddImages9View!
    @IBOutlet weak var feedbackAddViewHLC: NSLayoutConstraint!
    @IBOutlet weak var imageNumLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagsHeightLC: NSLayoutConstraint!

    private var font = UIFont.gx_font(size: 15)
    private var dataSource = ArrayDataSource<GXDictListAvailableData>()
    private lazy var collectionView: CollectionView = {
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: GXDictListAvailableData, index: Int) in
            view.titleLabel?.font = self.font
            view.setTitle(data.name, for: .normal)
            view.setTitleColor(.gx_drakGray, for: .normal)
            view.setTitleColor(.white, for: .selected)
            view.setBackgroundColor(.gx_background, for: .normal)
            view.setBackgroundColor(.gx_green, for: .selected)
            view.isSelected = self.superVC?.viewModel.selectedAppealTypeIds.contains(where: { $0 == data.id }) ?? false
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 16.0
            view.isUserInteractionEnabled = false
        })
        let sizeSource = { (index: Int, data: GXDictListAvailableData, collectionSize: CGSize) -> CGSize in
            let width = data.name.width(font: self.font) + 20.0
            return CGSize(width: width, height: collectionSize.height)
        }
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: {[weak self] tapContext in
                guard let `self` = self else { return }
                guard let viewModel = self.superVC?.viewModel else { return }
                if viewModel.selectedAppealTypeIds.contains(where: { $0 == tapContext.data.id }) {
                    viewModel.selectedAppealTypeIds.removeAll(where: { $0 == tapContext.data.id })
                } else {
                    viewModel.selectedAppealTypeIds.append(tapContext.data.id)
                }
                self.updateSubmitState()
                self.collectionView.reloadData()
            }
        )
        provider.layout = RowLayout(spacing: 10.0)
        return CollectionView(provider: provider)
    }()
    private weak var superVC: GXOrderAppealVC?
    private var updateSubmitAction: GXActionBlockItem<Bool>?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.showsHorizontalScrollIndicator = false
        self.containerView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.descTV.placeholder = "Please enter the reason for your appeal"
        self.descTV.placeholderColor = .gx_gray
        self.descTV.font = .gx_font(size: 17)
        self.descTV.gx_setMarginZero()
        self.descTV.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.descTV.markedTextRange == nil else { return }
            guard var text = self.descTV.text else { return }
            let maxCount: Int = 1000
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.descTV.text = text
            }
            self.descNumLabel.text = "\(text.count)/\(maxCount)"
            self.descNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_drakGray
            self.updateSubmitState()
            
        }).disposed(by: disposeBag)

        self.feedbackAddView.backgroundColor = .clear
        self.feedbackAddView.maxAddCount = 9
        self.feedbackAddView.closeAction = {[weak self] height in
            self?.feedbackAddViewHLC.constant = height
            self?.updateImageContent()
        }
        self.feedbackAddView.addAction = {[weak self] in
            self?.showAddViewPhotoPicker()
        }
        self.feedbackAddView.previewAction = {[weak self] (index, cell) in
            self?.showAddViewBrowser(pageIndex: index, cell: cell)
        }
    }
    
    func bindCell(superVC: GXOrderAppealVC, updateSubmitAction: GXActionBlockItem<Bool>?) {
        self.superVC = superVC
        self.updateSubmitAction = updateSubmitAction

        self.dataSource.data = GXUserManager.shared.appealTypeList
        // Bind input
        self.resDisposeBag = DisposeBag()
        (self.descTV.rx.textInput <-> superVC.viewModel.descInput).disposed(by: resDisposeBag)
        
        self.feedbackAddView.images = superVC.viewModel.images
        self.layoutIfNeeded()
        self.feedbackAddViewHLC.constant = self.feedbackAddView.getShowHeight()
    }
    
}

extension GXOrderAppealCell {
    
    func showAddViewPhotoPicker() {
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .multiple
        config.selectOptions = .photo
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoSelectionTapAction = .preview
        config.photoList.rowNumber = 3
        config.maximumSelectedCount = (9 - self.feedbackAddView.images.count)
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            guard let `self` = self else { return }
            self.feedbackAddView.images.append(contentsOf: result.photoAssets)
            self.updateImageContent()
        }
        self.superVC?.present(vc, animated: true, completion: nil)
    }
    
    func showAddViewBrowser(pageIndex: Int, cell: GXAddImage9Cell) {
        HXPhotoPicker.PhotoBrowser.show(pageIndex: pageIndex, transitionalImage: cell.imageView.image) {
            self.feedbackAddView.images.count
        } assetForIndex: {
            self.feedbackAddView.images[$0]
        } transitionAnimator: { index,arg  in
            self.feedbackAddView.cellForItem(at: IndexPath(item: index,section: 0)) as? GXAddImage9Cell
        }
    }
        
    func updateImageContent() {
        guard let superVC = self.superVC else { return }
        
        superVC.viewModel.images = self.feedbackAddView.images
        self.imageNumLabel.text = "\(superVC.viewModel.images.count)/9"
        let height = self.feedbackAddView.getShowHeight()
        self.feedbackAddViewHLC.constant = height
        UIView.performWithoutAnimation {
            self.superVC?.tableView.reloadData()
        }
        self.updateSubmitState()
    }
    
    func updateSubmitState() {
        var isSubmit = false
        isSubmit = self.descTV.text?.count ?? 0 > 0
        isSubmit = isSubmit && (self.superVC?.viewModel.selectedAppealTypeIds.count ?? 0 > 0)
        self.updateSubmitAction?(isSubmit)
    }
    
}
