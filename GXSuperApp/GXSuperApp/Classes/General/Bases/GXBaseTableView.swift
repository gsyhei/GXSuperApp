//
//  GXBaseTableView.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/1.
//

import UIKit

class GXPlaceholderView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha == 0 {
            return nil
        }
        for subview in self.subviews {
            let subviewPoint: CGPoint = self.convert(point, to: subview)
            let fitView = subview.hitTest(subviewPoint, with: event)
            if let letFitView = fitView, letFitView.isKind(of: UIButton.self) {
                return letFitView
            }
        }
        return nil
    }
}

class GXBaseTableView: UITableView {
    var placeholder: String? {
        didSet {
            self.placeholderLabel.text = placeholder
        }
    }

    private(set) lazy var placeholderView: GXPlaceholderView = {
        return GXPlaceholderView(frame: self.bounds).then {
            $0.backgroundColor = .clear
            $0.isHidden = true
        }
    }()

    private(set) lazy var placeholderLabel: UILabel = {
        return UILabel().then {
            $0.font = .gx_font(size: 15)
            $0.textAlignment = .center
            $0.textColor = .gx_gray
            $0.text = "暂无数据"
        }
    }()

    private var addAction: GXActionBlock?
    private(set) lazy var addButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 44))
            $0.titleLabel?.font = .gx_boldFont(size: 17)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 22.0
            $0.isHidden = true
            $0.addTarget(self, action: #selector(self.addButtonClicked(_:)), for: .touchUpInside)
        }
    }()

    convenience init(_frame: CGRect, _style: UITableView.Style) {
        self.init(frame: _frame, style: _style)
        self.initTableView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initTableView()
    }
    
    private func initTableView() {
        self.configuration()
        self.separatorColor = .gx_lightGray
        
        self.placeholderView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.placeholderView.snp.centerY).offset(-100)
        }
        self.placeholderView.addSubview(self.addButton)
        self.addButton.snp.makeConstraints { make in
            make.top.equalTo(self.placeholderLabel.snp.bottom).offset(80)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let view = self.superview else { return }
        self.placeholderView.removeFromSuperview()
        view.addSubview(self.placeholderView)
        view.bringSubviewToFront(self.placeholderView)
        self.placeholderView.snp.remakeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    private func numberOfRowsInAllSections() -> Int {
        let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 1
        var rows = 0
        for i in 0 ..< numberOfSections {
            rows += self.dataSource?.tableView(self, numberOfRowsInSection: i) ?? 0
        }
        return rows
    }

    public func gx_reloadData() {
        if self.numberOfRowsInAllSections() == 0 {
            self.placeholderView.isHidden = false
            self.reloadData()
        }
        else {
            self.placeholderView.isHidden = true
            self.reloadData()
        }
    }
}

extension GXBaseTableView {

    @objc func addButtonClicked(_ sender: UIButton) {
        self.addAction?()
    }

    /// 设置添加按钮
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - type: 按钮类型  0-【标题黑、背景绿】， 1-【标题绿、背景黑】
    public func setAddButton(title: String, type: Int = 0, action: GXActionBlock?) {
        self.addButton.isHidden = false
        self.addButton.setTitle(title, for: .normal)
        switch type {
        case 1:
            self.addButton.setTitleColor(.gx_green, for: .normal)
            self.addButton.setBackgroundColor(.gx_black, for: .normal)
        default:
            self.addButton.setTitleColor(.gx_black, for: .normal)
            self.addButton.setBackgroundColor(.gx_green, for: .normal)
        }
        self.addAction = action
    }

    /// 设置tableFooterView并赋予高度
    /// - Parameter height: 高度
    public func setTableFooterView(height: CGFloat) {
        let width = self.frame.width > 0 ? self.frame.width:SCREEN_WIDTH
        self.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }

    /// 设置Section圆角[需在willDisplay处调用]
    public class func setTableView(_ tableView: UITableView, roundView: UIView, margin: CGFloat = 12, at indexPath: IndexPath) {
        //圆角半径
        let cornerRadius:CGFloat = 12.0
        //下面为设置圆角操作（通过遮罩实现）
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        let shapeLayer = CAShapeLayer()
        roundView.layer.mask = nil
        var bounds = roundView.bounds
        bounds.size.width = tableView.width - margin * 2
        //当前分区有多行数据时
        if sectionCount > 1 {
            switch indexPath.row {
                //如果是第一行,左上、右上角为圆角
            case 0:
                bounds.origin.y += 1.0  //这样每一组首行顶部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.topLeft,.topRight],
                                              cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //如果是最后一行,左下、右下角为圆角
            case sectionCount - 1:
                bounds.size.height -= 1.0  //这样每一组尾行底部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.bottomLeft,.bottomRight],
                                              cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
            default: break
            }
        }
        //当前分区只有一行行数据时
        else {
            //四个角都为圆角（同样设置偏移隐藏首、尾分隔线）
            let bezierPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.0, dy: 2.0), cornerRadius: cornerRadius)
            shapeLayer.path = bezierPath.cgPath
            roundView.layer.mask = shapeLayer
        }
    }

    /// 设置Section圆角[需在willDisplay处调用]<特殊可能关注的人第一个只有右边单圆角>
    public class func setFollowTableView(_ tableView: UITableView, roundView: UIView, margin: CGFloat = 12, at indexPath: IndexPath) {
        //圆角半径
        let cornerRadius:CGFloat = 12.0
        //下面为设置圆角操作（通过遮罩实现）
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        let shapeLayer = CAShapeLayer()
        roundView.layer.mask = nil
        var bounds = roundView.bounds
        bounds.size.width = tableView.width - margin * 2
        //当前分区有多行数据时
        if sectionCount > 1 {
            switch indexPath.row {
                //如果是第一行,左上、右上角为圆角
            case 0:
                bounds.origin.y += 1.0  //这样每一组首行顶部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.topRight],
                                              cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //如果是最后一行,左下、右下角为圆角
            case sectionCount - 1:
                bounds.size.height -= 1.0  //这样每一组尾行底部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.bottomLeft,.bottomRight],
                                              cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
            default: break
            }
        }
        //当前分区只有一行行数据时
        else {
            //四个角都为圆角（同样设置偏移隐藏首、尾分隔线）
            let bezierPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.0, dy: 2.0), cornerRadius: cornerRadius)
            shapeLayer.path = bezierPath.cgPath
            roundView.layer.mask = shapeLayer
        }
    }

}
