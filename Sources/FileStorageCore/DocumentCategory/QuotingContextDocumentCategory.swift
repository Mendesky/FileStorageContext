//
//  QuotingContextDocumentCategory.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//


package enum QuotingContextDocumentCategory {
    /// 報價依據
    case quotingProof
    /// 同意函
    case replyForm
    
    var rawValue: String {
        switch self {
        case .quotingProof:
            "quoting_proof"
        case .replyForm:
            "reply_form"
        }
    }
}

extension QuotingContextDocumentCategory {
    package func path(documentId: String, contentType: ContentType)-> String {
        return "quoting-context/\(self.rawValue)/\(documentId).\(contentType.fileExtension)"
    }
}
