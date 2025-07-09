import Foundation
import Testing
import EventStoreDB
import SharedTestUtility
import AsyncHTTPClient
import NIO
@testable import BusinessClientAggregate
 


@Suite(.serialized)
struct CreateBusinessClientApiTests {
    
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
        let customerId = "testCustomerId"
        let userId = "testUserId"
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
        let uploader = GcsUploader(eventLoopGroup: eventLoopGroup, httpClient: httpClient)
        let handler = ApiHandler(esdbClient: esdbClient, uploader: uploader)
        let response = try await handler.createBusinessClient(headers: .init(userId: userId), body: .json(.init(customerId: customerId)))
        
        let businessClientId = try #require(response.created.body.json.businessClientId)
        let businessClient = try #require(try await repository.find(byId: businessClientId))
        
        #expect(businessClient.id == businessClientId)
        #expect(businessClient.customerId == customerId)
        
        await clearTestingData(id: businessClientId)
    }
}
