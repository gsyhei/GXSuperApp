//
//  Copyable+Add.swift
//  GXHeiVibe
//
//  Created by Gin on 2024/1/6.
//

import Foundation

protocol GXCopyable: Codable {
    func gx_copy() -> Self
}

extension GXCopyable {
    func gx_copy() -> Self {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("encode失败")
        }
        let decoder = JSONDecoder()
        guard let target = try? decoder.decode(Self.self, from: data) else {
            fatalError("decode失败")
        }
        return target
    }
}
