//
//  GXMessagesLoadTableView.swift
//  GXChatUIKit
//
//  Created by Gin on 2022/12/24.
//

import UIKit
import GXCategories
import GXRefresh

class GXMessagesLoadTableView: GXBaseTableView {

    public var isHeaderLoading: Bool = false

    open var headerHeight: CGFloat = 40.0
        
    open var backgroundImage: UIImage? {
        didSet {
            guard let image = backgroundImage else { return }
            let imageView = UIImageView(frame: self.bounds)
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            if #available(iOS 13.0, *) {
                imageView.contentScaleFactor =  self.window?.windowScene?.screen.scale ?? 2.0
            } else {
                imageView.contentScaleFactor =  UIScreen.main.scale
            }
            self.backgroundView = imageView
            self.backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    open override var contentSize: CGSize {
        didSet {
            guard self.isHeaderLoading else { return }
            guard self.dataSource != nil else { return }
            guard self.contentSize != .zero else { return }
            guard self.contentSize.height > oldValue.height else { return }
            
            self.isHeaderLoading = false
            var offset = super.contentOffset
            offset.y = contentSize.height - oldValue.height - self.adjustedContentInset.top
            self.contentOffset = offset
        }
    }

    public convenience init(frame: CGRect, _style: UITableView.Style) {
        self.init(frame: frame, style: _style)
        self.configuration()
    }

    private func configuration() {
        self.backgroundColor = .gx_black
        self.placeholderLabel.textColor = .lightGray
        self.configuration(mode: .onDrag, separatorLeft: false, footerZero: false)
    }
}

extension GXMessagesLoadTableView {
    
    func addMessagesHeader(callback: @escaping GXRefreshComponent.GXRefreshCallBack) {
        let header = GXMessagesLoadHeader(completion: {
            callback()
        })
        header.isTextHidden = true
        header.gx_height = headerHeight;
        header.beginRefreshingAction = {[weak self] in
            self?.isHeaderLoading = true
        }
        self.gx_header = header;
    }
    
    func endHeaderLoading(isReload: Bool = true, isNoMore: Bool = false) {
        if isReload {
            self.reloadData()
        }
        self.gx_header?.endRefreshing()
        if isNoMore {
            self.gx_header = nil;
        }
    }
    
}
