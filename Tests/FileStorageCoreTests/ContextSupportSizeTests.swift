//
//  ContextSupportSizeTests.swift
//  FileStorageContext
//

import Foundation
import Testing
@testable import FileStorageCore


/// 記錄每個操作收到的 path，其餘為 no-op。不碰網路。
///
/// **刻意不實作 `sizeInBytes(path:)`** —— 用來驗證新 requirement 的 default implementation 生效，
/// 也就是「既有 conformer 一行都不用改」這件事。
private actor PathRecordingStorage: StorageProtocol {
    typealias MetadataType = StandardContextMetadata

    private(set) var downloadedPaths: [String] = []

    func download(path: String) async throws -> DownloadResult? {
        downloadedPaths.append(path)
        return nil
    }

    func upload(data: Data, path: String, contentType: String, metadata: [String: String]?, limit: FileSizeLimit) async throws -> UploadedResult? {
        .init(path: path, mediaLink: "recorded://\(path)")
    }

    func setMetadata(_ metadata: [String: String], path: String) async throws {}
    func getMetadata(path: String) async throws -> [String: String]? { nil }
    func download(mediaLink: String) async throws -> DownloadResult? { nil }
    func markDelete(path: String) async throws {}
    func isMarkedDeleted(path: String) async throws -> Bool { false }
}


/// 回固定大小並記下 path 的實作 —— 用來鎖 path 組法。
private actor SizeRecordingStorage: StorageProtocol {
    typealias MetadataType = StandardContextMetadata

    private(set) var queriedPaths: [String] = []
    private let size: Int64?

    init(size: Int64?) { self.size = size }

    func sizeInBytes(path: String) async throws -> Int64? {
        queriedPaths.append(path)
        return size
    }

    func upload(data: Data, path: String, contentType: String, metadata: [String: String]?, limit: FileSizeLimit) async throws -> UploadedResult? { nil }
    func setMetadata(_ metadata: [String: String], path: String) async throws {}
    func getMetadata(path: String) async throws -> [String: String]? { nil }
    func download(path: String) async throws -> DownloadResult? { nil }
    func download(mediaLink: String) async throws -> DownloadResult? { nil }
    func markDelete(path: String) async throws {}
    func isMarkedDeleted(path: String) async throws -> Bool { false }
}


@Suite("Context sizeInBytes")
struct ContextSupportSizeTests {

    private let contextInfo = ContextStorageInfo(context: "OpportunityContext", category: "ClientDocument")
    private let metadata = StandardContextMetadata(
        originalName: "日記帳.pdf",
        context: "OpportunityContext",
        aggregateRoot: "QuotingCaseGrouping",
        aggregateRootId: "grouping-1"
    )

    /// **相容性鎖**：`sizeInBytes` 是後加的 protocol requirement。沒實作它的既有 conformer
    /// 必須照樣編譯、照樣可用（拿到 nil）。這支測試紅了代表 default implementation 被拿掉，
    /// 各專案的測試 mock 會全部編譯失敗。
    @Test("conformer without an implementation falls back to nil")
    func defaultImplementationReturnsNil() async throws {
        let storage = PathRecordingStorage()
        #expect(try await storage.sizeInBytes(path: "any/path") == nil)
        #expect(try await storage.sizeInBytes(documentId: "doc-1", contextInfo: contextInfo, metadata: metadata) == nil)
    }

    /// **path parity 鎖**：`sizeInBytes(documentId:)` 與 `download(documentId:)` 必須組出同一條 path。
    /// 兩者漂移的話會變成「查 A 的大小、下載 B 的內容」，而那種錯誤在正式環境只會表現成
    /// 「Content-Length 與實際 body 不符」，極難回推原因。
    @Test("documentId overload composes the same path as download")
    func pathMatchesDownload() async throws {
        let sizeStorage = SizeRecordingStorage(size: 12345)
        let downloadStorage = PathRecordingStorage()

        _ = try await sizeStorage.sizeInBytes(documentId: "doc-1", contextInfo: contextInfo, metadata: metadata)
        _ = try await downloadStorage.download(documentId: "doc-1", contextInfo: contextInfo, metadata: metadata)

        let queried = await sizeStorage.queriedPaths
        let downloaded = await downloadStorage.downloadedPaths
        #expect(queried == downloaded)
        #expect(queried == ["OpportunityContext/QuotingCaseGrouping-grouping-1/ClientDocument/doc-1"])
    }

    @Test("documentId overload returns the underlying size")
    func returnsUnderlyingSize() async throws {
        let storage = SizeRecordingStorage(size: 987_654_321)
        let size = try await storage.sizeInBytes(documentId: "doc-1", contextInfo: contextInfo, metadata: metadata)
        #expect(size == 987_654_321)
    }
}
