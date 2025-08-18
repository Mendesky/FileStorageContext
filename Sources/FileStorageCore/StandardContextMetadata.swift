//
//  StandardContextMetadata.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//
import Logging

fileprivate let logger = Logger(label: "[StandardContextMetadata]")

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
    
    public init?(from dictionary: [String:String]){
        guard let context = dictionary["context"] else {
            logger.debug("Failed to get context from \(dictionary)")
            return nil
        }
        guard let aggregateRoot = dictionary["aggregateRoot"]else {
            logger.debug("Failed to get aggregateRoot from \(dictionary)")
            return nil
        }
        guard let aggregateRootId = dictionary["aggregateRootId"] else {
            logger.debug("Failed to get aggregateRootId from \(dictionary)")
            return nil
        }
        
        guard let originalName = dictionary["originalName"] else {
            logger.debug("Failed to get originalName from \(dictionary)")
            return nil
        }
        
        self.context = context
        self.aggregateRoot = aggregateRoot
        self.aggregateRootId = aggregateRootId
        self.originalName = originalName
    }
    
    public var represented: [String: String]{
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
