//
//  GXConversationSystemDetailVC.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/14.
//

import UIKit

class GXConversationSystemDetailVC: GXBaseViewController {

    private lazy var cell: GXConversationSystemCell = {
        return GXConversationSystemCell.xibView()
    }()
    weak var viewModel: GXConversationSystemListViewModel!
    var selectIndex: Int = 0

    init(viewModel: GXConversationSystemListViewModel, index: Int) {
        self.viewModel = viewModel
        self.selectIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.requestSetReadFlag(index: self.selectIndex)
    }

    override func setupViewController() {
        self.title = "消息详情"
        self.view.backgroundColor = .gx_background
        self.gx_addBackBarButtonItem()

        let model = self.viewModel.list[self.selectIndex]
        self.cell.bindCell(model: model)
        self.cell.contentLabel.font = .gx_boldFont(size: 15)
        self.cell.lookButton.isHidden = true
        self.cell.tagView.isHidden = true
        self.cell.contentLabel.numberOfLines = 0

        let textWidth = self.view.frame.width - 64
        let height = model.messageContent.height(width: textWidth, font: .gx_boldFont(size: 15)) + 93
        self.view.addSubview(self.cell)
        self.cell.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.height.equalTo(height)
        }
    }

}
