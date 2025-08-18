//
//  Metadata.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//

public protocol Metadata: Codable {
    var originalName: String { get }
    var represented: [String: String] { get }
    
    init?(from dictionary: [String:String])
}



