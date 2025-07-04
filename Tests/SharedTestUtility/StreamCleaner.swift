import EventStoreDB
import TestUtility
@testable import BusinessClientAggregate


package class StreamCleaner {

    package static func clearStream(esdbClient: EventStoreDBClient, businessClientId id: String) async {
        await esdbClient.clearStreams(projectableType: BusinessClient.self, id: id)
    }
}
