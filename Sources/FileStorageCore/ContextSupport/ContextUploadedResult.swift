//
//  ContextUploadedResult.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/19.
//

public struct ContextUploadedResult {
    public let documentId: String
    public let uploadedResult: UploadedResult
    
    package init(documentId: String, uploadedResult: UploadedResult) {
        self.documentId = documentId
        self.uploadedResult = uploadedResult
    }
}


