import Foundation
import Core
import Storage
import AsyncHTTPClient
import NIO


package struct UploaderConfiguration {
    
    let projectId: String
    let bucket: String
    let credentialsFile: String
    
    static var `default`: Self {
        get {
            let projectId = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com"
            let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky"
            let credentialsFile = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? ""
            return .init(projectId: projectId, bucket: bucket, credentialsFile: credentialsFile)
        }
    }
}


package final class GcsUploader: Uploader {
    
    let eventLoopGroup: EventLoopGroup
    let httpClient: HTTPClient
    let config: UploaderConfiguration
    
    package init(eventLoopGroup: EventLoopGroup, httpClient: HTTPClient, config: UploaderConfiguration = .default) {
        self.eventLoopGroup = eventLoopGroup
        self.httpClient = httpClient
        self.config = config
    }
    
    package func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        do {
            let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: config.projectId, credentialsFile: config.credentialsFile)
            let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
            let gcs = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
            let object = try await gcs.object.createSimpleUpload(bucket: config.bucket, data: data, name: path, contentType: contentType).get()
            return object.mediaLink
        } catch {
            throw UploadError.uploadFailed(error: error)
        }
    }
}
