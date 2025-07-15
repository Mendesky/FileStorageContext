import Foundation

package protocol UploaderProtocol: Sendable {
    func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String?
}
