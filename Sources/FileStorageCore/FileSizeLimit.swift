//
//  FileSizeLimit 2.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//

public enum FileSizeLimit{
    case bytes(Int)
    case kb(Int)
    case mb(Int)
    case gb(Int)
    
    
    var bytes: Int {
        switch self {
        case .bytes(let value):
            return value
        case .kb(let value):
            return value * 1024
        case .mb(let value):
            return value * 1024 * 1024
        case .gb(let value):
            return value * 1024 * 1024 * 1024
        }
    }
}
