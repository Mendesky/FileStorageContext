//
//  DocumentIdStrategy.swift
//  FileStorageContext
//

import Foundation

/// `documentId` 的產生策略。
///
/// **為什麼需要這個選擇**：`documentId` 決定 GCS 物件路徑，因此也決定了「什麼樣的兩次上傳會落在
/// 同一個物件上」。`.contentHash` 把「同內容同檔名 ＝ 同一份文件」這個判斷內建在 storage 層；
/// 但那不是所有 context 的業務規則 —— 例如同一份掃描檔要分別掛在集團內兩家公司底下、或掛在
/// 兩個不同的文件分類底下時，storage 層的判斷反而會擋住合法操作。
///
/// 這個 enum 讓**重複的定義權回到各 context**：需要 storage 層去重的維持 `.contentHash`，
/// 自己在 domain 層判重的改用 `.unique`。
public enum DocumentIdStrategy: Sendable {
    /// 由「檔案內容 ＋ contextInfo ＋ metadata」雜湊而得（library 的預設行為）。
    ///
    /// 特性：**冪等** —— 同樣的輸入永遠算出同一個 documentId、落在同一條 path，重試會覆蓋而非新增，
    /// 因此上傳成功但後續步驟失敗時，重試不會累積孤兒物件。代價是無法讓「同內容的兩份文件」並存。
    case contentHash

    /// 每次上傳產生一個全新的 UUID，與檔案內容無關。
    ///
    /// 特性：同一份檔案可以並存多筆，重複與否**完全由呼叫端的 domain 規則決定**。
    /// ⚠️ 代價是**失去冪等**：上傳成功但後續步驟失敗時，每次重試都會留下一個新的孤兒物件，
    /// 呼叫端需自備補償（失敗時 `markDelete`）或離線清理機制。
    case unique

    func documentId(for data: Data, contextInfo: ContextStorageInfo, metadata: some ContextMetadata) throws -> String {
        switch self {
        case .contentHash:
            return try data.sha256(extra: contextInfo, metadata)
        case .unique:
            return UUID().uuidString
        }
    }
}
