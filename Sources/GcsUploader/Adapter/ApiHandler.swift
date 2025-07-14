import Foundation


package struct ApiHandler: APIProtocol {

    let uploader: Uploader
    
    package init(uploader: Uploader) {
        self.uploader = uploader
    }
    
    package func uploadFromQuotingContext(_ input: Operations.uploadFromQuotingContext.Input) async throws -> Operations.uploadFromQuotingContext.Output {
        let fileType = input.headers.fileContentType.wrapped.fileType
        let ext = input.headers.fileContentType.wrapped.ext
        
        var fileData: Data?
        var customerId: String?
        switch input.body {
        case let .multipartForm(multipartBody):
            for try await part in multipartBody {
                switch part {
                case let .file(filePayload):
                    fileData = try await filePayload.payload.body.reduce(into: Data()) { partialResult, byteChunk in
                        partialResult.append(contentsOf: byteChunk.map(\.self))
                    }
                case let .meta(metaPayload):
                    customerId = metaPayload.payload.body.customerId
                case .undocumented(_):
                    continue
                }
            }
        }
        guard let fileData else {
            throw UploadError.fileDataIsNil
        }
        guard let customerId else {
            throw UploadError.customerIdIsNil
        }
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = StoragePathGenerator.generateQuotingContextPath(customerId: customerId, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
}
