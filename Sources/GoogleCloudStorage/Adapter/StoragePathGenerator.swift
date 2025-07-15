import FileStorageCore

package struct StoragePathGenerator {
    
    static func generateQuotingContextPath(quotingCaseId: String, documentId: String, ext: String) -> String {
        return "QuotingCase\(quotingCaseId)/Quotation/\(documentId).\(ext)"
    }
    
    static func generateAuditContextPath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        return "Customer\(customerId)/Audit/\(documentType.rawValue)/\(documentId).\(ext)"
    }
    
    static func generateCustomerRelationshipContextPath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        return "Customer\(customerId)/CustomerRelationship/\(documentType.rawValue)/\(documentId).\(ext)"
    }
}
