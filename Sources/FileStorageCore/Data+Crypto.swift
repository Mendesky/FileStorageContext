//
//  Data+Crypto.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//

import Foundation
import Crypto

extension Data {
    public func sha256(extra extraDatas: [Data] = []) -> String {
        var datas = [self] + extraDatas
        let sha = datas.reduce(into: SHA256()) { partialResult, data in
            partialResult.update(data: data)
        }
        let digest = sha.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 以本身的 bytes 加上 `elements` 的 JSON 編碼計算 SHA-256。
    ///
    /// - Important: `.sortedKeys` 是**正確性要求**，不是格式偏好。少了它，JSON object 的 key 順序取自
    ///   Swift `Dictionary` 的迭代順序，而其 hash seed 由 storage buffer 的記憶體位址推導 —— process 內只要
    ///   有其他執行緒同時配置記憶體，順序就會變，同樣的輸入會算出不同的雜湊。實測相同輸入：單執行緒 200 次
    ///   得 1 種結果、200 次併發得 9 種。這會讓所有以本函式產生的 `documentId` 當內容指紋的去重判斷失效。
    public func sha256(extra elements: Codable...) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let elementDatas = try elements.map{
            try encoder.encode($0)
        }
        return sha256(extra: elementDatas)
    }
}
