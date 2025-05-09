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
    
    class func gx_minuteSecond(time: Int) -> String {
        let m = time/60%60
        let s = time%60
        return String(format: "%02d:%02d", m, s)
    }
    
    class func gx_chargingTime(seconds: Int) -> String {
        let totalMins = seconds / 60
        if totalMins <= 1 {
            return "1min"
        }
        else if totalMins < 60 {
            return "\(totalMins)mins"
        }
        else {
            let hours = totalMins / 60
            let mins = totalMins % 60
            return "\(hours)h\(mins)m"
        }
    }

    class func gx_sizeToMBString(bytes: UInt) -> String {
        if bytes < 1024 * 1024 {
            return String(format: "%dKB", bytes/1024)
        }
        else {
            return String(format: "%.2fMB", bytes/(1024 * 1024))
        }
    }
    
    class func gx_h5Url(id: Int) -> String {
        return "https://h5.marsenergyev.com/#/agreement/\(id)"
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
                         messageAttributedText: NSAttributedString? = nil,
                         cancelTitle: String? = "Cancel",
                         actionTitle: String? = nil,
                         actionStyle: UIAlertAction.Style = .default,
                         actionHandler: ((GXAlertView, Int) -> Void)? = nil,
                         handler: ((GXAlertView, Int) -> Void)? = nil) {
        let alert = GXAlertView(frame: .zero)
        var actions: [GXAlertAction] = []
        if (actionTitle != nil) {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            cancelAction.titleFont = .gx_font(size: 17)
            cancelAction.titleColor = .gx_green
            cancelAction.borderWidth = 1.0
            cancelAction.backgroundColor = .white
            cancelAction.selBackgroundColor = .gx_background
            if (actionHandler != nil) {
                cancelAction.action = { alertView in
                    actionHandler?(alertView, 0)
                    alertView.hide(animated: true)
                }
            }
            else {
                cancelAction.action = { alertView in
                    handler?(alertView, 0)
                    alertView.hide(animated: true)
                }
            }
            actions.append(cancelAction)

            let action = GXAlertAction()
            action.title = actionTitle
            if actionStyle == .destructive {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_red
            }
            else if actionStyle == .default {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .white
            }
            else {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_black
            }
            action.backgroundColor = .gx_green
            action.selBackgroundColor = .gx_drakGreen
            if (actionHandler != nil) {
                action.action = { alertView in
                    actionHandler?(alert, 1)
                }
            }
            else {
                action.action = { alertView in
                    handler?(alertView, 1)
                    alertView.hide(animated: true)
                }
            }
            actions.append(action)
        }
        else {
            let cancelAction = GXAlertAction()
            cancelAction.title = cancelTitle
            if actionStyle == .destructive {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_red
            }
            else if actionStyle == .default {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .white
            }
            else {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_black
            }
            cancelAction.backgroundColor = .gx_green
            cancelAction.selBackgroundColor = .gx_drakGreen
            if (actionHandler != nil) {
                cancelAction.action = { alertView in
                    actionHandler?(alert, 0)
                }
            }
            else {
                cancelAction.action = { alertView in
                    handler?(alertView, 0)
                    alertView.hide(animated: true)
                }
            }
            actions.append(cancelAction)
        }
        alert.createAlert(title: title, message: message, messageAttributedText: messageAttributedText, actions: actions)
        alert.show(to: view, style: .alert, backgoundTapDismissEnable: false, usingSpring: true)
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
        cancelAction.titleColor = .gx_green
        cancelAction.borderWidth = 1.0
        cancelAction.backgroundColor = .white
        cancelAction.selBackgroundColor = .gx_background
        cancelAction.action = { alertView in
            handler?(alertView, 0)
            alertView.hide(animated: true)
        }
        actions.append(cancelAction)

        let action = GXAlertAction()
        action.title = actionTitle
        if actionStyle == .destructive {
            action.titleFont = .gx_font(size: 17)
            action.titleColor = .gx_red
        }
        else if actionStyle == .default {
            action.titleFont = .gx_font(size: 17)
            action.titleColor = .white
        }
        else {
            action.titleFont = .gx_font(size: 17)
            action.titleColor = .gx_black
        }
        action.backgroundColor = .gx_green
        action.selBackgroundColor = .gx_lightGreen
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
            cancelAction.titleColor = .gx_green
            cancelAction.borderWidth = 1.0
            cancelAction.backgroundColor = .white
            cancelAction.selBackgroundColor = .gx_background
            cancelAction.action = { alertView in
                handler?(alertView, 0)
                alertView.hide(animated: true)
            }
            actions.append(cancelAction)

            let action = GXAlertAction()
            action.title = actionTitle
            if actionStyle == .destructive {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_red
            }
            else if actionStyle == .default {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .white
            }
            else {
                action.titleFont = .gx_font(size: 17)
                action.titleColor = .gx_black
            }
            action.backgroundColor = .gx_green
            action.selBackgroundColor = .gx_lightGreen
            
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
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_red
            }
            else if actionStyle == .default {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .white
            }
            else {
                cancelAction.titleFont = .gx_font(size: 17)
                cancelAction.titleColor = .gx_black
            }
            cancelAction.backgroundColor = .gx_green
            cancelAction.selBackgroundColor = .gx_lightGreen
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
