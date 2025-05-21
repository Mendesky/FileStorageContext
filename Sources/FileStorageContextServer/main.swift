import Foundation
import Hummingbird
import OpenAPIHummingbird
import GoogleCloudStorage

// Create your router.
let router = Router()

// Create an instance of your handler type that conforms the generated protocol
// defining your service API.
let api = APIHandler()

router.middlewares.add(CORSMiddleware(allowOrigin: .all, allowMethods: [.get, .post, .put, .delete, .patch]))

// Call the generated function on your implementation to add its request
// handlers to the app.
try api.registerHandlers(on: router, serverURL: URL(string: "/file-storage-context")!)


// Create the application and run as you would normally.
let app = Application(router: router, configuration: .init(address: .hostname("0.0.0.0", port: 13579)))
try await app.runService()

