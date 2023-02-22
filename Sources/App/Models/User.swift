//
//  File.swift
//  
//
//  Created by Дмитрий Спичаков on 22.02.2023.
//

import Fluent
import Vapor

final class User: Model, Content {
    
    static var schema: String = "users"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "login") var login: String
    @Field(key: "password") var password: String
    @Field(key: "role") var role: String
    @Field(key: "profilePicture") var profilePicture: String?
    
    
    
    final class Public: Content {
        
        var id: UUID?
        var name: String
        var login: String
        var role: String
        var profilePicture: String?
        
        init(id: UUID? = nil, name: String, login: String, role: String, profilePicture: String? = nil) {
            self.id = id
            self.name = name
            self.login = login
            self.role = role
            self.profilePicture = profilePicture
        }
    }
    
    
    init() {}
    
    init(id: UUID? = nil, name: String, login: String, password: String, role: String, profilePicture: String? = nil) {
        self.id = id
        self.name = name
        self.login = login
        self.password = password
        self.role = role
        self.profilePicture = profilePicture
    }
    
}

// Make user authentificatable
extension User: ModelAuthenticatable {
    
    static var usernameKey = \User.$login
    
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

// Create public user (without password) from private user 
extension User {
    func convertToPublic() -> User.Public {
        let pub = User.Public(id: self.id,
                              name: self.name,
                              login: self.login,
                              role: self.role,
                              profilePicture: self.profilePicture)
        return pub
    }
}


enum UserRole: String {
    case officiant = "Officiant"
    case manageri = "Manager"
}
