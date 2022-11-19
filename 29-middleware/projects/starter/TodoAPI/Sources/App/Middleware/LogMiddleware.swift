
import Vapor

/// Logs all requests that pass through it.
final class LogMiddleware: Middleware {
	func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
		let start = Date()
		return next.respond(to: req).map { res in
			self.log(res, start: start, for: req)
			return res
		}
	}
	
	func log(_ res: Response, start: Date, for req: Request) {
		let reqInfo = "\(req.method.string) \(req.url.path)"
		let resInfo = "\(res.status.code) " + "\(res.status.reasonPhrase)"
		let time = Date().timeIntervalSince(start).readableMilliseconds
		req.logger.info("\(reqInfo) -> \(resInfo) [\(time)]")
	}
}

extension TimeInterval {
	/// Converts the time internal to readable milliseconds format, i.e., "3.4ms"
	var readableMilliseconds: String {
		let string = (self * 1000).description
		// include one decimal point after the zero
		let endIndex = string.index(string.firstIndex(of: ".")!, offsetBy: 2)
		let trimmed = string[string.startIndex..<endIndex]
		return .init(trimmed) + "ms"
	}
}
