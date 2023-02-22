//
//  File.swift
//  
//
//  Created by Дмитрий Спичаков on 22.02.2023.
//

import Fluent
import Vapor

struct CreateUser: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("login", .string, .required)
            .field("password", .string, .required)
            .field("role", .string, .required)
            .field("profilePicture", .string)
            .unique(on: "login")
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
       try await database.schema("users").delete()
    }
}
