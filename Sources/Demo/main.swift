import Foundation
import AsyncHTTPClient
import NIO
import GoogleCloudStorage

let projectId = ProcessInfo.processInfo.environment["GCS_PROJECT_ID"] ?? "ai-jiabao-com"
let bucket = ProcessInfo.processInfo.environment["GCS_BUCKET"] ?? "mendesky-resource"

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let httpClient = HTTPClient(eventLoopGroup: eventLoopGroup)
let credentialsFile = ProcessInfo.processInfo.environment["GCS_CREDENTIALSFILE"] ?? ""
let storage = try Storage<StandardContextMetadata>(eventLoopGroup: eventLoopGroup, httpClient: httpClient, projectId: projectId, bucket: bucket, credentialsFile: credentialsFile)
try await storage.upload(data: "hello2".data(using: .utf8)!, path: "hello5.txt", contentType: "text/plain", metadata: StandardContextMetadata(originalName: "hello5.txt", context: "QuotingContext", aggregateRoot: "QuotingCase", aggregateRootId: "1234"), limit: .mb(10))

try await storage.markDelete(path: "hello3.txt")
