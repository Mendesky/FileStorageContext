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
    
    public func sha256(extra elements: Codable...) throws -> String {
        let encoder = JSONEncoder()
        let elementDatas = try elements.map{
            try encoder.encode($0)
        }
        return sha256(extra: elementDatas)
    }
}
