import Foundation
import OpenAPIRuntime
import Core
import Storage
import AsyncHTTPClient
import NIO


package struct Config {
    let projectId = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com"
    let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky"
    let credentialsFile = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? ""
}

package final class GcsUploader: Uploader {
    
    let eventLoopGroup: EventLoopGroup
    let httpClient: HTTPClient
    let config: Config
    
    init(eventLoopGroup: EventLoopGroup, httpClient: HTTPClient) {
        self.eventLoopGroup = eventLoopGroup
        self.httpClient = httpClient
        self.config = Config()
    }
    
    func upload(body: (HTTPBody), name: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        do {
            let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: config.projectId, credentialsFile: config.credentialsFile)
            let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
            let gcs = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
            let data = try await Data(collecting: body, upTo: limit.bytes)
            let object = try await gcs.object.createSimpleUpload(bucket: config.bucket, data: data, name: name, contentType: contentType).get()
            return object.mediaLink
        } catch {
            throw UploadError.uploadFailed(error: error)
        }
    }
}
