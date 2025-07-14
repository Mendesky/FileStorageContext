package struct StoragePathGenerator {
    
    static func generateQuotingContextPath(customerId: String, documentId: String, ext: String) -> String {
        return "\(customerId)/Quotation/\(documentId).\(ext)"
    }
    
    static func generateAuditContextPath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        return "\(customerId)/Audit/\(documentType.rawValue)/\(documentId).\(ext)"
    }
}
