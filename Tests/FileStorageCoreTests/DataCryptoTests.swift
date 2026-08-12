//
//  DataCryptoTests.swift
//  FileStorageContext
//

import Foundation
import Testing
@testable import FileStorageCore

/// `sha256(extra:)` 的輸出即 `documentId`（見 `StorageProtocol+ContextSupport.upload`），
/// 而 `documentId` 同時是 GCS 的路徑末段與各 context 判斷「同一份檔案」的依據。
/// 它必須是純粹的內容函式：同樣的輸入，在任何執行緒、任何負載下都得到同一個值。
@Suite("Data.sha256(extra:) determinism")
struct DataCryptoTests {

    private let data = Data([UInt8](repeating: 0, count: 1024))
    private let contextInfo = ContextStorageInfo(context: "OpportunityContext", category: "clientDocument")
    private let metadata = StandardContextMetadata(
        originalName: "日記帳.pdf",
        context: "OpportunityContext",
        aggregateRoot: "QuotingCaseGrouping",
        aggregateRootId: "grouping-1"
    )

    /// **回歸測試**：本函式曾用未設 `.sortedKeys` 的 `JSONEncoder`，JSON object 的 key 順序取自 Swift
    /// `Dictionary` 的迭代順序（hash seed 由 storage buffer 位址推導）→ 只要 process 內有其他執行緒同時
    /// 在配置記憶體就會變。修復前這個測試會得到 6–9 種不同雜湊；單執行緒跑則看不出問題，故**必須併發**。
    @Test("same input yields one hash under concurrency")
    func concurrentHashIsStable() async throws {
        let hashes = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<200 {
                group.addTask { try self.data.sha256(extra: self.contextInfo, self.metadata) }
            }
            var collected = Set<String>()
            for try await hash in group { collected.insert(hash) }
            return collected
        }

        #expect(hashes.count == 1, "同樣的輸入必須只產生一個雜湊，實得 \(hashes.count) 種：\(hashes.sorted())")
    }

    /// **契約鎖**：`documentId` 一旦寫進各 context 的 event 就是永久識別碼，演算法變動會讓同一份檔案
    /// 在新舊版本算出不同 id、彼此比不出重複。這支測試紅掉時要改的是程式碼，不是這裡的期望值。
    @Test("hash of a known input is stable across releases")
    func knownVector() throws {
        #expect(try data.sha256(extra: contextInfo, metadata) == "9978b4d0ba5ec3257d0cf9ed0267a4cb6e542bafda1f15942ce5cfd41ca34e97")
    }

    /// 只雜湊 data 本身（不帶 extra）的路徑不受 JSON 編碼影響，用已知向量確認它一直是乾淨的。
    @Test("hash without extra elements is the plain sha256 of the bytes")
    func plainHash() {
        #expect(data.sha256() == "5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef")
    }
}
