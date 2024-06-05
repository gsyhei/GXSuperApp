//
//  GXAddImagesView.swift
//  GXHeiVibe
//
//  Created by Gin on 2023/12/4.
//

import UIKit
import RxCocoa
import RxSwift
import RxCocoaPlus
import XCGLogger
import Reusable

class GXAddItemCell: UITableViewCell, Reusable {
    private var disposeBag = DisposeBag()
    var addAction: GXActionBlockItem<GXAddItemCell>?
    var deleteAction: GXActionBlockItem<GXAddItemCell>?

    private lazy var textView: GXTextView = {
        return GXTextView(frame: .zero).then {
            $0.backgroundColor = .white
            $0.font = .gx_font(size: 15)
            $0.textColor = .gx_black
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
        }
    }()

    private lazy var textViewNumLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .right
            $0.textColor = .gx_gray
            $0.font = .gx_font(size: 13)
            $0.text = "0/50"
        }
    }()

    private lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            $0.setImage(UIImage(named: "ac_add_icon"), for: .normal)
            $0.addTarget(self, action: #selector(self.addButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    private lazy var deleteButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            $0.setImage(UIImage(named: "a_delete_icon"), for: .normal)
            $0.addTarget(self, action: #selector(self.deleteButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.contentView.backgroundColor = .gx_background
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.textViewNumLabel)
        self.contentView.addSubview(self.addButton)
        self.contentView.addSubview(self.deleteButton)

        self.addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        self.deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(self.addButton.snp.left).offset(-16)
        }
        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.right.equalTo(self.deleteButton.snp.left).offset(-16)
        }
        self.textViewNumLabel.snp.makeConstraints { make in
            make.right.equalTo(self.textView.snp.right).offset(-8)
            make.bottom.equalTo(self.textView.snp.bottom).offset(-4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    @objc func addButtonClicked(_ sender: UIButton) {
        self.addAction?(self)
    }

    @objc func deleteButtonClicked(_ sender: UIButton) {
        self.deleteAction?(self)
    }

    func bindCell(text: BehaviorRelay<String?>, index: Int, isLast: Bool) {
        self.textView.placeholder = "选项\(index + 1)"
        (self.textView.rx.textInput <-> text).disposed(by: disposeBag)

        self.textView.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.textView.markedTextRange == nil else { return }
            guard var text = self.textView.text else { return }
            let maxCount: Int = 50
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.textView.text = text
            }
            self.textViewNumLabel.text = "\(text.count)/\(maxCount)"
            self.textViewNumLabel.textColor = (text.count > maxCount) ? .gx_red:.gx_gray
        }).disposed(by: disposeBag)
        
        if isLast {
            if index == 0 {
                self.addButton.isHidden = false
                self.deleteButton.isHidden = true

                self.addButton.snp.remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview()
                }
                self.textView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(6)
                    make.left.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-6)
                    make.right.equalTo(self.addButton.snp.left).offset(-16)
                }
            }
            else {
                self.addButton.isHidden = false
                self.deleteButton.isHidden = false
                self.addButton.snp.remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview()
                }
                self.deleteButton.snp.remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalTo(self.addButton.snp.left).offset(-16)
                }
                self.textView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(6)
                    make.left.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-6)
                    make.right.equalTo(self.deleteButton.snp.left).offset(-16)
                }
            }
        }
        else {
            self.addButton.isHidden = true
            self.deleteButton.isHidden = false
            self.deleteButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
            }
            self.textView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(6)
                make.left.equalToSuperview()
                make.bottom.equalToSuperview().offset(-6)
                make.right.equalTo(self.deleteButton.snp.left).offset(-16)
            }
        }
    }
}

class GXAddItemsView: UIView {
    var updateAction: GXActionBlockItem<CGFloat>?

    var textArray: [BehaviorRelay<String?>] = [] {
        didSet {
            self.updateAction?(CGFloat(self.textArray.count) * 80.0)
            self.tableView.reloadData()
        }
    }

    private lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .plain).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = .clear
            $0.separatorColor = .gx_lightGray
            $0.rowHeight = 80.0
            $0.dataSource = self
            $0.delegate = self
            $0.isScrollEnabled = false
            $0.register(cellType: GXAddItemCell.self)
        }
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createSubviews()
    }

    private func createSubviews() {
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension GXAddItemsView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXAddItemCell = tableView.dequeueReusableCell(for: indexPath)
        let text = self.textArray[indexPath.row]
        let isLast = (indexPath.row == self.textArray.count - 1)
        cell.bindCell(text: text, index: indexPath.row, isLast: isLast && self.textArray.count < 50)
        cell.addAction = {[weak self] curCell in
            guard let `self` = self else { return }
            guard self.textArray.count < 50 else {
                GXToast.showError(text: "题目选项数量上线50个")
                return
            }
            let text = BehaviorRelay<String?>(value: nil)
            self.textArray.append(text)
            self.tableView.reloadData()
            self.updateAction?(CGFloat(self.textArray.count) * 80.0)
        }
        cell.deleteAction = {[weak self] curCell in
            guard let `self` = self else { return }
            if let currentIP = self.tableView.indexPath(for: curCell) {
                self.textArray.remove(at: currentIP.row)
                self.tableView.reloadData()
                self.updateAction?(CGFloat(self.textArray.count) * 80.0)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
