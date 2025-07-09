package struct StoragePathGenerator {
    
    static func generate(customerId: String, documentType: DocumentType?, documentId: String, ext: String) -> String {
        guard let documentType else {
            return "\(customerId)/Quotation/\(documentId).\(ext)"
        }
        return "\(customerId)/Audit/\(documentType.rawValue)/\(documentId).\(ext)"
    }
}
