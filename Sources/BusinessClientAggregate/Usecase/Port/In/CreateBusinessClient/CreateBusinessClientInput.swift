import Foundation
import DDDKit

package struct CreateBusinessClientInput: Input {
    let businessClientId: String
    let customerId: String
    let userId: String

    package init(businessClientId: String, customerId: String, userId: String) {
        self.businessClientId = businessClientId
        self.customerId = customerId
        self.userId = userId
    }
}
