
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
	// uncomment to serve files from /Public folder
	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	app.middleware.use(app.sessions.middleware)
	
	let databaseName: String
	let databasePort: Int
	if (app.environment == .testing) {
		databaseName = "vapor-test"
		if let testPort = Environment.get("DATABASE_PORT") {
			databasePort = Int(testPort) ?? 5433
		} else {
			databasePort = 5433
		}
	} else {
		databaseName = "vapor_database"
		databasePort = 5432
	}
	
	app.databases.use(.postgres(
		hostname: Environment.get("DATABASE_HOST") ?? "localhost",
		port: databasePort,
		username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
		password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
		database: Environment.get("DATABASE_NAME") ?? databaseName
	), as: .psql)
	
	app.migrations.add(CreateUser())
	app.migrations.add(CreateAcronym())
	app.migrations.add(CreateCategory())
	app.migrations.add(CreateAcronymCategoryPivot())
	app.migrations.add(CreateToken())
	app.migrations.add(AddTwitterURLToUser())
	switch app.environment {
	case .development, .testing:
		app.migrations.add(CreateAdminUser())
	default:
		break
	}
	app.migrations.add(MakeCategoriesUnique())
	
	app.logger.logLevel = .debug
	
	try app.autoMigrate().wait()
	
	app.views.use(.leaf)
	
	// register routes
	try routes(app)
}
