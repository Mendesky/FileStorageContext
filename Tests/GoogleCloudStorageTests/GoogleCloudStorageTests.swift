//
//  GoogleCloudStorageTests.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/18.
//
import Foundation
import Testing
@testable import GoogleCloudStorage
import AsyncHTTPClient
import NIO

@Test("Test upload plain text.")
func uploadPlainText() async throws {
    guard let storage = try Storage<StandardContextMetadata>.fromEnvironment(bucket: "mendesky-resource", numberOfThreads: 1) else {
        Issue.record("Failed to create storage client.")
        return
    }
    let data = "hello2".data(using: .utf8)!
    let contextInfo = ContextStorageInfo.init(context: "QuotingContext", category: "revenueQuotingProof")
    let metadata = StandardContextMetadata(originalName: "hello6.txt", context: "QuotingContext", aggregateRoot: "QuotingCase", aggregateRootId: "1234")
    let contentType = "text/plain"
    let result = try await storage.upload(data: data, contextInfo: contextInfo, contentType: contentType, metadata: metadata, limit: .mb(10))
    
    let downloaded = try await storage.download(mediaLink: #require(result).uploadedResult.mediaLink)
    #expect(downloaded?.data == data)
    #expect(downloaded?.contentType == contentType)
    
}
