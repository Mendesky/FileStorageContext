import AsyncHTTPClient
import OpenAPIRuntime

protocol Uploader: Sendable {
    func upload(body: (HTTPBody), name: String, contentType: String, limit: FileSizeLimit) async throws -> String?
}
