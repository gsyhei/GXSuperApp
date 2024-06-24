//
//  GXHomeDetailPriceDetailsMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXHomeDetailPriceDetailsMenu: GXBaseMenuView {

    private lazy var tableView: UITableView = {
        return UITableView(frame: self.bounds, style: .plain).then {
            $0.configuration(estimated: true)
            $0.sectionHeaderHeight = 22
            $0.sectionFooterHeight = 0
            $0.rowHeight = 44
            $0.allowsSelection = false
            $0.separatorStyle = .none
            $0.dataSource = self
            $0.delegate = self
            $0.register(headerFooterViewType: GXHomeDetailChargingFeeHeader.self)
            $0.register(cellType: GXHomeDetailChargingFeeCell.self)
        }
    }()
    
    private lazy var infoLabel: UILabel = {
        return UILabel().then {
            $0.textColor = .gx_drakGray
            $0.font = .gx_font(size: 14)
            $0.numberOfLines = 0
            $0.text = "Due to the fluctuation of service operating costs and electri-city prices, there are pricing differences between charging and different gun power"
        }
    }()

    override func createSubviews() {
        super.createSubviews()
        
        self.titleLabel.text = "Price Details"
        self.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(3)
            make.right.equalToSuperview().offset(-3)
            make.bottom.equalTo(self.infoLabel.snp.top).offset(-12)
        }
    }
    
}

extension GXHomeDetailPriceDetailsMenu: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailChargingFeeCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(GXHomeDetailChargingFeeHeader.self)
        return header
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
