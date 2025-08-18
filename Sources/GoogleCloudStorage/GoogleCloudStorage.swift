import Foundation
@_exported import FileStorageCore
import Core
@preconcurrency import Storage
import AsyncHTTPClient
import NIO

public struct Storage<MetadataType: Metadata>: StorageProtocol {
    package let underlyingClient: GoogleCloudStorageClient
    let projectId: String
    let bucket: String
    
    public init(projectId: String, bucket: String, eventLoopGroup: EventLoopGroup, client: GoogleCloudStorageClient){
        self.underlyingClient = client
        self.projectId = projectId
        self.bucket = bucket
    }
    
    public init(eventLoopGroup: EventLoopGroup, httpClient: HTTPClient, projectId: String, bucket: String, credentialsFile: String) throws {
        let credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: projectId, credentialsFile: credentialsFile)
        
        let cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default()
        let underlyingClient = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
        self.init(projectId: projectId, bucket: bucket, eventLoopGroup: eventLoopGroup, client: underlyingClient)
    }
    
    public func upload(data: Data, path: String, contentType: String, metadata: [String: Codable]? = nil, limit: FileSizeLimit) async throws -> String? {
        
        do {
            let object = try await underlyingClient.object.createSimpleUpload(bucket: bucket, data: data, name: path, contentType: contentType).get()
            if let metadata {
                try await setMetadata(metadata, path: path)
            }
            return object.mediaLink
        } catch {
            throw StorageError.uploadFailed(error: error)
        }
    }
    
    public func setMetadata(_ metadata: [String: Any], path: String) async throws  {
        do {
            _ = try await underlyingClient.object.patch(bucket: bucket, object: path, metadata: metadata, queryParameters: nil).get()
        } catch {
            throw StorageError.setMetadataFailed(error: error)
        }
    }
    
    public func getMetadata(_ metadata: [String: String], path: String) async throws -> [String: String]? {
        do {
            let object = try await underlyingClient.object.get(bucket: bucket, object: path, queryParameters: nil).get()
            return object.metadata
        } catch {
            throw StorageError.setMetadataFailed(error: error)
        }
    }
    
    public func download(path: String) async throws -> Data? {
        do {
            let response = try await underlyingClient.object.getMedia(bucket: bucket, object: path, range: nil, queryParameters: nil).get()
            return response.data
        } catch {
            throw StorageError.downloadFailed(error: error)
        }
    }
    
    public func markDelete(path: String) async throws {
        do {
            try await setMetadata(["markDeleted": true], path: path)
        } catch {
            throw StorageError.markDeletedFailed(error: error)
        }
    }
    
}
