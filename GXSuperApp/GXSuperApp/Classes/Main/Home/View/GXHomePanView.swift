//
//  GXHomePanView.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/7.
//

import UIKit
import XCGLogger

class GXHomePanView: UIView {
    enum PanPosition {
        case top    //头部
        case center //中心
        case bottom //底部
    }
    private var currentTop: CGFloat = .zero
    private var panTopY: CGFloat = .zero
    private var panCenterY: CGFloat = .zero
    private var panBottomY: CGFloat = .zero
    private(set) var currentPanPosition: PanPosition = .bottom
    private var isMoveDirUp: Bool = false
    var changePositionAction: GXActionBlockItem<PanPosition>?
    
    lazy var tableView: GXBaseTableView = {
        return GXBaseTableView(_frame: self.bounds, _style: .plain).then {
            $0.backgroundColor = .gx_background
            $0.separatorStyle = .none
            $0.rowHeight = 80.0
            $0.dataSource = self
            $0.delegate = self
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPanMovedY(top: CGFloat, center: CGFloat, bottom: CGFloat, position: PanPosition = .bottom) {
        self.panTopY = top
        self.panCenterY = center
        self.panBottomY = bottom
        self.setCurrentPanPosition(position: position, velocity: 0, animated: false)
        self.isUserInteractionEnabled = true
    }
    
}

extension GXHomePanView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.contentView.backgroundColor = .gx_background
        }
        cell?.textLabel?.text = "Cell text"
        
        return cell!
    }
    
}

extension GXHomePanView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.tableView.isScrollEnabled && self.tableView.contentOffset.y > 0 {
            return false
        }
        if (self.tableView.isScrollEnabled) {
            self.tableView.showsVerticalScrollIndicator = false
            return true
        }
        return false
    }
}

private extension GXHomePanView {
    
    func setCurrentPanPosition(position: PanPosition, velocity: CGFloat, animated: Bool = true) {
        self.currentPanPosition = position
        var top = self.frame.origin.y
        switch position {
        case .top:
            top = self.panTopY
        case .center:
            top = self.panCenterY
        case .bottom:
            top = self.panBottomY
        }
        if animated {
            var duration = abs(top - self.frame.origin.y) / velocity
            duration = min(0.2, duration)
            duration = max(0.1, duration)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                self.top = top
            } completion: { finished in
                self.tableView.isScrollEnabled = position == .top
                self.tableView.showsVerticalScrollIndicator = position == .top
                self.changePositionAction?(position)
            }
        }
        else {
            self.top = top
            self.tableView.isScrollEnabled = position == .top
            self.tableView.showsVerticalScrollIndicator = position == .top
            self.changePositionAction?(position)
        }
    }
    
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
