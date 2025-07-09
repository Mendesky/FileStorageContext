import Foundation
import DDDKit

package struct UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentInput: Input {
    let documentId: String
    let businessClientId: String
    let year: Date
    let userId: String

    package init(documentId: String, businessClientId: String, year: Date, userId: String) {
        self.documentId = documentId
        self.businessClientId = businessClientId
        self.year = year
        self.userId = userId
    }
}
