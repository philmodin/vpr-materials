
import Vapor

extension Request {
	public var pokeAPI: PokeAPI {
		.init(client: self.client, cache: self.cache)
	}
}

/// A simple wrapper around the "pokeapi.co" API.
public final class PokeAPI {
	/// The HTTP client powering this API.
	let client: Client
	let cache: Cache
	
	/// Creates a new `PokeAPI` wrapper from the supplied client and cache.
	init(client: Client, cache: Cache) {
		self.client = client
		self.cache = cache
	}
	
	public func verify(name: String) -> EventLoopFuture<Bool> {
		let name = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		return cache.get(name, as: Bool.self).flatMap { verified in
			if let verified  = verified {
				return self.client.eventLoop.makeSucceededFuture(verified)
			} else {
				return self.uncachedVerify(name: name).flatMap { verified in
					return self.cache.set(name, to: verified).transform(to: verified)
				}
			}
		}
	}
	
	/// Returns `true` if the supplied Pokemon name is real.
	///
	/// - parameter name: The name to verify.
	public func uncachedVerify(name: String) -> EventLoopFuture<Bool> {
		/// Query the PokeAPI.
		return fetchPokemon(named: name).flatMapThrowing { res in
			switch res.status.code {
			case 200..<300:
				/// The API returned 2xx which means this is a real Pokemon name
				return true
			case 404:
				/// The API returned a 404 meaning this Pokemon name was not found.
				return false
			default:
				/// The API returned a 500. Only thing we can do is forward the error.
				throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.status)")
			}
		}
	}
	
	/// Fetches a pokemen with the supplied name from the PokeAPI.
	private func fetchPokemon(named name: String) -> EventLoopFuture<ClientResponse> {
		let name = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		return client.get("https://pokeapi.co/api/v2/pokemon/\(name)")
	}
}
