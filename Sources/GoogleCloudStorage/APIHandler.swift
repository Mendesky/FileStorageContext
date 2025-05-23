import Foundation
import Hummingbird
import OpenAPIRuntime
import AsyncHTTPClient
import Hummingbird
import NIO

enum FileSizeLimit{
    case bytes(Int)
    case kb(Int)
    case mb(Int)
    case gb(Int)
    
    
    var bytes: Int {
        switch self {
        case .bytes(let value):
            return value
        case .kb(let value):
            return value * 1024
        case .mb(let value):
            return value * 1024 * 1024
        case .gb(let value):
            return value * 1024 * 1024 * 1024
        }
    }
}

package struct APIHandler: APIProtocol {

    package init() {}
    
    package func uploadReplyForm(_ input: Operations.uploadReplyForm.Input) async throws -> Operations.uploadReplyForm.Output {
        
        let quotingCaseId = input.path.quotingCaseId
        let wrapped: (body: HTTPBody, fileName: String, contentType: String) = switch input.body {
        case let .jpeg(body):
            (body, "\(quotingCaseId).jpg", "image/jpeg")
        case let .png(body):
            (body, "\(quotingCaseId).png", "image/png")
        case let .pdf(body):
            (body, "\(quotingCaseId).pdf", "application/pdf")
        }

        return try await upload(body: wrapped.body, name: wrapped.fileName, contentType: wrapped.contentType, limit: .mb(10))
    }

    func upload(body: (HTTPBody), name: String, contentType: String, limit: FileSizeLimit) async throws -> Operations.uploadReplyForm.Output {
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
        do {
            let mediaLink = try await uploadToGoogleCloudStorage(httpClient: httpClient, eventLoopGroup: eventLoopGroup, data: .init(collecting: body, upTo: limit.bytes), name: name, contentType: contentType)
            try await httpClient.shutdown()
            return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
        } catch {
            try await httpClient.shutdown()
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
    }
}
