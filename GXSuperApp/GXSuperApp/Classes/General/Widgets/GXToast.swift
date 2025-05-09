//
//  GXTextHUD.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/2.
//

import UIKit

private let GXTextFont: UIFont = .gx_font(size: 15)
private let GXTextMaxSize: CGSize = .init(width: SCREEN_WIDTH - 200, height: SCREEN_HEIGHT - 230)
private let GXIconSize: CGSize = .init(width: 24, height: 24)
private let GXInsets: UIEdgeInsets = .init(top: 14, left: 16, bottom: 14, right: 16)
private let GXSpacing: CGFloat = 8

class GXToast: UIControl {
    lazy var toastView: UIView = {
        return UIView(frame: CGRect(origin: .zero, size: GXIconSize)).then {
            $0.backgroundColor = UIColor(white: 0, alpha: 0.8)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
        }
    }()

    lazy var iconIView: UIImageView = {
        return UIImageView(frame: CGRect(origin: .zero, size: GXIconSize))
    }()

    lazy var titleLabel: UILabel = {
        return UILabel(frame: CGRect(origin: .zero, size: GXIconSize)).then {
            $0.textAlignment = .left
            $0.textColor = .white
            $0.font = GXTextFont
            $0.numberOfLines = 0
        }
    }()

    deinit {
        NSLog("GXToast deinit.")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {
        self.addSubview(self.toastView)
        self.toastView.addSubview(self.iconIView)
        self.toastView.addSubview(self.titleLabel)

        self.iconIView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(GXInsets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(GXIconSize)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GXInsets.top)
            make.left.equalTo(self.iconIView.snp.right).offset(GXSpacing)
            make.right.equalToSuperview().offset(-GXInsets.right)
            make.bottom.equalToSuperview().offset(-GXInsets.bottom)
        }
    }

    func showView(to view: UIView, animated: Bool = true) {
        view.addSubview(self)
        guard animated else { return }

        let beginTransform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.toastView.transform = beginTransform
        self.toastView.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.toastView.transform = .identity
            self.toastView.alpha = 1.0
        } completion: { finished in
            self.autoHideToast()
        }
    }

    func autoHideToast() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            DispatchQueue.main.async {
                self.hideToast(animated: true)
            }
        }
    }

    func hideToast(animated: Bool = true) {
        guard animated else {
            self.toastView.removeFromSuperview()
            return
        }
        let transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.2) {
            self.toastView.transform = transform
            self.toastView.alpha = 0.0
        } completion: { finished in
            self.removeFromSuperview()
        }
    }
}

extension GXToast {
    class func show(text: String, icon: String, to view: UIView? = nil) {
        let backgroud = (view != nil) ? view : UIWindow.gx_frontWindow
        guard let backView = backgroud else { return }

        let textSize = text.size(size: GXTextMaxSize, font: GXTextFont)
        let contentHeight = max(ceil(textSize.height), GXIconSize.height)
        let toastWidth = GXIconSize.width + ceil(textSize.width) + GXInsets.left + GXInsets.right + GXSpacing
        let toastHeight = contentHeight + GXInsets.top + GXInsets.bottom
        let toastSize = CGSize(width: toastWidth, height: toastHeight)
        
        let top = (backView.frame.height - toastSize.height)/2
        let left = (backView.frame.width - toastSize.width)/2
        let frame = CGRect(origin: CGPoint(x: left, y: top), size: toastSize)
        let toast = GXToast(frame: backView.bounds)
        toast.toastView.frame = frame
        toast.iconIView.image = UIImage(named: icon)
        toast.titleLabel.text = text
        toast.showView(to: backView, animated: true)
    }

    class func showError(_ error: CustomNSError? = nil, to view: UIView? = nil) {
        guard error?.errorCode != NSURLErrorCancelled else { return }
        //guard error?.errorCode != 401 else { return }
        GXToast.showError(text: error?.localizedDescription, to: view)
    }

    class func showError(text: String?, to view: UIView? = nil) {
        GXToast.show(text: text ?? "", icon: "com_toast_ic_failed", to: view)
    }

    class func showSuccess(text: String?, to view: UIView? = nil) {
        GXToast.show(text: text ?? "", icon: "com_toast_ic_success", to: view)
    }

}
