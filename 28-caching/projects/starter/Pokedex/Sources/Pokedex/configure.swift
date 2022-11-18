
import Fluent
import FluentSQLiteDriver
import Vapor

/// Called before your application initializes.
public func configure(_ app: Application) throws {
	/// Setup a simple in-memory SQLite database
	app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
	
	/// Configure migrations
	app.migrations.add(CreatePokemon())
	app.migrations.add(CacheEntry.migration)
	
	try app.autoMigrate().wait()
	
	app.caches.use(.fluent)
	/// Register routes
	try routes(app)
}
