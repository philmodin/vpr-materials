import Fluent
import Vapor

struct UsersController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let usersRoute = routes.grouped("api", "users")
		usersRoute.get(use: getAllHandler)
		usersRoute.get(":userID", use: getHandler)
		usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
		let basicAuthMiddleware = User.authenticator()
		let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
		basicAuthGroup.post("login", use: loginHandler)
		
		let tokenAuthMiddleware = Token.authenticator()
		let guardAuthMiddleware = User.guardMiddleware()
		let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
		tokenAuthGroup.post(use: createHandler)
		tokenAuthGroup.delete(":userID", use: deleteHandler)
		tokenAuthGroup.post(":userID", "restore", use: restoreHandler)
		tokenAuthGroup.delete(":userID", "force", use: forceDeleteHandler)
	}
	
	func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
		let user = try req.content.decode(User.self)
		user.password = try Bcrypt.hash(user.password)
		return user.save(on: req.db).map { user.convertToPublic() }
	}
	
	func getAllHandler(_ req: Request) -> EventLoopFuture<[User.Public]> {
		User.query(on: req.db).all().convertToPublic()
	}
	
	func getHandler(_ req: Request) -> EventLoopFuture<User.Public> {
		User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).convertToPublic()
	}
	
	func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
		User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
			user.$acronyms.get(on: req.db)
		}
	}
	
	func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
		let user = try req.auth.require(User.self)
		let token = try Token.generate(for: user)
		return token.save(on: req.db).map { token }
	}
	
	func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
		let requestUser = try req.auth.require(User.self)
		guard requestUser.userType == .admin else {
			throw Abort(.forbidden)
		}
		return User.find(req.parameters.get("userID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { user in
				user.delete(on: req.db).transform(to: .noContent)
			}
	}
	
	func restoreHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
		let requestUser = try req.auth.require(User.self)
		guard requestUser.userType == .admin else {
			throw Abort(.forbidden)
		}
		let userID = try req.parameters.require("userID", as: UUID.self)
		return User.query(on: req.db)
			.withDeleted()
			.filter(\.$id == userID)
			.first()
			.unwrap(or: Abort(.notFound))
			.flatMap { user in
				user.restore(on: req.db).transform(to: .ok)
			}
	}
	
	func forceDeleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
		let requestUser = try req.auth.require(User.self)
		guard requestUser.userType == .admin else {
			throw Abort(.forbidden)
		}
		return User.find(req.parameters.get("userID"), on: req.db)
			.unwrap(or: Abort(.notFound))
			.flatMap { user in
				user.delete(force: true, on: req.db)
					.transform(to: .noContent)
			}
	}
}
