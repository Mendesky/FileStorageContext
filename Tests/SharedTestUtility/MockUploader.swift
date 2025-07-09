@testable import BusinessClientAggregate
import OpenAPIRuntime


package final class MockUploader: Uploader {
    
    let mediaLink: String?
    
    package init(mediaLink: String?) {
        self.mediaLink = mediaLink
    }

    package func upload(body: (HTTPBody), name: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        return mediaLink
    }
}
