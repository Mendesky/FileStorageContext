import DDDKit
import Foundation

class ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument: Entity, Document {
    let id: String
    let businessClientId: String
    let year: Date
    
    init(id: String, businessClientId: String, year: Date) {
        self.id = id
        self.businessClientId = businessClientId
        self.year = year
    }
}
