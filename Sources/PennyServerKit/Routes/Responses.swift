import Foundation
import Hummingbird
import PennyCore

enum Responses {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        return encoder
    }()

    static func json(_ value: some Encodable, status: HTTPResponse.Status = .ok) throws -> Response {
        let data = try encoder.encode(value)
        return Response(
            status: status,
            headers: [.contentType: "application/json; charset=utf-8", .cacheControl: "no-store"],
            body: ResponseBody(byteBuffer: ByteBuffer(bytes: data))
        )
    }

    static func error(_ message: String, status: HTTPResponse.Status) throws -> Response {
        try json(API.ErrorBody(message), status: status)
    }

    static func error(_ errors: ValidationError, status: HTTPResponse.Status) throws -> Response {
        try json(API.ErrorBody(errors), status: status)
    }

    static func html(_ document: String, status: HTTPResponse.Status = .ok) -> Response {
        Response(
            status: status,
            headers: [.contentType: "text/html; charset=utf-8", .cacheControl: "public, max-age=300"],
            body: ResponseBody(byteBuffer: ByteBuffer(string: document))
        )
    }
}
