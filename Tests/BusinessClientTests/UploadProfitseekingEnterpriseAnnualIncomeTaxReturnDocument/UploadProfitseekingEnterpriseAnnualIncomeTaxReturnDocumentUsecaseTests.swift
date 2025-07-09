import Foundation
import Testing
import EventStoreDB
import SharedTestUtility
import DDDKit
@testable import BusinessClientAggregate
 


@Suite(.serialized)
struct UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUsecaseTests {
    
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

        let documentId = "testDocumentId"
        let year: Date = .init(timeIntervalSince1970: 17564511100000.9)
        let input = UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentInput(documentId: documentId, businessClientId: businessClientId, year: year, userId: userId)
        let usecase = UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentService(repository: repository)
        let output: UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentOutput = try await usecase.execute(input: input)
        
        #expect(output.id == businessClientId)

        let businessClient = try #require(try await repository.find(byId: businessClientId))
        
        #expect(businessClient.id == businessClientId)
        #expect(businessClient.customerId == customerId)
        #expect(businessClient.documents.count == 1)
        
        let document = businessClient.documents.first { $0.id == documentId } as! ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument
        
        #expect(document.id == documentId)
        #expect(document.businessClientId == businessClientId)
        #expect(document.year == year)
        
        await clearTestingData(id: businessClientId)
    }
    
    @Test("UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument with businessClient not existing")
    func addWithAggregateRootNotExisted() async throws {
        let businessClientId = "businessClientId"
        let documentId = "documentId"
        let year: Date = .init(timeIntervalSince1970: 1758900000.9)
        let userId = "userId"
        
        let input = UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentInput(documentId: documentId, businessClientId: businessClientId, year: year, userId: userId)
        let usecase = UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentService(repository: repository)

        await #expect(performing: {
            let _: UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentOutput = try await usecase.execute(input: input)
        }, throws: { e in
            guard let error = e as? DDDError else {
                return false
            }
            return error.code == DDDError.Code.aggregateNotFound
        })
    }
}
