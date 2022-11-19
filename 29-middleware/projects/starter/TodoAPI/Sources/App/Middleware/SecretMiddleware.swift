
import Vapor

/// Rejects requests that do not contain correct secret.
final class SecretMiddleware: Middleware {
	let secret: String
	
	init(secret: String) {
		self.secret = secret
	}
	
	func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
		guard request.headers.first(name: .xSecret) == secret else {
			return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Incorrect X-Secret header."))
		}
		return next.respond(to: request)
	}
}

extension SecretMiddleware {
	static func detect() throws -> Self {
		guard let secret = Environment.get("SECRET") else {
			throw Abort(.internalServerError, reason: """
				No SECRET set on environment. \
				Use export SECRET=<secret>
				"""
			)
		}
		return .init(secret: secret)
	}
}

extension HTTPHeaders.Name {
	/// Contains a secret key.
	///
	/// `HTTPHeaderName` wrapper for "X-Secret".
	static var xSecret: Self {
		return .init("X-Secret")
	}
}
