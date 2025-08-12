//
//  LoggingMiddleware.swift
//  FileStorageContext
//
//  Created by Grady Zhuo on 2025/8/12.
//
import Logging
import OpenAPIRuntime
import Hummingbird

struct LoggingMiddleware: ServerMiddleware {
    let logger = Logger(label: "LoggingMiddleware")
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        metadata: ServerRequestMetadata,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        logger.debug(">>>: \(request.method.rawValue) \(String(describing: request.path))")
        do {
            let (response, responseBody) = try await next(request, body, metadata)
            logger.debug("<<<: \(response.status.code)")
            return (response, responseBody)
        } catch {
            logger.error("The error happened: \(error.localizedDescription)")
            throw error
        }
    }
}
