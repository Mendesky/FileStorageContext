//
//  ContextStorageInfo.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//

public struct ContextStorageInfo: Codable {
    let context: String
    let category: String
    
    public init(context: String, category: String) {
        self.context = context
        self.category = category
    }
    
    func folderPath(metadata: ContextMetadata) -> String {
        return "\(context)/\(metadata.aggregateRoot)-\(metadata.aggregateRootId)/\(category)"
    }
}
