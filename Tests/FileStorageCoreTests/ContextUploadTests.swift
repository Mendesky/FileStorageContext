//
//  ContextUploadTests.swift
//  FileStorageContext
//

import Foundation
import Testing
@testable import FileStorageCore

/// 記錄 upload 收到的 path，其餘操作為 no-op。不碰網路。
private actor PathRecordingStorage: StorageProtocol {
    typealias MetadataType = StandardContextMetadata

    private(set) var uploadedPaths: [String] = []

    func upload(data: Data, path: String, contentType: String, metadata: [String: String]?, limit: FileSizeLimit) async throws -> UploadedResult? {
        uploadedPaths.append(path)
        return .init(path: path, mediaLink: "recorded://\(path)")
    }

    func setMetadata(_ metadata: [String: String], path: String) async throws {}
    func getMetadata(path: String) async throws -> [String: String]? { nil }
    func download(path: String) async throws -> DownloadResult? { nil }
    func download(mediaLink: String) async throws -> DownloadResult? { nil }
    func markDelete(path: String) async throws {}
    func isMarkedDeleted(path: String) async throws -> Bool { false }
}

@Suite("Context upload documentId strategy")
struct ContextUploadTests {

    private let data = Data([UInt8](repeating: 0, count: 1024))
    private let contextInfo = ContextStorageInfo(context: "OpportunityContext", category: "clientDocument")
    private let metadata = StandardContextMetadata(
        originalName: "日記帳.pdf",
        context: "OpportunityContext",
        aggregateRoot: "QuotingCaseGrouping",
        aggregateRootId: "grouping-1"
    )

    /// **相容性鎖**：`documentIdStrategy` 是後加的預設參數，預設路徑**必須**與加它之前逐位元組相同。
    /// 這個值同時是 `DataCryptoTests.knownVector` 鎖住的那個 —— 若哪天有人「順手」把預設換成
    /// `.unique`、或改動雜湊輸入，所有既有 context 的重複判定會靜默失效，而這支測試會先紅。
    @Test("default strategy keeps the historical documentId byte-for-byte")
    func defaultStrategyIsUnchanged() async throws {
        let storage = PathRecordingStorage()
        let result = try #require(try await storage.upload(
            data: data, contextInfo: contextInfo, contentType: "application/pdf",
            metadata: metadata, limit: .mb(50)
        ))

        #expect(result.documentId == "9978b4d0ba5ec3257d0cf9ed0267a4cb6e542bafda1f15942ce5cfd41ca34e97")
    }

    /// 同樣的輸入、`.contentHash` → 同一個 documentId、同一條 path（冪等：重試會覆蓋而非新增）。
    @Test("contentHash strategy is idempotent for identical input")
    func contentHashIsIdempotent() async throws {
        let storage = PathRecordingStorage()
        let first = try #require(try await storage.upload(data: data, contextInfo: contextInfo, contentType: "application/pdf", metadata: metadata, limit: .mb(50), documentIdStrategy: .contentHash))
        let second = try #require(try await storage.upload(data: data, contextInfo: contextInfo, contentType: "application/pdf", metadata: metadata, limit: .mb(50), documentIdStrategy: .contentHash))

        #expect(first.documentId == second.documentId)
        let paths = await storage.uploadedPaths
        #expect(paths[0] == paths[1])
    }

    /// `.unique` → 同樣的輸入也得到不同的 documentId（重複與否交由呼叫端的 domain 規則判斷）。
    @Test("unique strategy yields a distinct documentId per upload")
    func uniqueIsDistinctPerUpload() async throws {
        let storage = PathRecordingStorage()
        let first = try #require(try await storage.upload(data: data, contextInfo: contextInfo, contentType: "application/pdf", metadata: metadata, limit: .mb(50), documentIdStrategy: .unique))
        let second = try #require(try await storage.upload(data: data, contextInfo: contextInfo, contentType: "application/pdf", metadata: metadata, limit: .mb(50), documentIdStrategy: .unique))

        #expect(first.documentId != second.documentId)
        let paths = await storage.uploadedPaths
        #expect(paths[0] != paths[1])
    }

    /// **路徑格式鎖**：folderPath 是 `{context}/{aggregateRoot}-{aggregateRootId}/{category}/{documentId}`。
    /// download / markDelete 都靠同一個組法重建路徑，任一 component 改動都會讓既有檔案取不到，
    /// 故格式本身就是契約。兩種策略只影響最後一段。
    @Test("path shape is the contract, regardless of strategy", arguments: [DocumentIdStrategy.contentHash, .unique])
    func pathShapeIsLocked(strategy: DocumentIdStrategy) async throws {
        let storage = PathRecordingStorage()
        let result = try #require(try await storage.upload(data: data, contextInfo: contextInfo, contentType: "application/pdf", metadata: metadata, limit: .mb(50), documentIdStrategy: strategy))

        let paths = await storage.uploadedPaths
        #expect(paths.first == "OpportunityContext/QuotingCaseGrouping-grouping-1/clientDocument/\(result.documentId)")
    }
}
