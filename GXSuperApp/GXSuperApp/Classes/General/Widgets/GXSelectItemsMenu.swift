//
//  GXSelectItemsMenu.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/10.
//

import UIKit
import Reusable

struct GXSelectItem {
    var title: String
    var status: Int?

    init(_ title: String, _ status: Int?) {
        self.title = title
        self.status = status
    }
}

class GXSelectItemCell: UITableViewCell, Reusable {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.accessoryType = .none
        self.indentationLevel = 2
        self.indentationWidth = 8.0
        self.tintColor = .gx_drakGreen
        self.textLabel?.font = .gx_font(size: 15)
        self.textLabel?.textColor = .gx_drakGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.accessoryType = .checkmark
            self.textLabel?.font = .gx_boldFont(size: 15)
            self.textLabel?.textColor = .gx_textBlack
        }
        else {
            self.accessoryType = .none
            self.textLabel?.font = .gx_font(size: 15)
            self.textLabel?.textColor = .gx_drakGray
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            self.accessoryType = .checkmark
            self.textLabel?.font = .gx_boldFont(size: 15)
            self.textLabel?.textColor = .gx_textBlack
        }
        else {
            self.accessoryType = .none
            self.textLabel?.font = .gx_font(size: 15)
            self.textLabel?.textColor = .gx_drakGray
        }
    }

    func bindModel(_ model: GXSelectItem) {
        self.textLabel?.text = model.title
    }
}

class GXSelectItemsMenu: UIView {
    private let CellID = "CellID"
    private var items: [GXSelectItem] = []
    var selectedAction: GXActionBlockItem<[GXSelectItem]>?

    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .white
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 40.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXSelectItemCell.self)
        }
    }()

    lazy var resetButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("重置", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.titleLabel?.font = .gx_font(size: 17)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
            $0.addTarget(self, action: #selector(resetButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    lazy var confirmButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setTitle("确定", for: .normal)
            $0.setTitleColor(.gx_textBlack, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.titleLabel?.font = .gx_font(size: 17)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
            $0.addTarget(self, action: #selector(confirmButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    init(items: [GXSelectItem], multipleSelection: Bool = false) {
        var height = (CGFloat(items.count) * 40.0) + 20.0
        if multipleSelection { height += 50.0 }
        let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height)
        super.init(frame: rect)

        self.items = items
        self.tableView.allowsMultipleSelection = multipleSelection
        self.createSubviews()
        self.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }

    func selected(items: [String]) {
        if items.count == 0 {
            self.selected(status: nil)
            return
        }
        for item in items {
            if let status = Int(item) {
                self.selected(status: status)
            }
        }
    }

    func selected(status: Int?) {
        if let index = self.items.firstIndex(where: { $0.status == status }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRoundedCorners([.bottomLeft, .bottomRight], radius: 16.0)
    }

    func createSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            if self.tableView.allowsMultipleSelection {
                make.bottom.equalToSuperview().offset(-60)
            }
            else {
                make.bottom.equalToSuperview().offset(-10)
            }
        }
        if self.tableView.allowsMultipleSelection {
            self.addSubview(self.confirmButton)
            self.addSubview(self.resetButton)
            self.resetButton.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-10)
                make.size.equalTo(CGSizeMake(120, 40))
            }
            self.confirmButton.snp.makeConstraints { make in
                make.left.equalTo(self.resetButton.snp.right).offset(10)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-10)
                make.height.equalTo(40)
            }
        }
        self.tableView.reloadData()
    }
}

extension GXSelectItemsMenu: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXSelectItemCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bindModel(self.items[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.allowsMultipleSelection else { return }
        guard (tableView.indexPathsForSelectedRows?.count ?? 0) == 0 else { return }
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.allowsMultipleSelection {
            let selectedItem = self.items[indexPath.row]
            self.selectedAction?([selectedItem])
            self.hide(animated: true)
        }
        else {
            guard (tableView.indexPathsForSelectedRows?.count ?? 0) > 1 else { return }
            if indexPath.row == 0 {
                for selectIndexPath in self.tableView.indexPathsForSelectedRows ?? [] {
                    guard selectIndexPath != indexPath else { continue }
                    tableView.deselectRow(at: selectIndexPath, animated: true)
                }
            }
            else {
                tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
            }
        }
    }

}

extension GXSelectItemsMenu {
    @objc func resetButtonClicked(_ sender: UIButton) {
        self.tableView.deselectAll(animated: true)
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
    }

    @objc func confirmButtonClicked(_ sender: UIButton) {
        var selectedItems: [GXSelectItem] = []
        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            let selectItem = self.items[indexPath.row]
            selectedItems.append(selectItem)
        }
        self.selectedAction?(selectedItems)
        self.hide(animated: true)
    }
}
