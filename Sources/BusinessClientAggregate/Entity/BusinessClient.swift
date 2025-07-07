import Foundation
import DDDKit


package class BusinessClient: BusinessClientAggregateProtocol {

    package var metadata: DDDCore.AggregateRootMetadata = .init()
    
    package let id: String
    let customerId: String
    
    init(id: String, customerId: String) {
        self.id = id
        self.customerId = customerId
        
        let event = BusinessClientCreated(businessClientId: id, customerId: customerId)
        try? apply(event: event)
    }
    
    package required convenience init?(first createdEvent: BusinessClientCreated, other events: [any DDDCore.DomainEvent]) throws {
        self.init(id: createdEvent.businessClientId, customerId: createdEvent.customerId)
        try apply(events: events)
        try clearAllDomainEvents()
    }
}
