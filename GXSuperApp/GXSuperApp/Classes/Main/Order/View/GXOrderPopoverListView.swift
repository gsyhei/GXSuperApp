//
//  GXOrderPopoverButtonList.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/10.
//

import UIKit
import Reusable

private let CELL_HEIGHT = 38.0
class GXOrderPopoverListCell: UITableViewCell, Reusable {
    lazy var nameLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_drakGray
            $0.textAlignment = .left
            $0.font = .gx_font(size: 15)
        }
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.nameLabel.textColor = highlighted ? .gx_green : .gx_drakGray
    }
}

struct GXOrderPopoverListModel {
    var title: String
    var type: Int
    init(title: String, type: Int) {
        self.title = title
        self.type = type
    }
}

class GXOrderPopoverListView: UIView {
    private lazy var tableView: UITableView = {
        return UITableView(frame: self.bounds, style: .plain).then {
            $0.configuration()
            $0.separatorStyle = .none
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = CELL_HEIGHT
            $0.register(cellType: GXOrderPopoverListCell.self)
        }
    }()
    private var list: [GXOrderPopoverListModel] = []
    private var action: GXActionBlockItem<GXOrderPopoverListModel>?
    
    required init(list: [GXOrderPopoverListModel], action: GXActionBlockItem<GXOrderPopoverListModel>?) {
        var maxWidth: CGFloat = 0
        list.forEach { item in
            let titleWidth = item.title.width(font: .gx_font(size: 15)) + 1
            maxWidth = max(maxWidth, titleWidth)
        }
        let height = CELL_HEIGHT * CGFloat(list.count) + 10.0
        let rect = CGRect(origin: .zero, size: CGSize(width: maxWidth + 24, height: height))
        super.init(frame: rect)
        self.list = list
        self.action = action
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.backgroundColor = .clear
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 5, left: 0, bottom: 13, right: 0))
        }
        self.tableView.reloadData()
    }
}

extension GXOrderPopoverListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXOrderPopoverListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.nameLabel.text = self.list[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.list[indexPath.row]
        self.action?(item)
    }
}
