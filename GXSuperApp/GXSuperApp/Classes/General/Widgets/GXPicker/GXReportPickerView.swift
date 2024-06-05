//
//  GXReportPickerView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/20.
//

import UIKit
import CollectionKit

class GXReportPickerView: UIView {
    @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var okButton: UIButton!
    var dataSource = ArrayDataSource<String>()
    var completion: GXActionBlockItem<[String]>?

    private lazy var list: [String] = {
        return [
            "谩骂攻击",
            "色情低俗",
            "网络暴力",
            "违法违规",
            "政治敏感",
            "垃圾广告",
            "未成年相关",
            "其他"
        ]
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.okButton.setBackgroundColor(.gx_green, for: .normal)

        let width: Int = Int(SCREEN_WIDTH - 48.0) / 3
        let viewSource = ClosureViewSource(viewUpdater: { (view: UIButton, data: String, index: Int) in
            view.titleLabel?.font = .gx_font(size: 15)
            view.setTitle(data, for: .normal)
            view.setTitleColor(.gx_black, for: .normal)
            view.setTitleColor(.gx_drakGreen, for: .selected)
            view.setBackgroundColor(.white, for: .normal)
            view.setBackgroundColor(.gx_black, for: .selected)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 4.0
            view.layer.borderWidth = 1.0
            view.layer.borderColor = UIColor.gx_lightGray.cgColor
            view.isUserInteractionEnabled = false
        })
        let sizeSource = { (index: Int, data: String, collectionSize: CGSize) -> CGSize in
            return CGSize(width: width, height: 32)
        }
        self.dataSource.data = self.list
        let provider = BasicProvider (
            dataSource: self.dataSource,
            viewSource: viewSource,
            sizeSource: sizeSource,
            tapHandler: { tapContext in
                tapContext.view.isSelected = !tapContext.view.isSelected
            }
        )
        provider.layout = FlowLayout(spacing: 8.0)
        self.collectionView.provider = provider
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.topLeft, .topRight], radius: 12.0)
    }
}

extension GXReportPickerView {
    @IBAction func closeButtonClicked(_ sender: Any?) {
        self.hide(animated: true)
    }
    @IBAction func okButtonClicked(_ sender: Any?) {
        var selectList: [String] = []
        for cell in self.collectionView.visibleCells {
            if let button = cell as? UIButton {
                if button.isSelected {
                    let title = button.title(for: .normal) ?? ""
                    selectList.append(title)
                }
            }
        }
        self.completion?(selectList)
        self.hide(animated: true)
    }
}
