//
//  UIFont+Add.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/5/31.
//

import UIKit

extension UIFont {

    enum PingFangSCType {
        /// 纤细体
        case thin
        /// 极细体
        case ultralight
        /// 细体
        case light
        /// 常规体
        case regular
        /// 中黑体
        case medium
        /// 中粗体
        case semibold
    }

    class func gx_font(size fontSize: CGFloat) -> UIFont {
        return UIFont.gx_PFSCfont(size: fontSize, type: .regular)
    }

    class func gx_boldFont(size fontSize: CGFloat) -> UIFont {
        return UIFont.gx_PFSCfont(size: fontSize, type: .medium)
    }

    class func gx_boldMaxFont(size fontSize: CGFloat) -> UIFont {
        return UIFont.gx_PFSCfont(size: fontSize, type: .semibold)
    }

    class func gx_dingTalkFont(size fontSize: CGFloat) -> UIFont {
        return UIFont(name: "DingTalk JinBuTi", size: fontSize) ?? .gx_boldMaxFont(size: fontSize).gx_setItalic()
    }

    class func gx_PFSCfont(size fontSize: CGFloat, type: PingFangSCType) -> UIFont {
        switch type {
        case .thin:
            return UIFont(name: "PingFangSC-Thin", size: fontSize) ?? .systemFont(ofSize: fontSize)
        case .ultralight:
            return UIFont(name: "PingFangSC-Ultralight", size: fontSize) ?? .systemFont(ofSize: fontSize)
        case .light:
            return UIFont(name: "PingFangSC-Light", size: fontSize) ?? .systemFont(ofSize: fontSize)
        case .regular:
            return UIFont(name: "PingFangSC-Regular", size: fontSize) ?? .systemFont(ofSize: fontSize)
        case .medium:
            return UIFont(name: "PingFangSC-Medium", size: fontSize) ?? .italicSystemFont(ofSize: fontSize)
        case .semibold:
            return UIFont(name: "PingFangSC-Semibold", size: fontSize) ?? .italicSystemFont(ofSize: fontSize)
        }
    }

    func gx_setItalic() -> UIFont {
        let matrix: CGAffineTransform = CGAffineTransformMake(1, 0, CGFloat(tanf(10 * Float.pi / 180)), 1, 0, 0);
        let fontDescriptor = self.fontDescriptor.withMatrix(matrix)

        return UIFont(descriptor: fontDescriptor, size: 0)
    }
}
