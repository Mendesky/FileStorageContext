import Foundation
import OpenAPIRuntime
import EventStoreDB


package struct ApiHandler: APIProtocol {

    let esdbClient: EventStoreDBClient
    let uploader: Uploader
    
    init(esdbClient: EventStoreDBClient, uploader: Uploader) {
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
        let wrapped: (contentType: String, ext: String) = switch input.headers.contentType {
        case .jpeg:
            ("image/jpeg", "jpg")
        case .pdf:
            ("application/pdf", "pdf")
        case .png:
            ("image/png", "png")
        }
        
        var customerId: String?
        var year: Date?
        var fileData: HTTPBody?
        switch input.body {
        case let .multipartForm(multipartBody):
            for try await part in multipartBody {
                switch part {
                case let .file(filePayload):
                    fileData = filePayload.payload.body
                case let .customerId(customerPayload):
                    customerId = customerPayload.payload.body
                case let .year(yearPayload):
                    year = Date(timeIntervalSince1970: yearPayload.payload.body)
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
            let filePath = StoragePathGenerator.generate(customerId: customerId, documentType: .ProfitseekingEnterpriseAnnualIncomeTaxReturnDocument, documentId: documentId, ext: wrapped.ext)
            mediaLink = try await self.uploader.upload(body: fileData, name: filePath, contentType: wrapped.contentType, limit: .mb(10))
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
