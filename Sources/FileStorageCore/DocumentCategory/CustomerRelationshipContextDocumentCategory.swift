//
//  CustomerRelationshipContextDocumentCategory.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//


package enum CustomerRelationshipContextDocumentCategory {
    /// 新客風控表
    case businessClientRiskControlDocument

    var rawValue: String {
        switch self {
        case .businessClientRiskControlDocument:
            "business_client_risk_control_document"
        }
    }
}

extension CustomerRelationshipContextDocumentCategory {
    package func path(customerId: String, documentId: String, contentType: ContentType)-> String {
        return "customer-relationship-context/\(customerId)/\(self.rawValue)/\(documentId).\(contentType.fileExtension)"
    }
}
