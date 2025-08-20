//
//  StorageProtocol+ContextStorage.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//
import Foundation

extension StorageProtocol where MetadataType: ContextMetadata {
    public func upload(data: Data, contextInfo: ContextStorageInfo, contentType: String, metadata: MetadataType, limit: FileSizeLimit) async throws -> ContextUploadedResult? {
        let documentId = try data.sha256(extra: contextInfo, metadata)
        
        let folderPath = contextInfo.folderPath(metadata: metadata)
        let path = "\(folderPath)/\(documentId)"
        guard let result = try await upload(data: data, path: path, contentType: contentType, metadata: metadata, limit: limit) else {
            throw StorageError.uploadUnknownedFailed(message: "Upload to path \(path) failed")
        }
        return .init(documentId: documentId, uploadedResult: result)
    }
    
    
    public func markDelete(contextInfo: ContextStorageInfo, metadata: MetadataType) async throws {
        return try await markDelete(path: contextInfo.folderPath(metadata: metadata))
    }
    
    
    
}
