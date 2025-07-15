import Foundation
import Core
import Storage
import AsyncHTTPClient
import NIO
import General


package final class Uploader: UploaderProtocol {
    
    let eventLoopGroup: EventLoopGroup
    let httpClient: HTTPClient
    let projectId: String
    let bucket: String
    let credentialsFile: String
    
    package init(eventLoopGroup: EventLoopGroup, httpClient: HTTPClient, projectId: String = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com", bucket: String = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky", credentialsFile: String = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? "") {
        self.eventLoopGroup = eventLoopGroup
        self.httpClient = httpClient
        self.projectId = projectId
        self.bucket = bucket
        self.credentialsFile = credentialsFile
    }
    
    package func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        do {
            let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: projectId, credentialsFile: credentialsFile)
            let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
            let gcs = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
            let object = try await gcs.object.createSimpleUpload(bucket: bucket, data: data, name: path, contentType: contentType).get()
            return object.mediaLink
        } catch {
            throw UploadError.uploadFailed(error: error)
        }
    }
}
