import Foundation
@_exported import FileStorageCore
import Core
@preconcurrency import Storage
import AsyncHTTPClient
import NIO

public struct Storage<MetadataType: Metadata>: StorageProtocol {
    let projectId: String
    let bucket: String
    let eventLoopGroup: EventLoopGroup
    let credentialsConfiguration: GoogleCloudCredentialsConfiguration
    let cloudStorageConfiguration: GoogleCloudStorageConfiguration
    
    public init(eventLoopGroup: EventLoopGroup, projectId: String, bucket: String, cloudStorageConfiguration: GoogleCloudStorageConfiguration = .default(), credentialsFile: String) throws {
        self.projectId = projectId
        self.bucket = bucket
        self.eventLoopGroup = eventLoopGroup
        self.credentialsConfiguration = try GoogleCloudCredentialsConfiguration(projectId: projectId, credentialsFile: credentialsFile)
        self.cloudStorageConfiguration = cloudStorageConfiguration
    }
    
    private func withGCSClient<Response>(_ handler:(_ underlyingClient: GoogleCloudStorageClient) async throws ->Response) async throws ->Response{
        let httpClient = HTTPClient(eventLoopGroup: eventLoopGroup)
        
        
        let client = try GoogleCloudStorageClient(credentials: credentialsConfiguration, storageConfig: cloudStorageConfiguration, httpClient: httpClient, eventLoop: eventLoopGroup.next())
        let response = try await handler(client)
        try await httpClient.shutdown()
        return response
    }
    
    
    
    public func upload(data: Data, path: String, contentType: String, metadata: [String: String]? = nil, limit: FileSizeLimit) async throws -> UploadedResult? {
        
        do {
            return try await withGCSClient { underlyingClient in
                let object = try await underlyingClient.object.createSimpleUpload(bucket: bucket, data: data, name: path, contentType: contentType).get()
                if let metadata {
                    try await setMetadata(metadata, path: path)
                }
                
                guard let mediaLink = object.mediaLink else {
                    return nil
                }
                return .init(path: path, mediaLink: mediaLink)
            }
        } catch {
            throw StorageError.uploadFailed(error: error)
        }
    }
    
    public func setMetadata(_ metadata: [String: String], path: String) async throws  {
        do {
            try await withGCSClient { underlyingClient in
                _ = try await underlyingClient.object.patch(bucket: bucket, object: path, metadata: metadata, queryParameters: nil).get()
            }
        } catch {
            throw StorageError.setMetadataFailed(error: error)
        }
    }
    
    public func getMetadata(path: String) async throws -> [String: String]? {
        do {
            return try await withGCSClient { underlyingClient in
                let object = try await underlyingClient.object.get(bucket: bucket, object: path, queryParameters: nil).get()
                return object.metadata
            }
        } catch {
            throw StorageError.setMetadataFailed(error: error)
        }
    }
    
    public func download(path: String) async throws -> DownloadResult? {
        do {
            return try await withGCSClient { underlyingClient in
                let object = try await underlyingClient.object.get(bucket: bucket, object: path, queryParameters: nil).get()
                
                let response = try await underlyingClient.object.getMedia(bucket: bucket, object: path, range: nil, queryParameters: nil).get()
                guard let data = response.data, let contentType = object.contentType else {
                    return nil
                }
                return .init(contentType: contentType, data: data)
            }
        } catch {
            throw StorageError.downloadFailed(error: error)
        }
    }
    
    public func download(mediaLink: String) async throws -> DownloadResult? {
        guard let mediaLink = MediaLink(urlString: mediaLink) else {
            return nil
        }
        return try await download(mediaLink: mediaLink)
    }
    
    public func download(mediaLink: MediaLink) async throws -> DownloadResult? {
        return try await download(path: mediaLink.object)
    }
    
}


extension Storage {
    
    public static func fromEnvironment(bucket: String, numberOfThreads: Int = 1) throws -> Self? {
        let projectId = "ai-jiabao-com"
        
        guard let credentialsFile: String = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] else {
            return nil
        }
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
        
        return try .init(eventLoopGroup: eventLoopGroup, projectId: projectId, bucket: bucket, credentialsFile: credentialsFile)
    }
}

