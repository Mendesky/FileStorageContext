import FileStorageCore

extension Components.Parameters.fileContentType {
    var contentType: ContentType {
        switch self {
        case .jpeg:
            .jpeg
        case .pdf:
            .pdf
        case .png:
            .png
        }
    }
}


extension Components.Parameters.quotingContextDocumentType {
    var documentType: QuotingContextDocumentCategory {
        get{
            switch self{
            case .quotingProof:
                .quotingProof
            case .replyForm:
                .replyForm
            }
        }
    }
}

extension Components.Parameters.auditContextDocumentType {
    var documentType: AuditContextDocumentCategory {
        get{
            switch self{
            case .businessClientRiskControlDocument:
                .businessClientRiskControlDocument
            case .businessTaxReturnDocument401:
                .businessTaxReturnDocument(._401)
            case .financialComplianceAuditDocument:
                .financialComplianceAuditDocument
            case .profitseekingEnterpriseAnnualIncomeTaxReturnDocument:
                .financialComplianceAuditDocument
            case .taxComplianceAuditDocument:
                .taxComplianceAuditDocument
            }
        }
    }
}

extension Components.Parameters.customerRelationshipContextDocumentType {
    var documentType: CustomerRelationshipContextDocumentCategory {
        get{
            switch self{
            case .businessClientRiskControlDocument:
                .businessClientRiskControlDocument
            }
        }
    }
}
