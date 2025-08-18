//
//  ContextMetadata.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//

public protocol ContextMetadata: Metadata {
    var context: String { get }
    var aggregateRoot: String { get }
    var aggregateRootId: String { get }
}


    
