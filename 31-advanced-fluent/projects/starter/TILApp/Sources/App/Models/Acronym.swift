
import Vapor
import Fluent

final class Acronym: Model {
	static let schema = "acronyms"
	
	@ID
	var id: UUID?
	
	@Field(key: "short")
	var short: String
	
	@Field(key: "long")
	var long: String
	
	@Parent(key: "userID")
	var user: User
	
	@Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
	var categories: [Category]
	
	@Timestamp(key: "created_at", on: .create)
	var createdAt: Date?
	
	@Timestamp(key: "updated_at", on: .update)
	var updatedAt: Date?
	
	init() {}
	
	init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
		self.id = id
		self.short = short
		self.long = long
		self.$user.id = userID
	}
}

extension Acronym: Content {}
