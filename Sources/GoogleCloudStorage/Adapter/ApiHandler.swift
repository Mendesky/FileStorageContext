import Foundation


package struct ApiHandler: APIProtocol {

    let uploader: Uploader
    
    package init(uploader: Uploader) {
        self.uploader = uploader
    }
    
    package func upload(_ input: Operations.upload.Input) async throws -> Operations.upload.Output {
        let fileContentType = input.headers.fileContentType.wrapped.fileContentType
        let ext = input.headers.fileContentType.wrapped.ext
        
        var fileData: Data?
        var customerId: String?
        var documentType: DocumentType?
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
                    documentType = DocumentType(rawValue: metaPayload.payload.body.documentType.rawValue)
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
        guard let documentType else {
            throw UploadError.documentTypeIsNil
        }
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = getFilePath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileContentType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
    }
}

extension ApiHandler {
    
    func getFilePath(customerId: String, documentType: DocumentType, documentId: String, ext: String) -> String {
        switch documentType {
        case .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument:
            return StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
        case .BusinessTaxReturnDocument:
            return StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
        case .BusinessClientRiskControlDocument:
            return StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
        case .FinancialComplianceAuditDocument:
            return StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
        case .TaxComplianceAuditDocument:
            return StoragePathGenerator.generateAuditContextPath(customerId: customerId, documentType: documentType, documentId: documentId, ext: ext)
        case .QuotingProof:
            return StoragePathGenerator.generateQuotingContextPath(customerId: customerId, documentId: documentId, ext: ext)
        case .ReplyForm:
            return StoragePathGenerator.generateQuotingContextPath(customerId: customerId, documentId: documentId, ext: ext)
        case .NewBusinessClientRiskControlDocument:
            return StoragePathGenerator.generateQuotingContextPath(customerId: customerId, documentId: documentId, ext: ext)
        }
    }
}
