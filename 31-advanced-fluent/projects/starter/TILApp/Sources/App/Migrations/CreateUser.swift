
import Fluent

struct CreateUser: Migration {
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.enum("userType")
			.case("admin")
			.case("standard")
			.case("restricted")
			.create()
			.flatMap { userType in
				database.schema("users")
					.id()
					.field("name", .string, .required)
					.field("username", .string, .required)
					.field("password", .string, .required)
					.field("deleted_at", .datetime)
					.field("userType", userType, .required)
					.unique(on: "username")
					.create()
			}
		
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema("users").delete()
	}
}
