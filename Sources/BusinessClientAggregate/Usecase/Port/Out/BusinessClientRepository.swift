import DDDKit

package class BusinessClientRepository: EventSourcingRepository {
    package typealias StorageCoordinator = ESDBStorageCoordinator<BusinessClient>
    package typealias AggregateRootType = BusinessClient

    package let coordinator: StorageCoordinator
    
    package init(coordinator: StorageCoordinator) {
        self.coordinator = coordinator
    }
}
