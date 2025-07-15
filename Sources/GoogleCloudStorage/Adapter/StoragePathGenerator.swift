import General

package struct StoragePathGenerator {
    
    static func generateQuotingContextPath(quotingCaseId: String, documentId: String, ext: String) -> String {
        return "\(quotingCaseId)/Quotation/\(documentId).\(ext)"
    }
    
    static func generateAuditContextPath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        return "\(customerId)/Audit/\(documentType.rawValue)/\(documentId).\(ext)"
    }
    
    static func generateCustomerRelationshipContextPath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        return "\(customerId)/CustomerRelationship/\(documentType.rawValue)/\(documentId).\(ext)"
    }
}
