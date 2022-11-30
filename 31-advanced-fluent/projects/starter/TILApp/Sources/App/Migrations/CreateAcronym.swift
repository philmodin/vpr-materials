
import Fluent

struct CreateAcronym: Migration {
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema("acronyms")
			.id()
			.field("short", .string, .required)
			.field("long", .string, .required)
			.field("userID", .uuid, .required, .references("users", "id"))
			.field("created_at", .datetime)
			.field("updated_at", .datetime)
			.create()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("acronyms").delete()
	}
}
