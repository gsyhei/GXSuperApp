//
//  GXCollectionViewAlignmentLeftLayout.swift
//  GXSuperApp
//
//  Created by Gin on 2024/6/20.
//

import UIKit

extension UICollectionViewLayoutAttributes {

    /** 每行第一个item左对齐 **/
    func leftAlignFrame(sectionInset:UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }
}

class GXCollectionViewAlignmentLeftLayout: UICollectionViewFlowLayout {

    //MARK: - 重新UICollectionViewFlowLayout的方法

    /** Collection所有的UICollectionViewLayoutAttributes */
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesToReturn = super.layoutAttributesForElements(in: rect) else { return nil }
        for attributes in attributesToReturn {
            guard attributes.representedElementKind == nil else { continue }
            if let itemAttribute = self.layoutAttributesForItem(at: attributes.indexPath) {
                attributes.frame = itemAttribute.frame
            }
        }
        return attributesToReturn
    }

    /** 每个item的UICollectionViewLayoutAttributes */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //现在item的UICollectionViewLayoutAttributes
        guard let currentItemAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        //现在section的sectionInset
        let sectionInset = self.evaluatedSectionInset(itemAtIndex: indexPath.section)
        //是否是section的第一个item
        let isFirstItemInSection = indexPath.item == 0
        //出去section偏移量的宽度
        let layoutWidth: CGFloat = CGRectGetWidth(self.collectionView!.frame) - sectionInset.left - sectionInset.right
        //是section的第一个item
        if isFirstItemInSection {
            //每行第一个item左对齐
            currentItemAttributes.leftAlignFrame(sectionInset: sectionInset)
            return currentItemAttributes
        }
    
        //前一个item的NSIndexPath
        let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        //前一个item的frame
        let previousFrame = self.layoutAttributesForItem(at: previousIndexPath)?.frame ?? .zero
        //为现在item计算新的left
        let previousFrameRightPoint: CGFloat = previousFrame.origin.x + previousFrame.size.width
        //现在item的frame
        let currentFrame = currentItemAttributes.frame
        //现在item所在一行的frame
        let strecthedCurrentFrame = CGRectMake(sectionInset.left, currentFrame.origin.y, layoutWidth, currentFrame.size.height)
    
        //previousFrame和strecthedCurrentFrame是否有交集，没有，说明这个item和前一个item在同一行，item是这行的第一个item
        let isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)
        //item是这行的第一个item
        if isFirstItemInRow {
            //每行第一个item左对齐
            currentItemAttributes.leftAlignFrame(sectionInset: sectionInset)
            return currentItemAttributes
        }
        //不是每行的第一个item
        var frame = currentItemAttributes.frame
        //为item计算新的left = previousFrameRightPoint + item之间的间距
        frame.origin.x = previousFrameRightPoint + self.evaluatedMinimumInteritemSpacing(itemAtIndex: indexPath.item)
        //为item的frame赋新值
        currentItemAttributes.frame = frame
        return currentItemAttributes
    }

    //MARK: - System

    /** item行间距 **/
    private func evaluatedMinimumInteritemSpacing(itemAtIndex: Int) -> CGFloat {
        guard let collectionView = self.collectionView else { return self.minimumInteritemSpacing }
        guard let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout else { return self.minimumInteritemSpacing }
        guard delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))) else { return self.minimumInteritemSpacing }
        guard let interitemSpacing = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: itemAtIndex) else { return self.minimumInteritemSpacing }
        
        return interitemSpacing
    }

    /** section的偏移量 **/
    private func evaluatedSectionInset(itemAtIndex: Int) -> UIEdgeInsets {
        guard let collectionView = self.collectionView else { return self.sectionInset }
        guard let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout else { return self.sectionInset }
        guard delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))) else { return self.sectionInset }
        guard let sectionInset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: itemAtIndex) else { return self.sectionInset }

        return sectionInset
    }
    
}
