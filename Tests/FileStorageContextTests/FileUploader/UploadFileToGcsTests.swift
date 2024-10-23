@testable import FileUploader
import XCTest


final class UploadFileToGcsAPITests: XCTestCase {
    
    func testUploadFileToGcs() async throws {
        let quotingCaseId = UUID().uuidString
        let bytes = [UInt8](repeating: 0, count: 1024)

        let apiHandler = APIHandler()
        let response = try await apiHandler.uploadFile(path: .init(quotingCaseId: quotingCaseId), headers: .init(), body: .pdf(.init(bytes)))
        XCTAssertNotNil(try response.ok.body.json.mediaLink)
    }
}