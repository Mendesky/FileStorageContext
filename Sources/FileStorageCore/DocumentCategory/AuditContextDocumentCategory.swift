//
//  AuditContextDocumentCategory.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//


package enum AuditContextDocumentCategory {
    /// 結算申報書
    case profitseekingEnterpriseAnnualIncomeTaxReturnDocument
    /// 401
    case businessTaxReturnDocument(BusinessTaxReturnDocumentNo)
    /// 所客風控表
    case businessClientRiskControlDocument
    /// 財簽
    case financialComplianceAuditDocument
    /// 稅簽
    case taxComplianceAuditDocument
    
    
    var rawValue: String {
        switch self {
        case .profitseekingEnterpriseAnnualIncomeTaxReturnDocument:
            "profitseeking_enterprise_annual_income_tax_return_document"
        case .businessTaxReturnDocument(let no):
            "business_tax_return_document/\(no)"
        case .businessClientRiskControlDocument:
            "business_client_risk_control_document"
        case .financialComplianceAuditDocument:
            "financial_compliance_audit_document"
        case .taxComplianceAuditDocument:
            "tax_compliance_audit-document"
        }
    }
}

extension AuditContextDocumentCategory {
    package func path(customerId: String, documentId: String, contentType: ContentType)-> String {
        return "audit-context/\(customerId)/\(self.rawValue)/\(documentId).\(contentType.fileExtension)"
    }
}

extension AuditContextDocumentCategory {
    package enum BusinessTaxReturnDocumentNo: String {
        case _401 = "401"
        case _403 = "403"
    }
    
    
}
