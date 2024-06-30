//
//  GXTextHUD.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/2.
//

import UIKit

class GXToast: UIControl {

    lazy var toastView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28)).then {
            $0.backgroundColor = UIColor(white: 0, alpha: 0.8)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 8.0
        }
    }()

    lazy var iconIView: UIImageView = {
        return UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
    }()

    lazy var titleLabel: UILabel = {
        return UILabel(frame: CGRect(x: 0, y: 0, width: 28, height: 28)).then {
            $0.textAlignment = .left
            $0.textColor = .white
            $0.font = .gx_font(size: 15)
            $0.numberOfLines = 0
        }
    }()

    deinit {
        NSLog("GXToast deinit.")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addTarget(self, action: #selector(self.dissmisClicked(_:)), for: .touchUpInside)
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
            make.left.equalToSuperview().offset(24.0)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalTo(self.iconIView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-15)
        }
    }

    @objc func dissmisClicked(_ sender: Any?) {

    }

    func showView(to view: UIView, animated: Bool = true) {
        view.addSubview(self)
        guard animated else { return }

        let beginTransform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        self.toastView.transform = beginTransform
        self.toastView.alpha = 0.0
        UIView.animate(withDuration: 0.1) {
            self.toastView.transform = .identity
            self.toastView.alpha = 1.0
        } completion: { finished in
            self.autoHide()
        }
    }

    func autoHide() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            DispatchQueue.main.async {
                self.hideView(animated: true)
            }
        }
    }

    func hideView(animated: Bool = true) {
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

        let maxSize = CGSize(width: SCREEN_WIDTH - 204, height: SCREEN_HEIGHT - 200)
        let textSize = text.size(size: maxSize, font: .gx_font(size: 15))
        var toastSize = CGSize(width: textSize.width + 85, height: ceil(textSize.height) + 30)
        toastSize.height = min(toastSize.height, SCREEN_HEIGHT - 228)
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
        guard error?.errorCode != 401 else { return }
        GXToast.showError(text: error?.localizedDescription, to: view)
    }

    class func showError(text: String?, to view: UIView? = nil) {
        GXToast.show(text: text ?? "", icon: "toast_info", to: view)
    }

    class func showSuccess(text: String?, to view: UIView? = nil) {
        GXToast.show(text: text ?? "", icon: "toast_succ", to: view)
    }

}
