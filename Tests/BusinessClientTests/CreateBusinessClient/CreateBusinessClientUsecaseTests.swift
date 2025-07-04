import Foundation
import Testing
import EventStoreDB
import SharedTestUtility
@testable import BusinessClientAggregate
 


@Suite(.serialized)
struct CreateBusinessClientUsecaseTests {
    
    let esdbClient = EventStoreDBClient(settings: .localhost())
    let eventMapper = BusinessClientAggregateEventMapper()
    let repository: BusinessClientRepository

    init() {
        repository = BusinessClientRepository(coordinator: .init(client: esdbClient, eventMapper: eventMapper))
    }

    func clearTestingData(id: String) async {
        await StreamCleaner.clearStream(esdbClient: esdbClient, businessClientId: id)
    }
    
    
    @Test("CreateBusinessClient with valid parameters")
    func create() async throws {
        let businessClientId = "testBusinessClientId"
        let customerId = "testCustomerId"
        let userId = "testUserId"
        
        await clearTestingData(id: businessClientId)
        
        let input = CreateBusinessClientInput(businessClientId: businessClientId, customerId: customerId, userId: userId)
        let usecase = CreateBusinessClientService(repository: repository)
        let output: CreateBusinessClientOutput = try await usecase.execute(input: input)
        
        #expect(output.id == businessClientId)

        let businessClient = try #require(try await repository.find(byId: businessClientId))
        
        #expect(businessClient.id == businessClientId)
        #expect(businessClient.customerId == customerId)
        
        await clearTestingData(id: businessClientId)
    }
}
