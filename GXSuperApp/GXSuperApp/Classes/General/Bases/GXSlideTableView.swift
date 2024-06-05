//
//  GXSlideTableView.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/5.
//

import UIKit
import GXSegmentPageView

class GXSlideTableView: GXBaseTableView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let otherPan: UIPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
           let otherSV: UIScrollView = otherPan.view as? UIScrollView
        {
            if otherSV.isKind(of: GXSegmentCollectionView.self) {
                return false
            }
            let top = self.contentSize.height - self.height - self.contentInset.top + self.contentInset.bottom
            // 已经滚到到底部
            if top < -self.contentInset.top {
                return false
            }
        }
        return true
    }
    
}
