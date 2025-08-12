import Foundation
import FileStorageCore


package struct ApiHandler: APIProtocol {

    let uploader: UploaderProtocol
    
    package init(uploader: UploaderProtocol) {
        self.uploader = uploader
    }
    
    package func uploadFromQuotingContext(_ input: Operations.uploadFromQuotingContext.Input) async throws -> Operations.uploadFromQuotingContext.Output {
        let contentType = input.headers.fileContentType.contentType
        
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
            throw UploadError.invalidFileData
        }

        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            
            let filePath = input.path.quotingContextDocumentType.documentType.path(documentId: documentId, contentType: contentType)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: contentType.rawValue, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
    
    package func uploadFromCustomerRelationshipContext(_ input: Operations.uploadFromCustomerRelationshipContext.Input) async throws -> Operations.uploadFromCustomerRelationshipContext.Output {
        let customerId = input.path.customerId
        let contentType = input.headers.fileContentType.contentType
        
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
            throw UploadError.invalidFileData
        }

        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = input.path.customerRelationshipContextDocumentType.documentType.path(customerId: customerId, documentId: documentId, contentType: contentType)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: contentType.rawValue, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
    
    package func uploadFromAuditContext(_ input: Operations.uploadFromAuditContext.Input) async throws -> Operations.uploadFromAuditContext.Output {
        let customerId = input.path.customerId
        let contentType = input.headers.fileContentType.contentType
        
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
            throw UploadError.invalidFileData
        }
        
        
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = input.path.auditContextDocumentType.documentType.path(customerId: customerId, documentId: documentId, contentType: contentType)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: contentType.rawValue, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
}
