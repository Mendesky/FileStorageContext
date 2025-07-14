import Foundation
import Hummingbird
import OpenAPIHummingbird
import AsyncHTTPClient
import NIO
import GcsUploader

// Create your router.
let router = Router()

// Create an instance of your handler type that conforms the generated protocol
// defining your service API.
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: .init(ignoreUncleanSSLShutdown: true))
let uploader = GcsUploader(eventLoopGroup: eventLoopGroup, httpClient: httpClient)
let api = ApiHandler(uploader: uploader)

router.middlewares.add(CORSMiddleware(allowOrigin: .all, allowMethods: [.get, .post, .put, .delete, .patch]))

// Call the generated function on your implementation to add its request
// handlers to the app.
try api.registerHandlers(on: router, serverURL: URL(string: "/file-storage-context")!)


// Create the application and run as you would normally.
let app = Application(router: router, configuration: .init(address: .hostname("0.0.0.0", port: 13579)))
try await app.runService()

