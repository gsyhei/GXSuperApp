//
//  GXHomeDetailVehicleCodeMenu.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/1.
//

import UIKit

class GXHomeDetailVehicleCodeMenu: GXBaseMenuView {

    private lazy var picker: UIPickerView = {
        return UIPickerView(frame: self.bounds).then {
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    private lazy var confirmButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.titleLabel?.font = .gx_font(size: 16)
            $0.setTitle("Confirm", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.setBackgroundColor(.gx_green, for: .normal)
            $0.setBackgroundColor(.gx_drakGreen, for: .highlighted)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 20
            $0.addTarget(self, action: #selector(confirmButtonClicked(_:)), for: .touchUpInside)
        }
    }()
    
    var action: GXActionBlockItem<String>?

    override func createSubviews() {
        super.createSubviews()
        
        self.titleLabel.text = nil
        self.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(40)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        self.addSubview(self.picker)
        self.picker.snp.makeConstraints { make in
            make.top.equalTo(self.topLineView.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalTo(self.confirmButton.snp.top).offset(-10)
        }
    }
    
    @objc func confirmButtonClicked(_ sender: Any?) {
        let selectRow = self.picker.selectedRow(inComponent: 0)
        let code = GXUserManager.shared.paramsData?.states[selectRow] ?? ""
        self.action?(code)
        self.hide(animated: true)
    }
}

extension GXHomeDetailVehicleCodeMenu: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GXUserManager.shared.paramsData?.states.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GXUserManager.shared.paramsData?.states[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44.0
    }

}
