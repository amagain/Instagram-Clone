//
//  CollectionLayout.swift
//  InstagramApp
//
//  Created by User on 8/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation
import UIKit

class CollectionLayout: UICollectionViewLayout {
    
    fileprivate var numberOfColumns = 3
    fileprivate var cellPadding: Int = 3
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right) - (cellPadding * (CGFloat(numberOfColumns) - 1))
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        let itemsPerRow: Int = 3
        let normalColumnWidth: CGFloat = contentWidth / CGFloat(itemsPerRow)
        let normalColumnHeight: CGFloat = normalColumnWidth
        
        let featuredColumnWidth: CGFloat = normalColumnWidth * 2 + cellPadding
        let featuredColumnHeight: CGFloat = featuredColumnWidth
        
        var offsets: [CGFloat] = [CGFloat]()
    }
    
}
