//
//  FileStorageCore.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//

import Foundation

public protocol StorageProtocol {
    associatedtype MetadataType: Metadata
    func upload(data: Data, path: String, contentType: String, metadata: [String: String]?, limit: FileSizeLimit) async throws -> UploadedResult?
    
    func setMetadata(_ metadata: [String: String], path: String) async throws
    func getMetadata(path: String) async throws -> [String: String]?
    func download(path: String) async throws -> DownloadResult?
    func download(mediaLink: String) async throws -> DownloadResult?
    func markDelete(path: String) async throws
    func isMarkedDeleted(path: String) async throws -> Bool

    /// 物件大小（bytes），**不搬 bytes** —— 相當於 HTTP 的 HEAD 之於 GET。
    ///
    /// 用途是「下載之前就要知道多大」：批次打包時先算總量以擋掉超限的請求、算出 `Content-Length`。
    /// `download(path:)` 回的 `DownloadResult` 來得太晚 —— 它出現時 bytes 已經在記憶體裡了。
    ///
    /// **回 nil 的兩種情況刻意不區分**：物件不存在，或存在但底層拿不到大小。呼叫端拿 nil 一律走
    /// 「大小未知」的退路即可 —— 物件真的不存在的話，接下來的 `download` 會回 nil，那才是權威的判斷點。
    func sizeInBytes(path: String) async throws -> Int64?
}



extension StorageProtocol {
    /// 預設實作回 nil ＝「此實作不提供大小查詢」。
    ///
    /// **刻意給 default**：`sizeInBytes` 是後加的 requirement，沒有 default 的話所有既有 conformer
    /// （含各專案的測試 mock）都會編譯失敗，而它們絕大多數並不在意大小。需要的實作自己 override。
    public func sizeInBytes(path: String) async throws -> Int64? { nil }

    public func upload(data: Data, path: String, contentType: String, metadata: MetadataType, limit: FileSizeLimit) async throws -> UploadedResult? {
        return try await upload(data: data, path: path, contentType: contentType, metadata: metadata.represented, limit: limit)
    }
    
    public func setMetadata(_ metadata: MetadataType, path: String) async throws{
        try await setMetadata(metadata.represented, path: path)
    }
    
    public func getMetadata(path: String) async throws -> MetadataType?{
        let dictionary: [String: String]? = try await getMetadata(path: path)
        return dictionary.flatMap{
            .init(from: $0)
        }
    }
    
    public func markDelete(path: String) async throws {
        do {
            try await setMetadata(["markDeleted": String(true)], path: path)
        } catch {
            throw StorageError.markDeletedFailed(error: error)
        }
    }
    
    public func isMarkedDeleted(path: String) async throws -> Bool{
        do {
            guard let metadata = try await getMetadata(path: path),
                  let markDeletedValue = metadata["markDeleted"],
                  let markDeleted = Bool(markDeletedValue) else {
                return false
            }
            return markDeleted
        } catch {
            throw StorageError.markDeletedFailed(error: error)
        }
    }
    
}



