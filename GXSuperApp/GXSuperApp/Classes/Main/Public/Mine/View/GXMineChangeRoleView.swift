//
//  GXMineChangeRoleView.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/11.
//

import UIKit

class GXMineChangeRoleView: UIView {

    class func createView() -> GXMineChangeRoleView {
        let view = GXMineChangeRoleView.xibView()
        view.frame = CGRect(x: 0, y: 0, width: 260, height: 42)

        return view
    }

}
