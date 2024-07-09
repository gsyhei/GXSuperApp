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
    
    var placeholderImageName: String = "com_empty_ic_nodata" {
        didSet {
            self.placeholderImageView.image = UIImage(named: placeholderImageName)
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
            $0.textColor = .gx_drakGray
            $0.text = "Apologies, I didn't find anything"
        }
    }()
    
    private(set) lazy var placeholderImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "com_empty_ic_nodata"))
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
        self.configuration(estimated: true, separatorLeft: false)
        self.separatorColor = .gx_lineGray
        
        self.placeholderView.addSubview(self.placeholderImageView)
        self.placeholderImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.placeholderView.snp.centerY).offset(-100)
        }
        
        self.placeholderView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.placeholderImageView.snp.bottom).offset(20)
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
    
    public func gx_setPlaceholder(isTop: Bool = false, offset: CGFloat = -100) {
        self.placeholderImageView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            if isTop {
                make.top.equalToSuperview().offset(offset)
            }
            else {
                make.top.equalTo(self.placeholderView.snp.centerY).offset(offset)
            }
        }
    }
}

extension GXBaseTableView {
    
    /// 设置tableFooterView并赋予高度
    /// - Parameter height: 高度
    public func setTableFooterView(height: CGFloat) {
        let width = self.frame.width > 0 ? self.frame.width:SCREEN_WIDTH
        self.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    /// 设置Section圆角[需在willDisplay处调用]
    public class func setTableView(_ tableView: UITableView, cell: UITableViewCell?, margin: CGFloat = 12, radius: CGFloat = 8, at indexPath: IndexPath) {
        guard let roundView = cell else { return }
        //下面为设置圆角操作（通过遮罩实现）
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        let shapeLayer = CAShapeLayer()
        roundView.layer.mask = nil
        var bounds = roundView.bounds.inset(by: UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin))
        //当前分区有多行数据时
        if sectionCount > 1 {
            switch indexPath.row {
                //如果是第一行,左上、右上角为圆角
            case 0:
                bounds.origin.y += 1.0  //这样每一组首行顶部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.topLeft,.topRight],
                                              cornerRadii: CGSize(width: radius, height: radius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //如果是最后一行,左下、右下角为圆角
            case sectionCount - 1:
                bounds.size.height -= 1.0  //这样每一组尾行底部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.bottomLeft,.bottomRight],
                                              cornerRadii: CGSize(width: radius, height: radius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //中间部分切掉margin
            default:
                let bezierPath = UIBezierPath(rect: bounds)
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
            }
        }
        //当前分区只有一行行数据时
        else {
            //四个角都为圆角（同样设置偏移隐藏首、尾分隔线）
            let bezierPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.0, dy: 2.0), cornerRadius: radius)
            shapeLayer.path = bezierPath.cgPath
            roundView.layer.mask = shapeLayer
        }
    }
    
    /// 设置Section圆角[需在willDisplay处调用]<特殊可能关注的人第一个只有右边单圆角>
    public class func setFollowTableView(_ tableView: UITableView, cell: UITableViewCell?, margin: CGFloat = 12, radius: CGFloat = 8, at indexPath: IndexPath) {
        guard let roundView = cell else { return }
        //下面为设置圆角操作（通过遮罩实现）
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        let shapeLayer = CAShapeLayer()
        roundView.layer.mask = nil
        var bounds = roundView.bounds.inset(by: UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin))
        //当前分区有多行数据时
        if sectionCount > 1 {
            switch indexPath.row {
                //如果是第一行,左上、右上角为圆角
            case 0:
                bounds.origin.y += 1.0  //这样每一组首行顶部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.topRight],
                                              cornerRadii: CGSize(width: radius, height: radius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //如果是最后一行,左下、右下角为圆角
            case sectionCount - 1:
                bounds.size.height -= 1.0  //这样每一组尾行底部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,
                                              byRoundingCorners: [.bottomLeft,.bottomRight],
                                              cornerRadii: CGSize(width: radius, height: radius))
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
                //中间部分切掉margin
            default:
                let bezierPath = UIBezierPath(rect: bounds)
                shapeLayer.path = bezierPath.cgPath
                roundView.layer.mask = shapeLayer
            }
        }
        //当前分区只有一行行数据时
        else {
            //四个角都为圆角（同样设置偏移隐藏首、尾分隔线）
            let bezierPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.0, dy: 2.0), cornerRadius: radius)
            shapeLayer.path = bezierPath.cgPath
            roundView.layer.mask = shapeLayer
        }
    }
    
}
