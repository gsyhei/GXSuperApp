//
//  GXLoginInputCell.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit
import RxCocoa
import RxSwift
import RxCocoaPlus
import XCGLogger
import Reusable

enum GXInputCellType {
    case username
    case password
    case code
}

class GXLoginInputCell: UITableViewCell, NibReusable {
    private var disposeBag = DisposeBag()
    var sendCodeCompleteBlock: GXActionBlockItem<GXActionBlock>?

    @IBOutlet weak var rightLayoutC: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    
    private var countdown: Int = 60 {
        didSet {
            self.codeButton.setTitle(String(format: "重新发送(%ds)", self.countdown), for: .disabled)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.codeButton.setTitle("获取验证码", for: .normal)
        self.codeButton.setTitleColor(.gx_gray, for: .disabled)
        self.codeButton.setTitleColor(.gx_blue, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

private extension GXLoginInputCell {
    @IBAction func codeButtonClicked(_ sender: UIButton) {
        let block: GXActionBlock = { [weak self] in
            self?.startKeepTime()
        }
        self.sendCodeCompleteBlock?(block)
    }

    func startKeepTime() {
        self.codeButton.isEnabled = false
        GXUtil.gx_countdownTimer(second: 60) {[weak self] (index) in
            guard let strongSelf = self else { return }
            strongSelf.countdown = index
        }.subscribe {[weak self] () in
            guard let strongSelf = self else { return }
            strongSelf.codeButton.isEnabled = true
            XCGLogger.debug("计时结束")
        } onFailure: { (error) in
            XCGLogger.debug("计时失败：\(error)")
        }.disposed(by: self.disposeBag)
    }
}

extension GXLoginInputCell {
    func setInput(type: GXInputCellType, placeholder: String?, input: BehaviorRelay<String?>? = nil) {
        self.inputTextField.gx_setPlaceholder(text: placeholder, color: .gx_gray, font: .gx_boldFont(size: 17))
        var count: Int = 0
        switch type {
        case .username:
            self.rightLayoutC.constant = 0
            self.codeButton.isHidden = true
            self.inputTextField.keyboardType = .numberPad
            self.inputTextField.isSecureTextEntry = false
            count = 11
        case .password:
            self.rightLayoutC.constant = 0
            self.codeButton.isHidden = true
            self.inputTextField.keyboardType = .default
            self.inputTextField.isSecureTextEntry = true
            count = 20
        case .code:
            self.rightLayoutC.constant = self.codeButton.width
            self.codeButton.isHidden = false
            self.inputTextField.keyboardType = .numberPad
            self.inputTextField.isSecureTextEntry = false
            count = 6
        }
        // 绑定输入长度
        self.inputTextField.rx.controlEvent([.editingChanged])
        .asObservable()
        .subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.inputTextField.markedTextRange == nil {
                if let text = strongSelf.inputTextField.text {
                    if text.count > count {
                        strongSelf.inputTextField.text = text.substring(to: count)
                    }
                }
            }
        }).disposed(by: disposeBag)
        // 绑定输入文本
        if let inputText = input {
            (self.inputTextField.rx.textInput <-> inputText).disposed(by: disposeBag)
        }
    }
}
