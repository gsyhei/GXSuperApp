//
//  GXHomeDetailAddVehicleVC.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/1.
//

import UIKit
import PromiseKit
import MBProgressHUD
import RxCocoaPlus

class GXHomeDetailAddVehicleVC: GXBaseViewController {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var doneBottomLC: NSLayoutConstraint!
    @IBOutlet weak var infoTextView: GXLinkTextView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    private lazy var viewModel: GXHomeDetailAddVehicleViewModel = {
        return GXHomeDetailAddVehicleViewModel()
    }()
    var addCompletion: GXActionBlock?
    
    class func createVC(vehicle: GXVehicleConsumerListItem?) -> GXHomeDetailAddVehicleVC {
        return GXHomeDetailAddVehicleVC.xibViewController().then {
            $0.viewModel.vehicle = vehicle
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.didGetNetworktLoad {
            self.didGetNetworktLoad = true
            self.numberTF.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.numberTF.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillChangeFrameNotification)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] notifi in
                self?.keyboardChangeFrame(notification: notifi)
            }).disposed(by: disposeBag)
    }
    
    override func setupViewController() {
        self.navigationItem.title = "Add Vehicle"
        self.gx_addBackBarButtonItem()
        
        self.infoTextView.gx_setMarginZero()
        self.infoTextView.gx_appendLink(string: "Personal Information Processing Authorization", 
                                        color: UIColor.gx_blue,
                                        urlString: "Authorization")
        self.infoTextView.delegate = self
        
        self.doneButton.setBackgroundColor(.gx_green, for: .normal)
        self.doneButton.setBackgroundColor(.gx_drakGreen, for: .highlighted)
        self.doneButton.setBackgroundColor(.gx_gray, for: .disabled)
        self.doneButton.isEnabled = false
        
        self.numberTF.keyboardType = .alphabet
        self.numberTF.autocapitalizationType = .allCharacters
        self.numberTF.rx.text.orEmpty.subscribe (onNext: {[weak self] string in
            guard let `self` = self else { return }
            guard self.numberTF.markedTextRange == nil else { return }
            let maxCount: Int = 10
            if string.count > maxCount {
                self.numberTF.text = string.substring(to: maxCount)
            }
            self.updateDoneButton()
        }).disposed(by: disposeBag)
        
        self.viewModel.state.subscribe {[weak self] text in
            guard let `self` = self else { return }
            self.codeLabel.text = text
        }.disposed(by: disposeBag)
        (self.numberTF.rx.textInput <-> self.viewModel.carTailNumber).disposed(by: disposeBag)
    }
    
    func updateDoneButton() {
        if self.checkButton.isSelected && self.numberTF.text?.count ?? 0 > 0 {
            self.doneButton.isEnabled = true
        }
        else {
            self.doneButton.isEnabled = false
        }
    }
    
    func requestVehicleConsumerList() {
        self.view.endEditing(true)
        MBProgressHUD.showLoading()
        firstly {
            self.viewModel.requestVehicleConsumerSave()
        }.done { model in
            MBProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
            self.addCompletion?()
        }.catch { error in
            MBProgressHUD.dismiss()
            GXToast.showError(text:error.localizedDescription)
        }
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.updateDoneButton()
    }
    
    @IBAction func arrowButtonClicked(_ sender: UIButton) {
        let height = 300 + UIWindow.gx_safeAreaInsets.bottom
        let menu = GXHomeDetailVehicleCodeMenu(height: height)
        menu.action = {[weak self] code in
            guard let `self` = self else { return }
            self.viewModel.state.accept(code)
        }
        menu.show(style: .sheetBottom, usingSpring: true)
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        self.requestVehicleConsumerList()
    }
}

extension GXHomeDetailAddVehicleVC: UITextViewDelegate {
    func keyboardChangeFrame(notification: Notification) {
        let endFrame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration: Double = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let options: UIView.AnimationOptions = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationOptions ?? .curveLinear
        let bottom = self.view.safeAreaInsets.bottom - 15.0
        let height = self.view.frame.height - endFrame.origin.y
        let endBottom = max(height - bottom, 15.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: options) {
            self.doneBottomLC.constant = endBottom
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.didLinkScheme(URL.absoluteString)
        return false
    }

    func didLinkScheme(_ scheme: String) {
        let vc = GXWebViewController(urlString: "https://www.baidu.com", title: "Authorization")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
