import Foundation
import Testing
import EventStoreDB
import SharedTestUtility
import DDDKit
import AsyncHTTPClient
import NIO
import OpenAPIRuntime
@testable import BusinessClientAggregate
 


@Suite(.serialized)
struct UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentApiTests {
    
    let esdbClient = EventStoreDBClient(settings: .localhost())
    let eventMapper = BusinessClientAggregateEventMapper()
    let repository: BusinessClientRepository
    
    init() {
        repository = BusinessClientRepository(coordinator: .init(client: esdbClient, eventMapper: eventMapper))
    }
    
    func clearTestingData(id: String) async {
        await StreamCleaner.clearStream(esdbClient: esdbClient, businessClientId: id)
    }
    
    @Test("UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument with valid parameters")
    func upload() async throws {
        let businessClientId = "testBusinessClientId"
        let customerId = "testCustomerId"
        let userId = "testUserId"
        
        await clearTestingData(id: businessClientId)
        
        try await createBusinessClient(businessClientId: businessClientId, customerId: customerId, userId: userId, repository: repository)

        let year: Double = 17564511100000.9
        let mediaLink = "gs://Audit"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(esdbClient: esdbClient, uploader: uploader)
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(path: .init(businessClientId: businessClientId), headers: .init(userId: userId, fileType: .pdf), body: .multipartForm([.file(.init(payload: .init(body: HTTPBody(bytes)))), .meta(.init(payload: .init(body: .init(customerId: customerId, year: year))))]))
        
        let documentId = try #require(response.ok.body.json.documentId)
        #expect(try response.ok.body.json.mediaLink == mediaLink)
        
        let businessClient = try #require(await repository.find(byId: businessClientId))
        #expect(businessClient.documents.count == 1)
        let document = try #require(businessClient.findDocument(byId: documentId)) as! ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument
        #expect(document.id == documentId)
        #expect(document.businessClientId == businessClientId)
        #expect(document.year == Date(timeIntervalSince1970: year))
        
        await clearTestingData(id: businessClientId)
    }
    
    @Test("UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument with businessClient not existing")
    func uploadWithAggregateRootNotExisted() async throws {
        let businessClientId = "businessClientId"
        let customerId = "customerId"
        let userId = "userId"
        
        let mediaLink = "gs://Audit"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(esdbClient: esdbClient, uploader: uploader)
        let year: Double = 17564511100000.9
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(path: .init(businessClientId: businessClientId), headers: .init(userId: userId, fileType: .pdf), body: .multipartForm([.file(.init(payload: .init(body: HTTPBody(bytes)))), .meta(.init(payload: .init(body: .init(customerId: customerId, year: year))))]))
        
        switch response {
            case let .serviceUnavailable(error):
                #expect(try error.body.json.value != nil)
            default:
                Issue.record("reponse should be serviceUnavailable")
        }
    }
}
