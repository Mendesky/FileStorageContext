//
//  FileStorageCore.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//

import Foundation

public protocol StorageProtocol {
    associatedtype MetadataType: Metadata
    func upload(data: Data, path: String, contentType: String, metadata: [String: Codable]?, limit: FileSizeLimit) async throws -> String?
}

extension StorageProtocol {
    public func upload(data: Data, path: String, contentType: String, metadata: MetadataType, limit: FileSizeLimit) async throws -> String? {
        
        return try await upload(data: data, path: path, contentType: contentType, metadata: metadata.represented, limit: limit)
    }
}
