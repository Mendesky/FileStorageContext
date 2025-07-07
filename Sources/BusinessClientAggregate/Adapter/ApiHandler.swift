import Foundation
import EventStoreDB


package struct ApiHandler: APIProtocol {

    let esdbClient: EventStoreDBClient
    
    package init(esdbClient: EventStoreDBClient) {
        self.esdbClient = esdbClient
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
}
