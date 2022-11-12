
import Foundation
import UIKit

enum AuthResult {
	case success
	case failure
}

class Auth {
	static let keychainKey = "TIL-API-KEY"
	
	var token: String? {
		get {
			Keychain.load(key: Auth.keychainKey)
		}
		set {
			if let newToken = newValue {
				Keychain.save(key: Auth.keychainKey, data: newToken)
			} else {
				Keychain.delete(key: Auth.keychainKey)
			}
		}
	}
	
	func logout() {
		token = nil
		DispatchQueue.main.async {
			guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
			let rootController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigation")
			applicationDelegate.window?.rootViewController = rootController
		}
	}
	
	func login(username: String, password: String, completion: (@escaping (AuthResult) -> Void)) {
		let path = "http://localhost:8080/api/users/login"
		guard let url = URL(string: path) else { fatalError("Failed to convert URL") }
		guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else { fatalError("Failed to encode credentails") }
		var loginRequest = URLRequest(url: url)
		loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
		loginRequest.httpMethod = "POST"
		let dataTask = URLSession.shared.dataTask(with: loginRequest) { data, response, _ in
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
				completion(.failure)
				return
			}
			do {
				let token = try JSONDecoder().decode(Token.self, from: jsonData)
				self.token = token.value
				completion(.success)
			} catch {
				completion(.failure)
			}
		}
		dataTask.resume()
	}
}
