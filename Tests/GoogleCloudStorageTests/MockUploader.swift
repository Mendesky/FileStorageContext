import Foundation
import GoogleCloudStorage


package final class MockUploader: Uploader {
    
    let mediaLink: String?
    
    package init(mediaLink: String?) {
        self.mediaLink = mediaLink
    }

    package func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        return mediaLink
    }
}
