//
//  File.swift
//  
//
//  Created by Дмитрий Спичаков on 22.02.2023.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let usersGroup = routes.grouped("users")
        usersGroup.post(use: createHandler)
        usersGroup.get(use: getAllHandler)
        usersGroup.get(":id", use: getHandler)

        usersGroup.post("auth", use: authHandler)

    }
    
    func createHandler(_ req: Request) async throws -> User.Public {
        let user = try req.content.decode(User.self)
        // Hash password with bcrypt
        user.password = try Bcrypt.hash(user.password)
        try await user.save(on: req.db)
        return user.convertToPublic() // return without hashable password
    }
    
    func getAllHandler(_ req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        let publics = users.map { user in
            user.convertToPublic()
        }
        return publics
    }
    
    func getHandler(_ req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {throw Abort(.notFound)}
        return user.convertToPublic()
    }
    
    // Auth func
    func authHandler(_ req: Request) async throws -> User.Public {
        let userDTO = try req.content.decode(AuthUserDTO.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter("login", .equal, userDTO.login) // search user with this login
            .first() else {throw Abort(.notFound)}
        
        let isPasswordEqual = try Bcrypt.verify(userDTO.password, created: user.password) // Return Bool
        
        guard isPasswordEqual else { throw Abort(.unauthorized)}
        
        return user.convertToPublic()
    }
    
}

struct AuthUserDTO: Content {
    let login: String
    var password: String
}
