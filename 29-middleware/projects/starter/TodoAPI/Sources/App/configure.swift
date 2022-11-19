
import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
	app.middleware.use(LogMiddleware())
	// Configure fluent
	app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
	app.migrations.add(CreateTodo())
	
	try app.autoMigrate().wait()
	
	// Register routes
	try routes(app)
}
