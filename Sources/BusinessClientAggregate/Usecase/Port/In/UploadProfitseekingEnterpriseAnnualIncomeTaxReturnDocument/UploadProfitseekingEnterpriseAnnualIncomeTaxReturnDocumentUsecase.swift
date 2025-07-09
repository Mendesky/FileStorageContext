import DDDKit

protocol UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUsecase: Usecase where I == UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentInput, O == UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentOutput {
    var repository: BusinessClientRepository { get }
}

extension UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUsecase {

    package func execute(input: UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentInput) async throws -> UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentOutput {
        guard let businessClient = try await repository.find(byId: input.businessClientId) else {
            throw DDDError.aggregateNotFound(usecase: self, aggregateRootType: BusinessClient.self, aggregateRootId: input.businessClientId)
        }
        do {
            try businessClient.uploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocument(documentId: input.documentId, year: input.year)
            try await repository.save(aggregateRoot: businessClient, userId: input.userId)
        } catch {
            throw DDDError.executeUsecaseFailed(usecase: self, input: input, userInfos: ["error": error])
        }
        return .init(id: businessClient.id, message: nil)
    }
}
