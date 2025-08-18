import Foundation
import AsyncHTTPClient
import NIO
@testable import GoogleCloudStorage

let projectId = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com"
let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky-resource"

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let httpClient = HTTPClient(eventLoopGroup: eventLoopGroup)
let credentialsFile = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? ""
let storage = try Storage<StandardContextMetadata>(eventLoopGroup: eventLoopGroup, httpClient: httpClient, projectId: projectId, bucket: bucket, credentialsFile: credentialsFile)

let result = try await storage.underlyingClient.object.createSimpleUpload(bucket: bucket, body: .data("hello2".data(using: .utf8)!), name: "xxx.txt", contentType: "text/plain", queryParameters: nil).get()

try await storage.upload(data: "hello2".data(using: .utf8)!, path: "hello6.txt", contentType: "text/plain", metadata: StandardContextMetadata(originalName: "hello6.txt", context: "QuotingContext", aggregateRoot: "QuotingCase", aggregateRootId: "1234"), limit: .mb(10))

try await storage.markDelete(path: "hello6.txt")

let metadata = try await storage.getMetadata(path: "hello6.txt")
print(metadata)
print(try await storage.isMarkedDeleted(path: "hello6.txt"))
