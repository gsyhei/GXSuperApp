//
//  UIButton+Add.swift
//  GXSuperApp
//
//  Created by Gin on 2024/7/16.
//

import Foundation
import RxSwift
import RxCocoa
 
extension Reactive where Base: UIButton {
    var rx_isSelected: Observable<Bool> {
        return self.base.rx.tap.map { self.base.isSelected }
    }
}
