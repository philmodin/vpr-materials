
import Vapor

func routes(_ app: Application) throws {
	// register todo controller routes
	let todoController = TodoController()
	app.get("todos", use: todoController.index)
//	app.post("todos", use: todoController.create)
//	app.delete("todos", ":id", use: todoController.delete)
	try app.group(SecretMiddleware.detect()) { secretGroup in
		secretGroup.post("todos", use: todoController.create)
		secretGroup.delete("todos", ":id", use: todoController.delete)
	}
}
