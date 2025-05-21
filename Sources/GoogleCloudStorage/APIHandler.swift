import Foundation
import OpenAPIRuntime
import AsyncHTTPClient
import NIO

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

        return try await upload(body: wrapped.body, name: wrapped.fileName, contentType: wrapped.contentType)
    }

    func upload(body: (HTTPBody), name: String, contentType: String) async throws -> Operations.uploadReplyForm.Output {
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
        do {
            
            let data = try await body.reduce(into: Data()) { partialResult, bytes in
                partialResult.append(contentsOf: bytes)
            }
            try await httpClient.shutdown()
            return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
        } catch {
            try await httpClient.shutdown()
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
    }
}