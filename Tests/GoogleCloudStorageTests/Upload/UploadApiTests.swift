import Foundation
import Testing
import OpenAPIRuntime
@testable import GoogleCloudStorage
 


@Suite(.serialized)
struct UploadFromQuotingContextApiTests {
    
    @Test("UploadFromQuotingContext with valid parameters")
    func uploadFromQuotingContext() async throws {
        let quotingCaseId = "testQuotingCaseId"
        
        let mediaLink = "gs://Quotation"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(uploader: uploader)
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.uploadFromQuotingContext(path: .init(quotingCaseId: quotingCaseId, quotingContextDocumentType: .quotingProof), headers: .init(fileContentType: .pdf), body: .multipartForm(.init(arrayLiteral: .file(.init(payload: .init(body: HTTPBody(bytes)))))))
        
        let _ = try #require(response.ok.body.json.documentId)
        #expect(try response.ok.body.json.mediaLink == mediaLink)
    }
    
    @Test("UploadFromCustomerRelationashipContext with valid parameters")
    func uploadFromCustomerRelationashipContext() async throws {
        let customerId = "testCustomerId"
        
        let mediaLink = "gs://CustomerRelationship"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(uploader: uploader)
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.uploadFromCustomerRelationshipContext(path: .init(customerId: customerId, customerRelationshipContextDocumentType: .newBusinessClientRiskControlDocument), headers: .init(fileContentType: .pdf), body: .multipartForm(.init(arrayLiteral: .file(.init(payload: .init(body: HTTPBody(bytes)))))))
        
        let _ = try #require(response.ok.body.json.documentId)
        #expect(try response.ok.body.json.mediaLink == mediaLink)
    }
    
    @Test("UploadFromAuditContext with valid parameters")
    func uploadFromAuditContext() async throws {
        let customerId = "testCustomerId"

        let mediaLink = "gs://Audit"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(uploader: uploader)
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.uploadFromAuditContext(path: .init(customerId: customerId, auditContextDocumentType: .businessClientRiskControlDocument), headers: .init(fileContentType: .pdf), body: .multipartForm(.init(arrayLiteral: .file(.init(payload: .init(body: HTTPBody(bytes)))))))
        
        let _ = try #require(response.ok.body.json.documentId)
        #expect(try response.ok.body.json.mediaLink == mediaLink)
    }
}
