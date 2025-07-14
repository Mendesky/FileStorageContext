import Foundation

package protocol Uploader: Sendable {
    func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String?
}
