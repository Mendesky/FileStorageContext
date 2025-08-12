//
//  ContentType.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//

package struct ContentType {
    package let rawValue: String
    package let fileExtension: String
    
    package static var jpeg: Self = .init(rawValue: "image/jpeg", fileExtension: "jpg")
    package static var pdf: Self = .init(rawValue: "application/pdf", fileExtension: "pdf")
    package static var png: Self = .init(rawValue: "image/png", fileExtension: "png")
}
