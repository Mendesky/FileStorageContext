//
//  Extensions.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//

import struct HTTPTypes.HTTPField

extension HTTPTypes.HTTPField.Name: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension HTTPTypes.HTTPField.Name: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension HTTPTypes.HTTPField.Name: @retroactive ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .init(value)!
    }
}
