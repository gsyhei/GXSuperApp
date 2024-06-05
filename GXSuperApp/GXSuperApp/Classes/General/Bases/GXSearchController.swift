//
//  GXBaseSearchController.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/13.
//

import UIKit

class GXSearchController: GXBaseViewController {
    
    private var active: Bool = false
    public var isActive: Bool {
        return self.active
    }
        
    public var searchResultsController: UIViewController? {
        fatalError("Must Override.")
    }
    
    public var searchContentInsets: UIEdgeInsets = .zero {
        didSet {
            self.textField.frame = self.searchBar.frame.inset(by: searchContentInsets)
            self.textField.layer.cornerRadius = self.textField.frame.height/2
        }
    }
    
    public lazy var coverBackgroudView: UIControl = {
        return UIControl(frame: self.view.bounds).then {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            $0.addTarget(self, action: #selector(coverBackgroudTapped), for: .touchUpInside)
        }
    }()
    
    public lazy var searchImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "h_search"))
    }()
    
    public lazy var textField: GXBaseTextField = {
        return GXBaseTextField(frame: .zero).then {
            $0.backgroundColor = .gx_inputBackground
            $0.textAlignment = .left
            $0.tintColor = .gx_black
            $0.font = .gx_boldFont(size: 15)
            $0.returnKeyType = .search
            $0.clearButtonMode = .whileEditing
            $0.leftView = self.searchImageView
            $0.leftViewMode = .always
            $0.enablesReturnKeyAutomatically = true
            $0.layer.masksToBounds = true
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            $0.delegate = self
        }
    }()
    
    public lazy var searchBar: UIView = {
        let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44)
        return UIView(frame: rect).then {
            $0.backgroundColor = .white
            $0.addSubview(self.textField)
            self.textField.frame = rect
            self.textField.layer.cornerRadius = rect.height/2
            self.textField.margin = 15.0
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "l_back"), style: .plain, target: self, action: #selector(backItemTapped))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    public override func setupViewController() {}
    
    public func updateSearchResults(searchText: String?) {
        fatalError("Must Override.")
    }
    
    public func searchReturnResults(searchText: String?) {
        fatalError("Must Override.")
    }
    
    @objc func backItemTapped() {
        if self.isActive {
            self.gx_endSearch()
            return
        }
        if (self.navigationController?.popViewController(animated: true) == nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func coverBackgroudTapped() {
        if self.isActive {
            self.gx_endSearch()
        }
    }
}

extension GXSearchController: UITextFieldDelegate {
    
    @objc func textFieldValueChange(_ textField: UITextField) {
        if let text = textField.text, textField.markedTextRange == nil {
            self.searchResultsController?.view.isHidden = text.count == 0
            self.updateSearchResults(searchText: textField.text)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !self.isActive {
            self.gx_beginSearch()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            self.searchResultsController?.view.isHidden = text.count == 0
            self.searchReturnResults(searchText: textField.text)
            textField.resignFirstResponder()
        }
        return false
    }
}

private extension GXSearchController {

    func gx_beginSearch() {
        var rect = self.view.bounds
        if let scrollView = self.searchBar.superview as? UIScrollView {
            scrollView.scrollToTop(animated: true)
            scrollView.isScrollEnabled = false
            if #available(iOS 11.0, *) {
                rect = rect.inset(by: scrollView.adjustedContentInset)
            } else {
                rect = rect.inset(by: scrollView.contentInset)
            }
            rect.origin.y += self.searchBar.height
            rect.size.height -= self.searchBar.height
        }
        self.active = true
        self.coverBackgroudView.frame = rect
        self.view.addSubview(self.coverBackgroudView)
        self.view.bringSubviewToFront(self.coverBackgroudView)
        if let resultsVC = self.searchResultsController {
            self.addChild(resultsVC)
            resultsVC.view.frame = rect
            self.view.addSubview(resultsVC.view)
            resultsVC.didMove(toParent: self)
        }
        self.searchResultsController?.view.alpha = 1
        let inputText: String = self.textField.text ?? ""
        if inputText.isNotBlank() {
            self.searchResultsController?.view.isHidden = false
            self.coverBackgroudView.alpha = 1
        }
        else {
            self.coverBackgroudView.alpha = 0
            self.searchResultsController?.view.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.coverBackgroudView.alpha = 1
            }
        }
    }
    
    func gx_endSearch() {
        if let scrollView = self.searchBar.superview as? UIScrollView {
            scrollView.isScrollEnabled = true
        }
        self.active = false
        self.textField.text = ""
        self.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.1) {
            self.coverBackgroudView.alpha = 0
            self.searchResultsController?.view.alpha = 0
        } completion: { finished in
            self.coverBackgroudView.removeFromSuperview()
            if let resultsVC = self.searchResultsController {
                resultsVC.view.removeFromSuperview()
                resultsVC.removeFromParent()
            }
        }
    }
}
