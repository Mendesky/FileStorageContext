import Foundation
import Core
import Storage
import AsyncHTTPClient
import NIO

struct Config {
    let projectId = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com"
    let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky"
    let credentialsFile = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? "/home/suling/.jw_loader/credentials/gs/ai-jiabao-com-jw_storage.json"
}

func uploadToGoogleCloudStorage(httpClient: HTTPClient, eventLoopGroup: MultiThreadedEventLoopGroup, data: Data, name: String, contentType: String) async throws -> String? {
    let config = Config()
    let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: config.projectId, credentialsFile: config.credentialsFile)
    let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
    let gcs = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
    let object = try await gcs.object.createSimpleUpload(bucket: config.bucket, data: data, name: name, contentType: contentType).wait()
    return object.mediaLink
}