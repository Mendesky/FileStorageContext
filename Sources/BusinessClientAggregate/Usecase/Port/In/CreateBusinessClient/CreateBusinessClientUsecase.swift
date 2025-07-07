import DDDKit

protocol CreateBusinessClientUsecase: Usecase where I == CreateBusinessClientInput, O == CreateBusinessClientOutput {
    var repository: BusinessClientRepository { get }
}

extension CreateBusinessClientUsecase {

    package func execute(input: CreateBusinessClientInput) async throws -> CreateBusinessClientOutput {
        let businessClient = BusinessClient(id: input.businessClientId, customerId: input.customerId)
        do {
            try await repository.save(aggregateRoot: businessClient, userId: input.userId)
        } catch {
            throw DDDError.executeUsecaseFailed(usecase: self, input: input, userInfos: ["error": error])
        }
        return .init(id: businessClient.id, message: nil)
    }
}
