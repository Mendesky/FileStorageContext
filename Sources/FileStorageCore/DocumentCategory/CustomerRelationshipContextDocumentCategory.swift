//
//  CustomerRelationshipContextDocumentCategory.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//


package enum CustomerRelationshipContextDocumentCategory {
    /// 新客風控表
    case newBusinessClientRiskControlDocument

    var rawValue: String {
        switch self {
        case .newBusinessClientRiskControlDocument:
            "business_client_risk_control_document/new"
        }
    }
}

extension CustomerRelationshipContextDocumentCategory {
    package func path(customerId: String, documentId: String, contentType: ContentType)-> String {
        return "customer-relationship-context/\(customerId)/\(self.rawValue)/\(documentId).\(contentType.fileExtension)"
    }
}
