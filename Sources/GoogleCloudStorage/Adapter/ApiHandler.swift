import Foundation
import FileStorageCore


package struct ApiHandler: APIProtocol {

    let uploader: UploaderProtocol
    
    package init(uploader: UploaderProtocol) {
        self.uploader = uploader
    }
    
    package func uploadFromQuotingContext(_ input: Operations.uploadFromQuotingContext.Input) async throws -> Operations.uploadFromQuotingContext.Output {
        let quotingCaseId = input.path.quotingCaseId
        let fileContentType = input.headers.fileContentType.wrapped.fileContentType
        let ext = input.headers.fileContentType.wrapped.ext
        
        var fileData: Data?
        switch input.body {
        case let .multipartForm(multipartBody):
            for try await part in multipartBody {
                switch part {
                case let .file(filePayload):
                    fileData = try await filePayload.payload.body.reduce(into: Data()) { partialResult, byteChunk in
                        partialResult.append(contentsOf: byteChunk.map(\.self))
                    }
                case .undocumented(_):
                    continue
                }
            }
        }
        guard let fileData else {
            throw UploadError.fileDataIsNil
        }

        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = StoragePathGenerator.generateQuotingContextPath(quotingCaseId: quotingCaseId, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileContentType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
    
    package func uploadFromCustomerRelationshipContext(_ input: Operations.uploadFromCustomerRelationshipContext.Input) async throws -> Operations.uploadFromCustomerRelationshipContext.Output {
        let customerId = input.path.customerId
        let fileContentType = input.headers.fileContentType.wrapped.fileContentType
        let ext = input.headers.fileContentType.wrapped.ext
        
        var fileData: Data?
        switch input.body {
        case let .multipartForm(multipartBody):
            for try await part in multipartBody {
                switch part {
                case let .file(filePayload):
                    fileData = try await filePayload.payload.body.reduce(into: Data()) { partialResult, byteChunk in
                        partialResult.append(contentsOf: byteChunk.map(\.self))
                    }
                case .undocumented(_):
                    continue
                }
            }
        }
        guard let fileData else {
            throw UploadError.fileDataIsNil
        }
        guard let documentType = DocumentType(rawValue: input.path.customerRelationshipContextDocumentType.rawValue) else {
            throw UploadError.documentTypeIsInValid(value: input.path.customerRelationshipContextDocumentType.rawValue)
        }
        
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = StoragePathGenerator.generateCustomerRelationshipContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileContentType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
    
    package func uploadFromAuditContext(_ input: Operations.uploadFromAuditContext.Input) async throws -> Operations.uploadFromAuditContext.Output {
        let customerId = input.path.customerId
        let fileContentType = input.headers.fileContentType.wrapped.fileContentType
        let ext = input.headers.fileContentType.wrapped.ext
        
        var fileData: Data?
        switch input.body {
        case let .multipartForm(multipartBody):
            for try await part in multipartBody {
                switch part {
                case let .file(filePayload):
                    fileData = try await filePayload.payload.body.reduce(into: Data()) { partialResult, byteChunk in
                        partialResult.append(contentsOf: byteChunk.map(\.self))
                    }
                case .undocumented(_):
                    continue
                }
            }
        }
        guard let fileData else {
            throw UploadError.fileDataIsNil
        }
        guard let documentType = DocumentType(rawValue: input.path.auditContextDocumentType.rawValue) else {
            throw UploadError.documentTypeIsInValid(value: input.path.auditContextDocumentType.rawValue)
        }
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileContentType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
}
