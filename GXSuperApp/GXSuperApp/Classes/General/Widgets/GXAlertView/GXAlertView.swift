//
//  GXAlertView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/3.
//

import UIKit
import RxSwift
import RxCocoa
import RxCocoaPlus

class GXAlertAction: NSObject {
    public var title: String? = nil
    public var titleFont: UIFont? = nil
    public var titleColor: UIColor? = nil
    public var backgroundColor: UIColor? = nil
    public var selBackgroundColor: UIColor? = nil
    public var height: CGFloat = 40.0
    public var borderWidth: CGFloat = .zero
    public var action: GXActionBlockItem<GXAlertView>?
}

class GXAlertInput: NSObject {
    public var keyboardType: UIKeyboardType = .default
    public var isSecureTextEntry: Bool = false
    public var inputText = BehaviorRelay<String?>(value: nil)
    public var inputTitleColor: UIColor? = .gx_black
    public var inputTitleFont: UIFont? = .gx_font(size: 17)
    public var inputPlaceholder: String? = nil
    public var inputHeight: CGFloat = 48.0
}

private let GXALERT_XMARGIN: CGFloat = 16.0
private let GXALERT_YMARGIN: CGFloat = 20.0
private let GXALERT_XSPACE: CGFloat = 16.0
private let GXALERT_YSPACE: CGFloat = 16.0
private let GXALERT_MAXSIZE = CGSize(width: SCREEN_MIN_WIDTH - 100, height: SCREEN_HEIGHT - 200)

class GXAlertView: UIView {
    let disposeBag = DisposeBag()

    private(set) lazy var contentView: UIView = {
        return UIView().then {
            $0.backgroundColor = .white
        }
    }()

    private(set) lazy var titleLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_textBlack
            $0.font = .gx_boldFont(size: 19)
            $0.numberOfLines = 0
        }
    }()

    private(set) lazy var messageLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .center
            $0.textColor = .gx_drakGray
            $0.font = .gx_font(size: 16)
            $0.numberOfLines = 0
        }
    }()

    private(set) lazy var infoLabel: UILabel = {
        return UILabel().then {
            $0.textAlignment = .left
            $0.textColor = .gx_red
            $0.font = .gx_font(size: 14)
            $0.numberOfLines = 1
        }
    }()

    private(set) var buttonList: [UIButton] = []
    private(set) var textFieldList: [UITextField] = []
    private(set) var actions: [GXAlertAction] = []
    private(set) var inputs: [GXAlertInput] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(self.contentView)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createAlert(title: String? = nil,
                     message: String? = nil,
                     actions: [GXAlertAction] = [],
                     inputs: [GXAlertInput] = []) {
        self.actions = actions
        self.inputs = inputs

        var top = GXALERT_YMARGIN, left = GXALERT_XMARGIN
        let width = GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2
        if let letTitle = title {
            self.titleLabel.text = letTitle
            let height = letTitle.height(width: width, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: left, y: top, width: width, height: ceil(height))
            self.contentView.addSubview(self.titleLabel)
            top = self.titleLabel.bottom
        }
        if let letMessage = message {
            top += GXALERT_YSPACE/2
            self.messageLabel.text = letMessage
            let height = letMessage.height(width: width, font: self.messageLabel.font)
            self.messageLabel.frame = CGRect(x: left, y: top, width: width, height: ceil(height))
            self.contentView.addSubview(self.messageLabel)
            top = self.messageLabel.bottom
        }
        if inputs.count > 0 {
            top += GXALERT_YSPACE/2
            for item in inputs {
                top += GXALERT_YSPACE/2
                let frame = CGRect(x: left, y: top, width: width, height: item.inputHeight)
                let textField = UITextField(frame: frame).then {
                    $0.isSecureTextEntry = item.isSecureTextEntry
                    $0.keyboardType = item.keyboardType
                    $0.placeholder = item.inputPlaceholder
                    $0.textColor = item.inputTitleColor
                    $0.font = item.inputTitleFont
                    $0.backgroundColor = .gx_background
                    $0.layer.masksToBounds = true
                    $0.layer.cornerRadius = 4.0
                    $0.leftViewMode = .always
                    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: item.inputHeight))
                    $0.clearButtonMode = .whileEditing
                }
                (textField.rx.textInput <-> item.inputText).disposed(by: disposeBag)
                self.textFieldList.append(textField)
                self.contentView.addSubview(textField)
                top = textField.bottom
            }
            top += GXALERT_YSPACE/2
            self.infoLabel.frame = CGRect(x: left, y: top, width: width, height: 18)
            self.contentView.addSubview(self.infoLabel)
            top = self.infoLabel.bottom
        }
        self.contentView.frame = CGRect(x: 0, y: 0, width: GXALERT_MAXSIZE.width, height: top + GXALERT_YMARGIN)
        top = self.contentView.bottom

        if actions.count == 2 {
            top += 1.0

            let btnWidth = (GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2 - GXALERT_XSPACE) / 2
            let leftItem = actions[0]
            let leftButton = UIButton(type: .custom).then {
                $0.titleLabel?.font = leftItem.titleFont
                $0.setTitle(leftItem.title, for: .normal)
                $0.setTitleColor(leftItem.titleColor, for: .normal)
                $0.setBackgroundColor(leftItem.backgroundColor, for: .normal)
                $0.setBackgroundColor(leftItem.selBackgroundColor, for: .highlighted)
                $0.layer.masksToBounds = true
                if leftItem.borderWidth > 0 {
                    $0.layer.borderWidth = leftItem.borderWidth
                    $0.layer.borderColor = leftItem.titleColor?.cgColor
                }
                $0.layer.cornerRadius = leftItem.height / 2
                $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
            leftButton.frame = CGRect(x: GXALERT_XMARGIN, y: top, width: btnWidth, height: leftItem.height)
            self.buttonList.append(leftButton)
            self.addSubview(leftButton)

            let rightItem = actions[1]
            let rightButton = UIButton(type: .custom).then {
                $0.titleLabel?.font = rightItem.titleFont
                $0.setTitle(rightItem.title, for: .normal)
                $0.setTitleColor(rightItem.titleColor, for: .normal)
                $0.setBackgroundColor(rightItem.backgroundColor, for: .normal)
                $0.setBackgroundColor(rightItem.selBackgroundColor, for: .highlighted)
                $0.layer.masksToBounds = true
                if rightItem.borderWidth > 0 {
                    $0.layer.borderWidth = rightItem.borderWidth
                    $0.layer.borderColor = rightItem.titleColor?.cgColor
                }
                $0.layer.cornerRadius = rightItem.height / 2
                $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
            rightButton.frame = CGRect(x: leftButton.right + GXALERT_XSPACE, y: top, width: btnWidth, height: rightItem.height)
            self.buttonList.append(rightButton)
            self.addSubview(rightButton)

            top = rightButton.bottom + GXALERT_YSPACE
        }
        else {
            for item in actions {
                top += 1.0
                let button = UIButton(type: .custom).then {
                    $0.titleLabel?.font = item.titleFont
                    $0.setTitle(item.title, for: .normal)
                    $0.setTitleColor(item.titleColor, for: .normal)
                    $0.setBackgroundColor(item.backgroundColor, for: .normal)
                    $0.setBackgroundColor(item.selBackgroundColor, for: .highlighted)
                    $0.layer.masksToBounds = true
                    if item.borderWidth > 0 {
                        $0.layer.borderWidth = item.borderWidth
                        $0.layer.borderColor = item.titleColor?.cgColor
                    }
                    $0.layer.cornerRadius = item.height / 2
                    $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
                }
                let btnWidth = GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2
                button.frame = CGRect(x: GXALERT_XMARGIN, y: top, width: btnWidth, height: item.height)
                self.buttonList.append(button)
                self.addSubview(button)
                top = button.bottom + GXALERT_YSPACE
            }
        }
        self.frame = CGRect(x: 0, y: 0, width: GXALERT_MAXSIZE.width, height: top)
    }

    func createSheet(title: String? = nil,
                     message: String? = nil,
                     actions: [GXAlertAction] = []) {
        self.actions = actions
        let margin = GXALERT_YMARGIN/2
        var top = margin, left = GXALERT_XMARGIN
        let textWidth = SCREEN_MIN_WIDTH - GXALERT_XMARGIN * 2
        if let letTitle = title {
            self.titleLabel.text = letTitle
            let height = letTitle.height(width: textWidth, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: left, y: top, width: textWidth, height: ceil(height))
            self.contentView.addSubview(self.titleLabel)
            top = self.titleLabel.bottom
        }
        if let letMessage = message {
            top += GXALERT_YSPACE/2
            self.messageLabel.text = letMessage
            let height = letMessage.height(width: textWidth, font: self.messageLabel.font)
            self.messageLabel.frame = CGRect(x: left, y: top, width: textWidth, height: ceil(height))
            self.contentView.addSubview(self.messageLabel)
            top = self.messageLabel.bottom
        }
        self.contentView.frame = CGRect(x: 0, y: 0, width: SCREEN_MIN_WIDTH, height: top + margin)
        if top > margin {
            top = self.contentView.bottom
        } else {
            top = 0
        }
        for index in 0..<actions.count {
            let item = actions[index]
            let button = UIButton(type: .custom).then {
                $0.titleLabel?.font = item.titleFont
                $0.setTitle(item.title, for: .normal)
                $0.setTitleColor(item.titleColor, for: .normal)
                $0.setBackgroundColor(.white, for: .normal)
                $0.setBackgroundColor(.gx_lightGray, for: .highlighted)
                $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
            if index == actions.count - 1 {
                top += 8.0
                let btnHeight = item.height + (UIWindow.gx_frontWindow?.safeAreaInsets.bottom ?? 0)
                button.frame = CGRect(x: 0, y: top, width: SCREEN_MIN_WIDTH, height: btnHeight)
                if btnHeight > 0 {
                    button.setTitle(nil, for: .normal)
                    let label = UILabel().then {
                        $0.frame = CGRect(x: 0, y: 0, width: SCREEN_MIN_WIDTH, height: item.height)
                        $0.textAlignment = .center
                        $0.text = item.title
                        $0.font = item.titleFont
                        $0.textColor = item.titleColor
                    }
                    button.addSubview(label)
                }
            } else if index > 0 || top > 0 {
                top += 0.5
                button.frame = CGRect(x: 0, y: top, width: SCREEN_MIN_WIDTH, height: item.height)
            } else {
                button.frame = CGRect(x: 0, y: top, width: SCREEN_MIN_WIDTH, height: item.height)
            }
            self.buttonList.append(button)
            self.addSubview(button)
            top = button.bottom
        }
        self.frame = CGRect(x: 0, y: 0, width: SCREEN_MIN_WIDTH, height: top)
    }
    
    func createAlertInfo(title: String? = nil,
                         message: String? = nil,
                         info: String? = nil,
                         actions: [GXAlertAction] = []) {
        self.actions = actions

        var top = GXALERT_YMARGIN, left = GXALERT_XMARGIN
        let width = GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2
        if let letTitle = title {
            self.titleLabel.text = letTitle
            self.titleLabel.font = .gx_font(size: 15)
            let height = letTitle.height(width: width, font: self.titleLabel.font)
            self.titleLabel.frame = CGRect(x: left, y: top, width: width, height: ceil(height))
            self.contentView.addSubview(self.titleLabel)
            top = self.titleLabel.bottom
        }
        if let letMessage = message {
            top += GXALERT_YSPACE/2
            self.messageLabel.text = letMessage
            let height = letMessage.height(width: width, font: self.messageLabel.font)
            self.messageLabel.frame = CGRect(x: left, y: top, width: width, height: ceil(height))
            self.contentView.addSubview(self.messageLabel)
            top = self.messageLabel.bottom
        }
        if let letInfo = info {
            top += GXALERT_YSPACE/2
            self.infoLabel.text = letInfo
            self.infoLabel.textAlignment = .center
            self.infoLabel.frame = CGRect(x: left, y: top, width: width, height: 18)
            self.contentView.addSubview(self.infoLabel)
            top = self.infoLabel.bottom
        }
        self.contentView.frame = CGRect(x: 0, y: 0, width: GXALERT_MAXSIZE.width, height: top + GXALERT_YMARGIN)
        top = self.contentView.bottom

        if actions.count == 2 {
            top += 1.0

            let btnWidth = (GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2 - GXALERT_XSPACE) / 2
            let leftItem = actions[0]
            let leftButton = UIButton(type: .custom).then {
                $0.titleLabel?.font = leftItem.titleFont
                $0.setTitle(leftItem.title, for: .normal)
                $0.setTitleColor(leftItem.titleColor, for: .normal)
                $0.setBackgroundColor(leftItem.backgroundColor, for: .normal)
                $0.setBackgroundColor(leftItem.selBackgroundColor, for: .highlighted)
                $0.layer.masksToBounds = true
                if leftItem.borderWidth > 0 {
                    $0.layer.borderWidth = leftItem.borderWidth
                    $0.layer.borderColor = leftItem.titleColor?.cgColor
                }
                $0.cornerRadius = leftItem.height / 2
                $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
            leftButton.frame = CGRect(x: GXALERT_XMARGIN, y: top, width: btnWidth, height: leftItem.height)
            self.buttonList.append(leftButton)
            self.addSubview(leftButton)

            let rightItem = actions[1]
            let rightButton = UIButton(type: .custom).then {
                $0.titleLabel?.font = rightItem.titleFont
                $0.setTitle(rightItem.title, for: .normal)
                $0.setTitleColor(rightItem.titleColor, for: .normal)
                $0.setBackgroundColor(leftItem.backgroundColor, for: .normal)
                $0.setBackgroundColor(leftItem.selBackgroundColor, for: .highlighted)
                $0.layer.masksToBounds = true
                if rightItem.borderWidth > 0 {
                    $0.layer.borderWidth = rightItem.borderWidth
                    $0.layer.borderColor = rightItem.titleColor?.cgColor
                }
                $0.layer.cornerRadius = leftItem.height / 2
                $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
            rightButton.frame = CGRect(x: leftButton.right + GXALERT_XSPACE, y: top, width: btnWidth, height: rightItem.height)
            self.buttonList.append(rightButton)
            self.addSubview(rightButton)

            top = rightButton.bottom + GXALERT_YSPACE
        }
        else {
            for item in actions {
                top += 1.0
                let button = UIButton(type: .custom).then {
                    $0.titleLabel?.font = item.titleFont
                    $0.setTitle(item.title, for: .normal)
                    $0.setTitleColor(item.titleColor, for: .normal)
                    $0.setBackgroundColor(item.backgroundColor, for: .normal)
                    $0.setBackgroundColor(item.selBackgroundColor, for: .highlighted)
                    $0.layer.masksToBounds = true
                    if item.borderWidth > 0 {
                        $0.layer.borderWidth = item.borderWidth
                        $0.layer.borderColor = item.titleColor?.cgColor
                    }
                    $0.layer.cornerRadius = item.height / 2
                    $0.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
                }
                let btnWidth = GXALERT_MAXSIZE.width - GXALERT_XMARGIN * 2
                button.frame = CGRect(x: GXALERT_XMARGIN, y: top, width: btnWidth, height: item.height)
                self.buttonList.append(button)
                self.addSubview(button)
                top = button.bottom + GXALERT_YSPACE
            }
        }
        self.frame = CGRect(x: 0, y: 0, width: GXALERT_MAXSIZE.width, height: top)
    }

    @objc func buttonClicked(_ sender: UIButton) {
        var title = sender.title(for: .normal)
        if title == nil {
            if let label = sender.subviews.last as? UILabel {
                title = label.text
            }
        }
        if let action = self.actions.first(where: { $0.title == title }) {
            action.action?(self)
        }
    }
}
