//
//  UploadedResult.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//

public struct UploadedResult {
    public let path: String
    public let mediaLink: String
    
    public init(path: String, mediaLink: String) {
        self.path = path
        self.mediaLink = mediaLink
    }
}
