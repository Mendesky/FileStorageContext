import Foundation

extension BusinessClient {
    
    package func uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(documentId: String, year: Date) throws {
        let event = ProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUploaded(businessClientId: id, documentId: documentId, year: year)
        try apply(event: event)
    }
    
    package func when(event: ProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUploaded) throws {
        let document = ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(id: event.documentId, businessClientId: event.businessClientId, year: event.year)
        self.documents.append(document)
    }
}
