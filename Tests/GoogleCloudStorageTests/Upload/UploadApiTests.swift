import Foundation
import Testing
import OpenAPIRuntime
@testable import GoogleCloudStorage
 


@Suite(.serialized)
struct UploadApiTests {
    
    @Test("Upload with valid parameters")
    func upload() async throws {
        let customerId = "testCustomerId"
        
        let mediaLink = "gs://Audit"
        let uploader = MockUploader(mediaLink: mediaLink)
        let handler = ApiHandler(uploader: uploader)
        let bytes = [UInt8](repeating: 0, count: 1024)
        let response = try await handler.upload(headers: .init(fileContentType: .pdf), body: .multipartForm([.file(.init(payload: .init(body: HTTPBody(bytes)))), .meta(.init(payload: .init(body: .init(customerId: customerId, documentType: .BusinessClientRiskControlDocument))))]))
        
        let _ = try #require(response.ok.body.json.documentId)
        #expect(try response.ok.body.json.mediaLink == mediaLink)
    }
}
