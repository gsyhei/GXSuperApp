//
//  GXHomePanView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/7.
//

import UIKit
import XCGLogger
import GXRefresh

class GXHomePanView: UIView {
    enum PanPosition {
        case none   //底部
        case top    //头部
        case center //中心
        case bottom //底部
    }
    private var currentTop: CGFloat = .zero
    private(set) var panTopY: CGFloat = .zero
    private(set) var panCenterY: CGFloat = .zero
    private(set) var panBottomY: CGFloat = .zero
    private(set) var currentPanPosition: PanPosition = .bottom
    private(set) var lastPanPosition: PanPosition = .bottom
    private var isMoveDirUp: Bool = false
    private var panGesture: UIPanGestureRecognizer?
    weak var viewModel: GXHomeViewModel?
    var changePositionAction: GXActionBlockItem<PanPosition>?
    var didSelectRowAtAction: GXActionBlockItem<GXStationConsumerRowsModel>?
    var navigationAction: GXActionBlockItem<GXStationConsumerRowsModel?>?

    lazy var arrowButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .gx_background
            $0.setImage(UIImage(named: "home_list_ic_unfold"), for: .normal)
            $0.setImage(UIImage(named: "home_list_ic_fold"), for: .selected)
        }
    }()
    
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .grouped).then {
            $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            $0.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: .leastNormalMagnitude))
            $0.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            $0.backgroundColor = .gx_background
            $0.sectionHeaderHeight = 12
            $0.sectionFooterHeight = .leastNormalMagnitude
            $0.separatorStyle = .none
            $0.rowHeight = 121.0
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: GXHomeMarkerCell.self)
        }
    }()

    required init(frame: CGRect, viewModel: GXHomeViewModel) {
        super.init(frame: frame)
        
        self.addSubview(self.arrowButton)
        self.addSubview(self.tableView)
        
        self.arrowButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.right.equalToSuperview()
            make.height.equalTo(22)
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.arrowButton.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        self.panGesture = panGesture
        self.addGestureRecognizer(panGesture)
        self.isUserInteractionEnabled = false
        self.viewModel = viewModel
        
        /// 只为显示noMore
        self.tableView.gx_footer = GXRefreshNormalFooter(completion: {}).then { footer in
            footer.updateRefreshTitles()
            footer.contentIgnoredHeight = 40.0
            footer.isHiddenNoMoreByContent = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.arrowButton.setRoundedCorners([.topLeft, .topRight], radius: 12)
    }
    
    func setupPanMovedY(top: CGFloat, center: CGFloat, bottom: CGFloat, position: PanPosition = .center) {
        self.isUserInteractionEnabled = true
        self.panTopY = top
        self.panCenterY = center
        self.panBottomY = bottom
        self.setCurrentPanPosition(position: position, velocity: 0, animated: false)
        
        let offsetY = (self.frame.height - center - 140) / 2
        self.tableView.gx_setPlaceholder(isTop: true, offset: offsetY)
    }
    
    func setCurrentPanPosition(position: PanPosition, velocity: CGFloat = 600, animated: Bool = true) {
        self.lastPanPosition = self.currentPanPosition
        self.currentPanPosition = position
        var top = self.frame.origin.y
        switch position {
        case .none:
            top = SCREEN_HEIGHT
        case .top:
            top = self.panTopY
        case .center:
            top = self.panCenterY
        case .bottom:
            top = self.panBottomY
        }
        let isPanTop = position == .top
        if animated {
            let velocityY = max(velocity, 100)
            var duration = abs(top - self.frame.origin.y) / velocityY
            duration = min(0.5, duration)
            duration = max(0.2, duration)
            UIView.animate(.promise, duration: duration, options: .curveEaseOut) {
                self.top = top
            }.done { finished in
                self.arrowButton.isSelected = isPanTop
                self.tableView.isScrollEnabled = isPanTop
                self.panGesture?.isEnabled = true
            }
            self.changePositionAction?(position)
        }
        else {
            self.top = top
            self.arrowButton.isSelected = isPanTop
            self.tableView.isScrollEnabled = isPanTop
            self.panGesture?.isEnabled = true
            self.changePositionAction?(position)
        }
    }
    
    func tableViewReloadData() {
        self.tableView.gx_footer?.endRefreshing(isNoMore: true)
        self.tableView.gx_reloadData()
    }
}

extension GXHomePanView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.stationConsumerList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXHomeMarkerCell = tableView.dequeueReusableCell(for: indexPath)
        let model = self.viewModel?.stationConsumerList[indexPath.section]
        cell.bindCell(model: model)
        cell.navigationAction = {[weak self] model in
            guard let `self` = self else { return }
            self.navigationAction?(model)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let drag = (scrollView.contentOffset.y <= 0)
        self.panGesture?.isEnabled = drag
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.panGestureRecognizer.view).y
        self.tableView.showsVerticalScrollIndicator = (scrollView.contentOffset.y > 0) || (velocity < 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        XCGLogger.info("indexPath = \(indexPath)")
        if let model = self.viewModel?.stationConsumerList[indexPath.section] {
            self.didSelectRowAtAction?(model)
        }
    }
}

extension GXHomePanView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (self.currentPanPosition == .top)
    }
}

private extension GXHomePanView {
    
    @objc func panGestureAction(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.currentTop = self.frame.origin.y
        case .changed:
            let movePoint = pan.translation(in: pan.view)
            self.updateSafeCurrentPoint(movePoint)
            self.frame.origin.y = self.currentTop
            pan.setTranslation(.zero, in: pan.view)
        case .ended:
            let velocity = abs(pan.velocity(in: pan.view).y)
            self.panEndAnimation(velocity: velocity)
        case .cancelled: break
        case .failed: break
        default: break
        }
    }
    
    func updateSafeCurrentPoint(_ movePoint: CGPoint) {
        self.isMoveDirUp = !(movePoint.y > 0)
        var moveTop = self.currentTop + movePoint.y
        moveTop = max(moveTop, self.panTopY)
        moveTop = min(moveTop, self.panBottomY)
        self.currentTop = moveTop
        if self.currentTop > self.panTopY {
            self.tableView.isScrollEnabled = false
        }
    }
    
    func panEndAnimation(velocity: CGFloat) {
        if self.currentTop > self.panCenterY {
            let position: PanPosition = self.isMoveDirUp ? .center : .bottom
            self.setCurrentPanPosition(position: position, velocity: velocity, animated: true)
        }
        else {
            let position: PanPosition = self.isMoveDirUp ? .top : .center
            self.setCurrentPanPosition(position: position, velocity: velocity, animated: true)
        }
    }
    
}
