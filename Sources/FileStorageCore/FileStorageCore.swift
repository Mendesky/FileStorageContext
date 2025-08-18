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
    
    func setMetadata(_ metadata: [String: Codable], path: String) async throws
    func getMetadata(path: String) async throws -> [String: Codable]?
    func download(path: String) async throws -> Data?
    func markDelete(path: String) async throws
    func isMarkedDeleted(path: String) async throws -> Bool
}

extension StorageProtocol {
    public func upload(data: Data, path: String, contentType: String, metadata: MetadataType, limit: FileSizeLimit) async throws -> String? {
        
        return try await upload(data: data, path: path, contentType: contentType, metadata: metadata.represented, limit: limit)
    }
    
    public func setMetadata(_ metadata: MetadataType, path: String) async throws{
        try await setMetadata(metadata.represented, path: path)
    }
    
    public func getMetadata(path: String) async throws -> MetadataType?{
        let dictionary: [String: Codable]? = try await getMetadata(path: path)
        return dictionary.flatMap{
            .init(from: $0)
        }
    }
    
    public func markDelete(path: String) async throws {
        do {
            try await setMetadata(["markDeleted": true], path: path)
        } catch {
            throw StorageError.markDeletedFailed(error: error)
        }
    }
    
    public func isMarkedDeleted(path: String) async throws -> Bool{
        do {
            guard let metadata = try await getMetadata(path: path),
                  let markDeleted = metadata["markDeleted"] as? Bool else {
                return false
            }
            return markDeleted
        
        } catch {
            throw StorageError.markDeletedFailed(error: error)
        }
    }
    
    
    
}
