//
//  DownloadResult.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//
import Foundation

public struct DownloadResult {
    public let contentType: String
    public let data: Data
    
    package init(contentType: String, data: Data) {
        self.contentType = contentType
        self.data = data
    }
}
