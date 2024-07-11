//
//  GXTextView.swift
//  QROrderSystem
//
//  Created by Gin on 2021/9/30.
//

import UIKit

class GXTextView: UITextView {

    lazy var placeHolderLabel: UILabel = {
        $0.font = UIFont.gx_font(size: 16)
        $0.text = "请输入"
        $0.textColor = UIColor.hex(hexString: "#C1C1C1")
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    var placeholderColor: UIColor? {
        didSet {
            placeHolderLabel.textColor = placeholderColor
        }
    }
    
    var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
        }
    }
    
    override var font: UIFont? {
        didSet {
            if font != nil {
                placeHolderLabel.font = font
            }
        }
    }
    
    // 重写text
    override var text: String? {
        didSet {
            // 根据文本是否有内容而显示占位label
            placeHolderLabel.isHidden = hasText
        }
    }

    // frame
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    // xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // 添加控件,设置约束
    fileprivate func setupUI() {
        // 监听内容的通知
        NotificationCenter.default.addObserver(self, selector: #selector(GXTextView.valueChange), name: UITextView.textDidChangeNotification, object: nil)
        
        // 添加控件
        addSubview(placeHolderLabel)
    }
    
    // 内容改变的通知方法
    @objc fileprivate func valueChange() {
        //占位文字的显示与隐藏
        placeHolderLabel.isHidden = hasText
    }
    
    // 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 子控件布局
    override func layoutSubviews() {
        super.layoutSubviews()

        let top = self.textContainerInset.top
        let left = self.textContainer.lineFragmentPadding + self.textContainerInset.left
        let right = self.textContainer.lineFragmentPadding + self.textContainerInset.right
        let width = self.frame.width - left - right
        let height = self.placeholder?.height(width: self.frame.width,
                                              font: self.placeHolderLabel.font ?? .gx_font(size: 16))
        self.placeHolderLabel.frame = CGRect(x: left, y: top, width: width, height: height ?? 0)
    }
}
