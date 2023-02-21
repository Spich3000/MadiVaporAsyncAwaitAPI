//
//  File.swift
//  
//
//  Created by Дмитрий Спичаков on 21.02.2023.
//

import Fluent
import Vapor

struct ProductsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let productsGroup = routes.grouped("products")
        productsGroup.post(use: createHandler)
    }
    
    func createHandler(_ req: Request) async throws -> Product {
        guard let product =  try? req.content.decode(Product.self) else {
            throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель продукта"))
        }
        try await product.save(on: req.db)
        return product
    }
    
    func getAllHandler(_ req: Request) async throws -> [Product] {
        let products = try await Product.query(on: req.db).all()
        return products
    }
    
    
}
