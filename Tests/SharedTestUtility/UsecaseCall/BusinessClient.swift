@testable import BusinessClientAggregate


@discardableResult
package func createBusinessClient(businessClientId: String, customerId: String, userId: String, repository: BusinessClientRepository) async throws -> String? {
    let output = try await CreateBusinessClientService(repository: repository).execute(input: .init(businessClientId: businessClientId, customerId: customerId, userId: userId))
    return output.id
}
