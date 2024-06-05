//
//  GXBaseTextField.swift
//  GXLearningManagement
//
//  Created by Gin on 2021/6/14.
//

import UIKit

class GXBaseTextField: UITextField {

    public var margin: CGFloat = 0
    
    override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return super.borderRect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect.origin.x += self.margin
        rect.size.width -= self.margin * 2
        
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.placeholderRect(forBounds: bounds);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect.origin.x += self.margin
        rect.size.width -= self.margin * 2

        return rect
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x -= self.margin
        
        return rect
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += self.margin
        
        return rect
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= self.margin
        
        return rect
    }

}
