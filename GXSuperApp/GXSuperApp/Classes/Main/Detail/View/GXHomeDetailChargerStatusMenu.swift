//
//  GXHomeDetailChargerStatusMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/24.
//

import UIKit

class GXHomeDetailChargerStatusMenu: GXBaseMenuView {

    private lazy var tableView: UITableView = {
        return UITableView(frame: self.bounds, style: .plain).then {
            $0.configuration(estimated: true)
            $0.rowHeight = 64
            $0.allowsSelection = false
            $0.separatorColor = .gx_lightGray
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXHomeDetailChargerStatusCell.self)
        }
    }()

    override func createSubviews() {
        super.createSubviews()
        
        self.titleLabel.text = "Charger Status"
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(3)
            make.right.equalToSuperview().offset(-3)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
}

extension GXHomeDetailChargerStatusMenu: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeDetailChargerStatusCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
