//
//  21-01-14-AddTwitterToUser.swift
//  
//
//  Created by Philip Modin on 11/16/22.
//

import Fluent

struct AddTwitterURLToUser: Migration {
	func prepare(on database: Database) -> EventLoopFuture<Void> {
		database.schema(User.v20210113.schemaName)
			.field(User.v20210114.twitterURL, .string)
			.update()
	}
	
	func revert(on database: Database) -> EventLoopFuture<Void> {
		database.schema(User.v20210113.schemaName)
			.deleteField(User.v20210114.twitterURL)
			.update()
	}
}
