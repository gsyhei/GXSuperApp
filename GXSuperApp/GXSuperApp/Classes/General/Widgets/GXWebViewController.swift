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

class GXWebViewController: GXBaseViewController {

    private lazy var webView: WKWebView = {
        return WKWebView(frame: self.view.bounds).then {
            $0.backgroundColor = .gx_background
            $0.navigationDelegate = self
            $0.uiDelegate = self
            $0.isMultipleTouchEnabled = true
        }
    }()
    private var urlString: String?
    private var htmlString: String?

    private lazy var progressView: UIProgressView = {
        return UIProgressView(progressViewStyle: .bar).then {
            $0.trackTintColor = .clear
            $0.progressTintColor = .gx_blue
        }
    }()

    deinit {
        self.removeObservers()
    }
    
    required init(urlString: String?, htmlString: String? = nil, title: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.urlString = urlString
        self.htmlString = htmlString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppearForOnlyLoading() {
        self.webRequestStart()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
    }
    
    override func setupViewController() {
        self.view.backgroundColor = .white
        self.gx_addBackBarButtonItem()
        self.navigationItem.rightBarButtonItem =
        UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBarButtonItemTapped))
        
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.height.equalTo(2)
        }
    }

    func addObservers() {
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)
    }

    func removeObservers() {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    private func webRequestStart() {
        if let urlStr = self.urlString, let url = URL(string: urlStr) {
            self.webView.load(URLRequest(url: url))
            self.progressView.alpha = 1.0
            self.progressView.progress = 0.0
            XCGLogger.info("web url: \(urlStr)")
        }
        else if let htmlStr = self.htmlString {
            self.webView.loadHTMLString(htmlStr, baseURL: nil)
            self.progressView.alpha = 1.0
            self.progressView.progress = 1.0
            XCGLogger.info("web html: \(htmlStr)")
        }
    }
    
    @objc func refreshBarButtonItemTapped() {
        if self.progressView.progress > 0 {
            self.webView.reload()
        }
        else if let urlStr = self.urlString, let url = URL(string: urlStr) {
            self.webView.load(URLRequest(url: url))
        }
        else if let htmlStr = self.htmlString {
            self.webView.loadHTMLString(htmlStr, baseURL: nil)
        }
    }

    override func gx_backBarButtonItemTapped() {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        } else {
            super.gx_backBarButtonItemTapped()
        }
    }
}


extension GXWebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        self.progressView.alpha = 0
        XCGLogger.info("didFail:withError: \(error)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        self.progressView.alpha = 0
        XCGLogger.info("didFailProvisionalNavigation:withError: \(error)")
    }
}

extension GXWebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            guard let estimatedProgress = change?[NSKeyValueChangeKey.newKey] as? Double else { return }
            if estimatedProgress >= 1.0 {
                self.progressView.setProgress(1.0, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(.promise, duration: 0.2) {
                        self.progressView.alpha = 0
                    }
                }
            }
            else {
                self.progressView.setProgress(Float(estimatedProgress), animated: true)
            }
        }
    }
}
