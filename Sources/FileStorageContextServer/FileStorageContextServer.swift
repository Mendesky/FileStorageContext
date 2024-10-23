import Foundation
import Hummingbird
import OpenAPIHummingbird
import FileUploader


let app = HBApplication(configuration: .init(address: .hostname("0.0.0.0", port: 13579)))
app.middleware.add(HBCORSMiddleware(allowOrigin: .all, allowMethods: [.GET, .POST, .PUT, .DELETE, .PATCH]))
let transport = HBOpenAPITransport(app)

try FileUploader.APIHandler().registerHandlers(on: transport, serverURL: URL(string: "/file-storage-context")!)
try await app.asyncRun()