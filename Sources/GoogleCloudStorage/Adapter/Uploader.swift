import Foundation
import Core
import Storage
import AsyncHTTPClient
import NIO
import FileStorageCore


package final class Storage: UploaderProtocol {

    let client: GoogleCloudStorageClient
    let projectId: String
    let bucket: String
    
    package init(eventLoopGroup: EventLoopGroup, httpClient: HTTPClient, projectId: String, bucket: String, credentialsFile: String) throws {
        let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: projectId, credentialsFile: credentialsFile)
        let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
        self.client = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
        self.projectId = projectId
        self.bucket = bucket
    }
    
    package func upload(data: Data, path: String, contentType: String, limit: FileSizeLimit) async throws -> String? {
        do {
            let object = try await client.object.createSimpleUpload(bucket: bucket, data: data, name: path, contentType: contentType).get()
            return object.mediaLink
        } catch {
            throw UploadError.uploadFailed(error: error)
        }
    }
    
    package func download(path: String) async throws {
        let object = try await client.object.get(bucket: bucket, object: path, queryParameters: nil).get()
        
    }
}
