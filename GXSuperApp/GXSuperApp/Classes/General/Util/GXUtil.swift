//
//  GXUtil.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/7.
//

import UIKit
import RxSwift
import GXAlert_Swift

class GXUtil: NSObject {

    enum GXQRCodeType: String {
        case none     = ""
        case url      = "http"
        case user     = "heivibe://user?"
        case event    = "heivibe://event?"
        case ticket   = "heivibe://ticket?"
        case activity = "heivibe://activity?"
    }

    /// 获得二维码字符串 - heivibe://<动作>?<参数>
    class func gx_qrCode(type: GXQRCodeType, text: String?) -> String {
        guard let text = text else { return type.rawValue }
        return type.rawValue + text
    }

    /// 获得二维码类型 - heivibe://<动作>?<参数>
    class func gx_qrCodeType(qrCode: String?) -> GXQRCodeType {
        guard let qrCode = qrCode else { return .none }
        if qrCode.hasPrefix(GXQRCodeType.user.rawValue) {
            return .user
        }
        if qrCode.hasPrefix(GXQRCodeType.event.rawValue) {
            return .event
        }
        if qrCode.hasPrefix(GXQRCodeType.ticket.rawValue) {
            return .ticket
        }
        if qrCode.hasPrefix(GXQRCodeType.activity.rawValue) {
            return .activity
        }
        if qrCode.hasPrefix(GXQRCodeType.url.rawValue + "://") {
            return .url
        }
        if qrCode.hasPrefix(GXQRCodeType.url.rawValue + "s://") {
            return .url
        }
        if qrCode.hasPrefix("HTTP://") {
            return .url
        }
        if qrCode.hasPrefix("HTTPS://") {
            return .url
        }    
        return .none
    }

    class func gx_countdownTimer(second: Int, immediately: Bool = true, duration: ((Int) -> Void)?) -> Single<Void> {
        guard second > 0 else { return Single<Void>.just(()) }
        if immediately {  duration?(second) }
        return Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map{ second-(immediately ? ($0 + 1) : $0) }
            .take(second+(immediately ? 0 : 1))
            .do(onNext: { (index) in
                duration?(index)
            })
            .filter{ return $0 == 0 }
            .map{_ in return () }
            .asSingle()
    }

    class func gx_hour(time: Int) -> String {
        let h = time/3600
        return String(format: "%02d", h)
    }

    class func gx_minute(time: Int) -> String {
        let m = time/60%60
        return String(format: "%02d", m)
    }

    class func gx_second(time: Int) -> String {
        let s = time%60
        return String(format: "%02d", s)
    }

    class func gx_sizeToMBString(bytes: UInt) -> String {
        if bytes < 1024 * 1024 {
            return String(format: "%dKB", bytes/1024)
        }
        else {
            return String(format: "%.2fMB", bytes/(1024 * 1024))
        }
    }

    class func showAlert(to vc: UIViewController,
                         style: UIAlertController.Style = .alert,
                         title: String? = nil,
                         message: String? = nil,
                         cancelTitle:String? = "取消",
                         other actionTitles: [String] = [],
                         handler: ((Int) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
            handler?(0)
        }
        alert.addAction(cancelAction)
        for index in 0..<actionTitles.count {
            let action = UIAlertAction(title: actionTitles[index], style: .default) { action in
                handler?(index + 1)
            }
            alert.addAction(action)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = vc.view
            alert.popoverPresentationController?.sourceRect = CGRect(origin: vc.view.center, size: CGSize(width: 1, height: 1))
        }
        // 标题字体样式
        if let alertTitle = title {
            let titleFont = UIFont.gx_boldFont(size: 17)
            let titleAttribute = NSMutableAttributedString(string: alertTitle)
            titleAttribute.addAttributes([.font:titleFont, .foregroundColor:UIColor.gx_black], range:NSMakeRange(0, alertTitle.count))
            alert.setValue(titleAttribute, forKey: "attributedTitle")
        }
        // 消息内容样式
        if let alertMessage = message {
            let messageFont = UIFont.gx_font(size: 15)
            let messageAttribute = NSMutableAttributedString(string: alertMessage)
            messageAttribute.addAttributes([.font:messageFont, .foregroundColor:UIColor.gx_drakGray], range:NSMakeRange(0, alertMessage.count))
            alert.setValue(messageAttribute, forKey: "attributedMessage")
        }
        vc.present(alert, animated: true, completion: nil)
    }

    class func showAlert(to vc: UIViewController,
                         style: UIAlertController.Style = .alert,
                         title: String? = nil,
                         message: String? = nil,
                         cancelTitle: String? = "取消",
                         actionTitle: String,
                         actionStyle: UIAlertAction.Style = .default,
                         handler: ((Int) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
            handler?(0)
        }
        alert.addAction(cancelAction)
        let action = UIAlertAction(title: actionTitle, style: actionStyle) { action in
            handler?(1)
        }
        alert.addAction(action)
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = vc.view
            alert.popoverPresentationController?.sourceRect = CGRect(origin: vc.view.center, size: CGSize(width: 1, height: 1))
        }
        // 标题字体样式
        if let alertTitle = title {
            let titleFont = UIFont.gx_boldFont(size: 17)
            let titleAttribute = NSMutableAttributedString(string: alertTitle)
            titleAttribute.addAttributes([.font:titleFont, .foregroundColor:UIColor.gx_black], range:NSMakeRange(0, alertTitle.count))
            alert.setValue(titleAttribute, forKey: "attributedTitle")
        }
        // 消息内容样式
        if let alertMessage = message {
            let messageFont = UIFont.gx_font(size: 15)
            let messageAttribute = NSMutableAttributedString(string: alertMessage)
            messageAttribute.addAttributes([.font:messageFont, .foregroundColor:UIColor.gx_drakGray], range:NSMakeRange(0, alertMessage.count))
            alert.setValue(messageAttribute, forKey: "attributedMessage")
        }
        vc.present(alert, animated: true, completion: nil)
    }

    class func showAlert(to view: UIView? = nil,
                         title: String? = nil,
                         message: String? = nil,
                         cancelTitle: String? = "取消",
                         actionTitle: String? = nil,
                         actionStyle: UIAlertAction.Style = .default,
                         handler: ((GXAlertView, Int) -> Void)? = nil) {
        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []
        if (actionTitle != nil) {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            cancelAction.titleFont = .gx_font(size: 17)
            cancelAction.titleColor = .gx_black
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)

            let action = GXAlertAction()
            action.title = actionTitle
            if actionStyle == .destructive {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_red
            }
            else if actionStyle == .default {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_drakGreen
            }
            else {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_black
            }
            action.action = { alertView in
                handler?(alertView, 1)
                alertView.hide(animated: true)
            }
            actions.append(action)
        }
        else {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            if actionStyle == .destructive {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_red
            }
            else if actionStyle == .default {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_drakGreen
            }
            else {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_black
            }
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)
        }
        alert.createAlert(title: title, message: message, actions: actions)
        alert.show(to: view, style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }

    class func showReturnAlert(to view: UIView? = nil,
                               title: String? = nil,
                               message: String? = nil,
                               cancelTitle: String? = "取消",
                               actionTitle: String? = nil,
                               actionStyle: UIAlertAction.Style = .default,
                               handler: ((GXAlertView, Int) -> Void)? = nil) -> UIView? {
        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []
        if (actionTitle != nil) {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            cancelAction.titleFont = .gx_font(size: 17)
            cancelAction.titleColor = .gx_black
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)

            let action = GXAlertAction()
            action.title = actionTitle
            if actionStyle == .destructive {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_red
            }
            else if actionStyle == .default {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_drakGreen
            }
            else {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_black
            }
            action.action = { alertView in
                handler?(alertView, 1)
                alertView.hide(animated: true)
            }
            actions.append(action)
        }
        else {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            if actionStyle == .destructive {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_red
            }
            else if actionStyle == .default {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_drakGreen
            }
            else {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_black
            }
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)
        }
        alert.createAlert(title: title, message: message, actions: actions)
        alert.show(to: view, style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
        return alert
    }

    class func showInputAlert(title: String? = nil,
                              placeholder: String? = nil,
                              actionStyle: UIAlertAction.Style = .default,
                              handler: ((GXAlertView, Int) -> Void)? = nil) {
        let cancelTitle: String = "取消"
        let actionTitle: String = "确定"

        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []
        let cancelAction = GXAlertAction()
        cancelAction.title = cancelTitle
        cancelAction.titleFont = .gx_font(size: 17)
        cancelAction.titleColor = .gx_black
        cancelAction.action = { alertView in
            handler?(alertView, 0)
            alertView.hide(animated: true)
        }
        actions.append(cancelAction)

        let action = GXAlertAction()
        action.title = actionTitle
        if actionStyle == .destructive {
            action.titleFont = .gx_boldFont(size: 17)
            action.titleColor = .gx_red
        }
        else if actionStyle == .default {
            action.titleFont = .gx_boldFont(size: 17)
            action.titleColor = .gx_drakGreen
        }
        else {
            action.titleFont = .gx_font(size: 17)
            action.titleColor = .gx_black
        }
        action.action = { alertView in
            alertView.endEditing(true)
            handler?(alertView, 1)
        }
        actions.append(action)

        let input = GXAlertInput()
        input.keyboardType = .numberPad
        input.inputPlaceholder = placeholder

        alert.createAlert(title: title, actions: actions, inputs: [input])
        if let textField = alert.textFieldList.first {
            textField.rx.text.changed.subscribe { text in
                alert.infoLabel.text = nil
            }.disposed(by: alert.disposeBag)
        }
        alert.show(style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }

    class func showSheet(title: String? = nil,
                         message: String? = nil,
                         cancelTitle: String? = "取消",
                         otherActions: [GXAlertAction] = [],
                         handler: ((GXAlertView, Int) -> Void)? = nil) {
        let alert = GXAlertView(frame: .zero)

        let cancelAction = GXAlertAction()
        cancelAction.title = cancelTitle
        cancelAction.titleFont = .gx_font(size: 17)
        cancelAction.titleColor = .gx_black
        cancelAction.action = { alertView in
            handler?(alertView, 0)
            alertView.hide(animated: true)
        }
        for index in 0..<otherActions.count {
            let subAction = otherActions[index]
            if (subAction.action == nil) {
                subAction.action = { alertView in
                    handler?(alertView, (index + 1))
                    alertView.hide(animated: true)
                }
            }
        }
        let actions: [GXAlertAction] = otherActions + [cancelAction]
        alert.createSheet(title: title, message: message, actions: actions)
        alert.show(style: .sheetBottom, backgoundTapDismissEnable: false, usingSpring: true)
    }
    
    class func showInfoAlert(to view: UIView? = nil,
                             title: String? = nil,
                             message: String? = nil,
                             info: String? = nil,
                             cancelTitle: String? = "取消",
                             actionTitle: String? = nil,
                             actionStyle: UIAlertAction.Style = .default,
                             handler: ((GXAlertView, Int) -> Void)? = nil) {
        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []
        if (actionTitle != nil) {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            cancelAction.titleFont = .gx_font(size: 17)
            cancelAction.titleColor = .gx_black
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)

            let action = GXAlertAction()
            action.title = actionTitle
            if actionStyle == .destructive {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_red
            }
            else if actionStyle == .default {
                action.titleFont = .gx_boldFont(size: 17)
                action.titleColor = .gx_drakGreen
            }
            else {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_black
            }
            action.action = { alertView in
                handler?(alertView, 1)
                alertView.hide(animated: true)
            }
            actions.append(action)
        }
        else {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            if actionStyle == .destructive {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_red
            }
            else if actionStyle == .default {
                cancelAction.titleFont = .gx_boldFont(size: 17)
                cancelAction.titleColor = .gx_drakGreen
            }
            else {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_black
            }
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)
        }
        alert.createAlertInfo(title: title, message: message, info: info, actions: actions)
        alert.show(to: view, style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
    }
}
