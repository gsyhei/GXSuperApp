//
//  GXHomeDetailPriceDetailsMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXHomeDetailPriceDetailsMenu: GXBaseMenuView {
    private var prices: [GXStationConsumerDetailPricesItem] = []
    
    private lazy var infoText: String = {
        return "Due to the fluctuation of service operation costs and electri-city prices, pricing is different between charging and different gun powers"
    }()
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
            $0.font = .gx_font(size: 15)
            $0.numberOfLines = 0
            $0.text = self.infoText
        }
    }()

    override func createSubviews() {
        super.createSubviews()
        
        self.titleLabel.text = "Session Fee"
        self.addSubview(self.infoLabel)
        self.infoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(3)
            make.right.equalToSuperview().offset(-3)
            make.bottom.equalTo(self.infoLabel.snp.top).offset(-12)
        }
    }
    
    func bindView(prices: [GXStationConsumerDetailPricesItem]) {
        self.prices = prices
        self.tableView.reloadData()
        
        let infoHeight = self.infoText.height(width: SCREEN_WIDTH - 30, font: .gx_font(size: 15))
        var height = tableView.sectionHeaderHeight + infoHeight + 32
        height += tableView.rowHeight * CGFloat(prices.count)
        height += self.safeAreaHeight
        self.updateHeight(height: height)
    }
    
}

extension GXHomeDetailPriceDetailsMenu: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailChargingFeeCell = tableView.dequeueReusableCell(for: indexPath)
        let price = self.prices[indexPath.row]
        cell.bindCell(model: price)
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
