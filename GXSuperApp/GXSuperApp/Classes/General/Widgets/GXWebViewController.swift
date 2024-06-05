//
//  GXWebViewController.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/5.
//

import UIKit
import WebKit
import XCGLogger
import MBProgressHUD

class GXWebViewController: GXBaseViewController, WKNavigationDelegate, WKUIDelegate {

    private lazy var webView: WKWebView = {
        return WKWebView(frame: self.view.bounds).then {
            $0.backgroundColor = .gx_background
            $0.navigationDelegate = self
            $0.uiDelegate = self
            $0.isMultipleTouchEnabled = true
        }
    }()
    private var urlString: String = ""

    deinit {
        self.removeObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()

        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        if let url = URL(string: self.urlString) {
            self.webView.load(URLRequest(url: url))
        }
        XCGLogger.info("web url: \(self.urlString)")
    }

    func addObservers() {
        MBProgressHUD.showLoading(to: self.view)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)
    }

    func removeObservers() {
        if self.isViewLoaded {
            self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }

    init(urlString: String, title: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.urlString = urlString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func gx_backBarButtonItemTapped() {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        } else {
            super.gx_backBarButtonItemTapped()
        }
    }
}

extension GXWebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            guard let estimatedProgress = change?[NSKeyValueChangeKey.newKey] as? Double else { return }
            if estimatedProgress >= 1.0 {
                MBProgressHUD.dismiss(for: self.view)
            }
        }
    }
}
