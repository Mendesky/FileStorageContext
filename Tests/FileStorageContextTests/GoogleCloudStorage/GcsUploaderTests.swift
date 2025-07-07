//@testable import GoogleCloudStorage
//import XCTest
//
//
//final class UploadReplyFormAPITests: XCTestCase {
//
//    override func setUp() {
//        setenv("GCS_CREDENTIALSFILE", "/home/suling/.jw_loader/credentials/gs/ai-jiabao-com-jw_storage.json", 1)
//    }
//    
//    func testUploadReplyFormToGcs() async throws {
//        let quotingCaseId = UUID().uuidString
//        let bytes = [UInt8](repeating: 0, count: 1024)
//
//        let apiHandler = APIHandler()
//        let response = try await apiHandler.uploadReplyForm(path: .init(quotingCaseId: quotingCaseId), headers: .init(), body: .pdf(.init(bytes)))
//        XCTAssertNotNil(try response.ok.body.json.mediaLink)
//    }
//}
