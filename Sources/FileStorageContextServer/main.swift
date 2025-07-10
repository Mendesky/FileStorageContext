import Foundation
import Hummingbird
import OpenAPIHummingbird
import EventStoreDB
import AsyncHTTPClient
import NIO
import BusinessClientAggregate

// Create your router.
let router = Router()

// Create an instance of your handler type that conforms the generated protocol
// defining your service API.
let esdbSettings: String = ProcessInfo.processInfo.environment["ESDB_URL"] ?? "esdb://admin:changeit@localhost:2113?tls=false"
let esdbClient = EventStoreDBClient(settings: try esdbSettings.parse())
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
let uploader = GcsUploader(eventLoopGroup: eventLoopGroup, httpClient: httpClient)
let api = ApiHandler(esdbClient: esdbClient, uploader: uploader)

router.middlewares.add(CORSMiddleware(allowOrigin: .all, allowMethods: [.get, .post, .put, .delete, .patch]))

// Call the generated function on your implementation to add its request
// handlers to the app.
try api.registerHandlers(on: router, serverURL: URL(string: "/file-storage-context")!)


// Create the application and run as you would normally.
let app = Application(router: router, configuration: .init(address: .hostname("0.0.0.0", port: 13579)))
try await app.runService()

