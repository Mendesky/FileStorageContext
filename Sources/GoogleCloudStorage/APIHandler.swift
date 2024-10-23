import Foundation
import OpenAPIRuntime
import AsyncHTTPClient
import NIO

package struct APIHandler: APIProtocol {

    package init() {}
    
    package func uploadReplyForm(_ input: Operations.uploadReplyForm.Input) async throws -> Operations.uploadReplyForm.Output {
        let quotingCaseId = input.path.quotingCaseId
        var response: Operations.uploadReplyForm.Output 
        switch input.body {
        case let .jpeg(body):
            response = try await upload(body: body, name: "\(quotingCaseId).jpg", contentType: "image/jpeg")
        case let .png(body):
            response = try await upload(body: body, name: "\(quotingCaseId).png", contentType: "image/png")
        case let .pdf(body):
            response = try await upload(body: body, name: "\(quotingCaseId).pdf", contentType: "application/pdf")
        }
        return response
    }

    func upload(body: (HTTPBody), name: String, contentType: String) async throws -> Operations.uploadReplyForm.Output {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
        do {
            let bytes: [UInt8] = try await body.reduce(.init()) { $0 + $1 }
            let mediaLink = try await uploadToGoogleCloudStorage(httpClient: httpClient, eventLoopGroup: eventLoopGroup, data: Data(bytes), name: name, contentType: contentType)
            try await httpClient.shutdown()
            return .ok(.init(body: .json(.init(mediaLink: mediaLink))))
        } catch {
            try await httpClient.shutdown()
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
    }
}