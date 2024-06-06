//
//  String+Add.swift
//  QROrderSystem
//
//  Created by Gin on 2021/10/23.
//

import UIKit

extension String {

    static func gx_money(number: Int) -> String {
        return "￥" + self.gx_showInSeperator(number: number)
    }
    
    static func gx_money(string: String) -> String {
        return "￥" + self.gx_showInSeperator(source: string)
    }

    static func gx_showInSeperator(source: String, gap: Int = 3, seperator: Character=",") -> String {
        var tempStr = source
        let seperatorCount = (tempStr.count - 1) / gap
        guard seperatorCount > 0 else { return tempStr }
        for i in 1...seperatorCount {
            let index = tempStr.count - gap * i - (i - 1)
            tempStr.insert(seperator, at: tempStr.index(tempStr.startIndex, offsetBy: index))
        }
        return tempStr
    }

    static func gx_showInSeperator(number: Int, gap: Int = 3, seperator: Character=",") -> String {
        let source = String(number)
        return self.gx_showInSeperator(source: source, gap: gap, seperator: seperator)
    }

    static func gx_randomAlphanumericString(length: Int) -> String  {
        enum Statics {
            static let scalars = [UnicodeScalar("a").value...UnicodeScalar("z").value,
                                  UnicodeScalar("A").value...UnicodeScalar("Z").value,
                                  UnicodeScalar("0").value...UnicodeScalar("9").value].joined()
            static let characters = scalars.map { Character(UnicodeScalar($0)!) }
        }
        let result = (0..<length).map { _ in Statics.characters.randomElement()! }
        return String(result)
    }

}
