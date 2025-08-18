//
//  StandardContextMetadata.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//


public struct StandardContextMetadata: ContextMetadata {
    public let originalName: String
    public let context: String
    public let aggregateRoot: String
    public let aggregateRootId: String
    
    public init(originalName: String, context: String, aggregateRoot: String, aggregateRootId: String, markDeleted: Bool = false) {
        self.originalName = originalName
        self.context = context
        self.aggregateRoot = aggregateRoot
        self.aggregateRootId = aggregateRootId
    }
}

extension StandardContextMetadata {
    
    public init?(from dictionary: [String:Codable]){
        guard let context = dictionary["context"] as? String else {
            return nil
        }
        guard let aggregateRoot = dictionary["aggregateRoot"] as? String else {
            return nil
        }
        guard let aggregateRootId = dictionary["aggregateRootId"] as? String else {
            return nil
        }
        guard let markDeleted = dictionary["markDeleted"] as? Bool else {
            return nil
        }
        
        guard let originalName = dictionary["originalName"] as? String else {
            return nil
        }
        
        self.context = context
        self.aggregateRoot = aggregateRoot
        self.aggregateRootId = aggregateRootId
        self.originalName = originalName
    }
    
    public var represented: [String: Codable]{
        get{
            return [
                "context": context,
                "aggregateRoot": aggregateRoot,
                "aggregateRootId": aggregateRootId,
                "originalName": originalName
            ]
        }
    }
}
