import Foundation
import OpenAPIRuntime
import AsyncHTTPClient
import NIO

package struct APIHandler: APIProtocol {

    package init() {}
    
    package func uploadFile(_ input: Operations.uploadFile.Input) async throws -> Operations.uploadFile.Output {
        let quotingCaseId = input.path.quotingCaseId
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
        switch input.body {
        case let .jpeg(body):
            do {
                let bytes: [UInt8] = try await body.reduce(.init()) { $0 + $1 }
                let mediaLink = try await uploadToGoogleCloudStorage(httpClient: httpClient, eventLoopGroup: eventLoopGroup, data: Data(bytes), name: "\(quotingCaseId).jpg", contentType: "image/jpeg")
                try await httpClient.shutdown()
                return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
            } catch {
                try await httpClient.shutdown()
                return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
            }
        case let .png(body):
            do {
                let bytes: [UInt8] = try await body.reduce(.init()) { $0 + $1 }
                let mediaLink = try await uploadToGoogleCloudStorage(httpClient: httpClient, eventLoopGroup: eventLoopGroup, data: Data(bytes), name: "\(quotingCaseId).png", contentType: "image/png")
                try await httpClient.shutdown()
                return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
            } catch {
                try await httpClient.shutdown()
                return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
            }
        case let .pdf(body):
            do {
                let bytes: [UInt8] = try await body.reduce(.init()) { $0 + $1 }
                let mediaLink = try await uploadToGoogleCloudStorage(httpClient: httpClient, eventLoopGroup: eventLoopGroup, data: Data(bytes), name: "\(quotingCaseId).pdf", contentType: "application/pdf")
                try await httpClient.shutdown()
                return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
            } catch {
                try await httpClient.shutdown()
                return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
            }
        }
    }
}