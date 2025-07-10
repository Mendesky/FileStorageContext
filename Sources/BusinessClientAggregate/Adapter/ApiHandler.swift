import Foundation
import OpenAPIRuntime
import EventStoreDB


package struct ApiHandler: APIProtocol {

    let esdbClient: EventStoreDBClient
    let uploader: Uploader
    
    package init(esdbClient: EventStoreDBClient, uploader: Uploader) {
        self.esdbClient = esdbClient
        self.uploader = uploader
    }
    
    package func createBusinessClient(_ input: Operations.createBusinessClient.Input) async throws -> Operations.createBusinessClient.Output {
        guard case let .json(payload) = input.body else {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "Not supported body:  \(String(describing: input.body))"))))
        }
        
        let userId = input.headers.userId
        let repository = BusinessClientRepository(coordinator: .init(client: esdbClient, eventMapper: BusinessClientAggregateEventMapper()))
        let service = CreateBusinessClientService(repository: repository)
        do {
            let output = try await service.execute(input: .init(businessClientId: UUID().uuidString, customerId: payload.customerId, userId: userId))
            return .created(.init(body: .json(.init(businessClientId: output.id))))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
    }
    
    package func uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(_ input: Operations.uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument.Input) async throws -> Operations.uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument.Output {
        let businessClientId = input.path.businessClientId
        let userId = input.headers.userId
        let fileType = input.headers.fileType.wrapped.fileType
        let ext = input.headers.fileType.wrapped.ext
        
        var customerId: String?
        var year: Date?
        var fileData: Data?
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
                    year = Date(timeIntervalSince1970: metaPayload.payload.body.year)
                case .undocumented(_):
                    continue
                }
            }
        }
        guard let fileData else {
            throw UploadError.fileDataIsNil(businessClientId: businessClientId, documentType: .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument)
        }
        guard let customerId else {
            throw UploadError.customerIdIsNil(businessClientId: businessClientId, documentType: .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument)
        }
        guard let year else {
            throw UploadError.yearIsNil(businessClientId: businessClientId, documentType: .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument)
        }
        let documentId = UUID().uuidString
        var mediaLink: String?
        do {
            let filePath = StoragePathGenerator.generate(customerId: customerId, documentType: .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument, documentId: documentId, ext: ext)
            mediaLink = try await self.uploader.upload(data: fileData, path: filePath, contentType: fileType, limit: .mb(10))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
        
        let repository = BusinessClientRepository(coordinator: .init(client: esdbClient, eventMapper: BusinessClientAggregateEventMapper()))
        let service = UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentService(repository: repository)
        do {
            let _ = try await service.execute(input: .init(documentId: documentId, businessClientId: businessClientId, year: year, userId: userId))
            return .ok(.init(body: .json(.init(documentId: documentId, mediaLink: mediaLink))))
        } catch {
            return .serviceUnavailable(.init(body: .json(.init(stringLiteral: "\(error)"))))
        }
    }
}
