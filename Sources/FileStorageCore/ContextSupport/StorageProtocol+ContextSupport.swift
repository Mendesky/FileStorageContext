//
//  StorageProtocol+ContextStorage.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//
import Foundation

extension StorageProtocol where MetadataType: ContextMetadata {
    /// - Parameter documentIdStrategy: `documentId` 怎麼產生。預設 `.contentHash`＝既有行為，
    ///   既有呼叫端無需改動。需要「同一份檔案可並存多筆、重複與否由自己的 domain 規則決定」的
    ///   context 改傳 `.unique`（取捨見 `DocumentIdStrategy`）。
    public func upload(data: Data, contextInfo: ContextStorageInfo, contentType: String, metadata: MetadataType, limit: FileSizeLimit, documentIdStrategy: DocumentIdStrategy = .contentHash) async throws -> ContextUploadedResult? {
        let documentId = try documentIdStrategy.documentId(for: data, contextInfo: contextInfo, metadata: metadata)

        let folderPath = contextInfo.folderPath(metadata: metadata)
        let path = "\(folderPath)/\(documentId)"
        guard let result = try await upload(data: data, path: path, contentType: contentType, metadata: metadata, limit: limit) else {
            throw StorageError.uploadUnknownedFailed(message: "Upload to path \(path) failed")
        }
        return .init(documentId: documentId, uploadedResult: result)
    }
    
    public func download(documentId: String, contextInfo: ContextStorageInfo, metadata: MetadataType) async throws -> DownloadResult? {
        let folderPath = contextInfo.folderPath(metadata: metadata)
        let path = "\(folderPath)/\(documentId)"
        return try await download(path: path)
    }
    
    /// 與 `download(documentId:contextInfo:metadata:)` **必須組出同一條 path** ——
    /// 兩者若漂移，就會變成「查 A 的大小、下載 B 的內容」。`ContextSupportSizeTests` 鎖住這件事。
    public func sizeInBytes(documentId: String, contextInfo: ContextStorageInfo, metadata: MetadataType) async throws -> Int64? {
        let folderPath = contextInfo.folderPath(metadata: metadata)
        let path = "\(folderPath)/\(documentId)"
        return try await sizeInBytes(path: path)
    }

    public func markDelete(documentId: String, contextInfo: ContextStorageInfo, metadata: MetadataType) async throws {
        let folderPath = contextInfo.folderPath(metadata: metadata)
        let path = "\(folderPath)/\(documentId)"
        return try await markDelete(path: path)
    }
    
    
    
}

