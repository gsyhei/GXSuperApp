//
//  GXBaseChatViewController.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/15.
//

import UIKit
import HXPhotoPicker

class GXBaseChatViewController: GXBaseViewController {
    @IBOutlet weak var tableView: GXMessagesLoadTableView!
    @IBOutlet weak var inputBar: UIView!
    @IBOutlet weak var textInputBar: UIView!
    @IBOutlet weak var textView: GXTextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageInputBar: UIView!
    @IBOutlet weak var inputBarHeightLC: NSLayoutConstraint!
    @IBOutlet weak var inputHeightLC: NSLayoutConstraint!
    @IBOutlet weak var inputBottomLC: NSLayoutConstraint!
    @IBOutlet weak var inputRightLC: NSLayoutConstraint!
    private(set) var themeType: Int = 0 //0-黑色，1-白色
    private var photoAssets: [PhotoAsset] = []
    
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
        self.sendButton.setBackgroundColor(.gx_green, for: .normal)
        self.tableView.placeholder = "暂无消息"
        self.textView.gx_setMarginZero()
        self.textView.font = .gx_font(size: 17)
        self.textView.placeholder = "写评论，畅聊你的想法吧"
        self.textView.delegate = self
        self.textView.rx.didChange.asObservable().subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            //guard self.textView.markedTextRange == nil else { return }
            var text = self.textView.text ?? ""
            self.setSendButton(hidden: text.count == 0, animated: true)
            let maxCount: Int = 500
            if text.count > maxCount {
                text = text.substring(to: maxCount)
                self.textView.text = text
            }
        }).disposed(by: disposeBag)
        // 更新inputBar
        self.setTextViewDidChange(self.textView, animated: false)
        // 更新发送按钮
        self.setSendButton(hidden: true, animated: false)
    }

    /// 设置主题类型
    /// - Parameter type: 0-黑色，1-白色
    public func setThemeType(type: Int) {
        self.themeType = type
        if type == 1 {
            self.view.backgroundColor = .gx_background
            self.gx_addBackBarButtonItem()
            self.gx_addNavTopView(color: .white)
            self.tableView.backgroundColor = .white
            self.tableView.separatorColor = .gx_lightGray
            self.inputBar.backgroundColor = .gx_background
            self.textInputBar.backgroundColor = .white
            self.textView.placeholderColor = .hex(hexString: "#C1C1C1")
            self.textView.textColor = .gx_black
            self.photoButton.setImage(UIImage(named: "chat_photo_b"), for: .normal)

            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.gx_black
            let nbAppearance = UINavigationBarAppearance()
            nbAppearance.configureWithTransparentBackground()
            nbAppearance.backgroundColor = UIColor.white
            nbAppearance.shadowColor = .gx_lightGray
            nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
            let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
            bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
            bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_lightGray, .font: UIFont.gx_boldFont(size: 15)]
            nbAppearance.buttonAppearance = bbiAppearance
            nbAppearance.doneButtonAppearance = bbiAppearance
            nbAppearance.backButtonAppearance = bbiAppearance
            self.navigationController?.navigationBar.standardAppearance = nbAppearance
            if #available(iOS 15.0, *) {
                let nbAppearance = UINavigationBarAppearance()
                nbAppearance.configureWithTransparentBackground()
                nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
                let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
                bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gx_black, .font: UIFont.gx_boldFont(size: 15)]
                bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_gray, .font: UIFont.gx_boldFont(size: 15)]
                nbAppearance.buttonAppearance = bbiAppearance
                nbAppearance.doneButtonAppearance = bbiAppearance
                nbAppearance.backButtonAppearance = bbiAppearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = nbAppearance
            }
        }
        else {
            self.view.backgroundColor = .hex(hexString: "#2A2A2A")
            self.addBackBarButtonItem(imageNamed: "w_back")
            self.gx_addNavTopView(color: .black)
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = .hex(hexString: "#111111")
            self.inputBar.backgroundColor = .hex(hexString: "#2A2A2A")
            self.textInputBar.backgroundColor = .hex(hexString: "#4B4B4B")
            self.textView.placeholderColor = .gx_drakGray
            self.textView.textColor = .white
            self.photoButton.setImage(UIImage(named: "chat_photo"), for: .normal)

            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            let nbAppearance = UINavigationBarAppearance()
            nbAppearance.configureWithTransparentBackground()
            nbAppearance.backgroundColor = UIColor.black
            nbAppearance.shadowColor = .hex(hexString: "#111111")
            nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.gx_boldFont(size: 15)]
            let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
            bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.gx_boldFont(size: 15)]
            bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_lightGray, .font: UIFont.gx_boldFont(size: 15)]
            nbAppearance.buttonAppearance = bbiAppearance
            nbAppearance.doneButtonAppearance = bbiAppearance
            nbAppearance.backButtonAppearance = bbiAppearance
            self.navigationController?.navigationBar.standardAppearance = nbAppearance
            if #available(iOS 15.0, *) {
                let nbAppearance = UINavigationBarAppearance()
                nbAppearance.configureWithTransparentBackground()
                nbAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.gx_boldFont(size: 15)]
                let bbiAppearance = UIBarButtonItemAppearance(style: .plain)
                bbiAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.gx_boldFont(size: 15)]
                bbiAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.gx_lightGray, .font: UIFont.gx_boldFont(size: 15)]
                nbAppearance.buttonAppearance = bbiAppearance
                nbAppearance.doneButtonAppearance = bbiAppearance
                nbAppearance.backButtonAppearance = bbiAppearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = nbAppearance
            }
        }
    }

    public func sendMessage(text: String, photoAssets: [PhotoAsset]) {
         fatalError("Must Override.")
    }

    public func clearMessage()  {
        self.photoAssets.removeAll()
        self.textView.text = nil
        self.setTextViewDidChange(self.textView, animated: true)
    }

    func scrollToBottom(animated: Bool) {
        let numberOfRows = self.tableView.numberOfRows(inSection: 0)
        guard numberOfRows > 0 else { return }
        let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    func setSendButton(hidden: Bool, animated: Bool) {
        let alpha = hidden ? 0.0 : 1.0
        if self.sendButton.alpha == alpha { return }
        let right = hidden ? 16.0 : 76.0
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.inputRightLC.constant = right
                self.sendButton.alpha = alpha
                self.view.layoutIfNeeded()
            }
        }
        else {
            self.inputRightLC.constant = right
            self.sendButton.alpha = alpha
        }
    }

    func setTextViewDidChange(_ textView: UITextView, animated: Bool) {
        let textFont: UIFont = textView.font ?? .gx_font(size: 17)
        let insetHeight = 16.0, minHeight = 32.0
        let maxHeight = insetHeight + textFont.lineHeight * 5
        let width = textView.width
        let textHeight = textView.text.height(width: width, font: textFont)
        var inputHeight = insetHeight + textHeight
        inputHeight = max(minHeight, inputHeight)
        inputHeight = min(maxHeight, inputHeight)
        self.inputHeightLC.constant = inputHeight
        let isPhotoBarHidden = self.photoAssets.count == 0
        let inputBarHeight = isPhotoBarHidden ? (inputHeight + 20.0):(inputHeight + 65.0)
        self.imageInputBar.isHidden = isPhotoBarHidden
        guard self.inputBarHeightLC.constant != inputBarHeight else { return }
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.inputBarHeightLC.constant = inputBarHeight
                self.view.layoutIfNeeded()
            }
        } 
        else {
            self.inputBarHeightLC.constant = inputBarHeight
        }
    }
}

extension GXBaseChatViewController: UITextViewDelegate {
    func keyboardChangeFrame(notification: Notification) {
        let endFrame: CGRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration: Double = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let options: UIView.AnimationOptions = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationOptions ?? .curveLinear
        let bottom = self.view.safeAreaInsets.bottom
        let height = self.view.frame.height - endFrame.origin.y
        let endBottom = max(height - bottom, 0)
        UIView.animate(withDuration: duration, delay: 0.0, options: options) {
            self.inputBottomLC.constant = endBottom
            self.view.layoutIfNeeded()
        }
        self.tableView.scrollToBottom(animated: true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.setTextViewDidChange(textView, animated: true)
    }
}

extension GXBaseChatViewController {
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.sendMessage(text: self.textView.text ?? "", photoAssets: self.photoAssets)
    }
    @IBAction func photoButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var config: PickerConfiguration = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.selectMode = .single
        config.selectOptions = .photo
        config.photoSelectionTapAction = .quickSelect
        config.photoList.allowAddCamera = true
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoList.rowNumber = 3
        let vc = PhotoPickerController.init(config: config)
        vc.finishHandler = {[weak self] (result, picker) in
            guard let asset = result.photoAssets.first else { return }
            self?.updatePhotoAsset(asset: asset)
        }
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        self.photoAssets.removeAll()
        self.setTextViewDidChange(self.textView, animated: true)
    }
    func updatePhotoAsset(asset: PhotoAsset) {
        self.photoAssets = [asset]
        self.setTextViewDidChange(self.textView, animated: true)
        asset.getImage(completion: {[weak self] image in
            self?.imageView.image = image
        })
    }
    
}
