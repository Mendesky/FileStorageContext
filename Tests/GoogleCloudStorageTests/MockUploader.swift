import Foundation
import FileStorageCore


package final class MockUploader: UploaderProtocol {
    
    let mediaLink: String?
    
    package init(mediaLink: String?) {
        self.mediaLink = mediaLink
    }

    package func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        return mediaLink
    }
}
