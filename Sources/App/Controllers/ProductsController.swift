//
//  File.swift
//  
//
//  Created by Дмитрий Спичаков on 21.02.2023.
//

import Fluent
import Vapor

struct ProductsController: RouteCollection {
    
    // MARK: REG ROUTE
    func boot(routes: Vapor.RoutesBuilder) throws {
        let productsGroup = routes.grouped("products")
        
        productsGroup.get(use: getAllHandler)
        productsGroup.get(":productID", use: getHandler)
        
        let basicMW = User.authenticator() // Auth protection
        let guardMW = User.guardMiddleware()
        let protected = productsGroup.grouped(basicMW, guardMW) // Create protected group
        protected.post(use: createHandler)
        protected.delete(":productID", use: deleteHandler)
        protected.put(":productID", use: updateHandler)
    }
    
    // MARK: CREATE
    func createHandler(_ req: Request) async throws -> Product {
        guard let product =  try? req.content.decode(Product.self) else {
            throw Abort(.custom(code: 499, reasonPhrase: "Не получилось декодировать контент в модель продукта"))
        }
        try await product.save(on: req.db)
        return product
    }
    
    // MARK: GET ALL
    func getAllHandler(_ req: Request) async throws -> [Product] {
        let products = try await Product.query(on: req.db).all()
        return products
    }
    
    // MARK: GET WITH ID
    func getHandler(_ req: Request) async throws -> Product {
        guard let product = try await Product.find(req.parameters.get("productID"), on: req.db) // "productID" - dynamic parametr
        else { throw Abort(.notFound)}
        return product
    }
    
    // MARK: DELETE WITH ID
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let product = try await Product.find(req.parameters.get("productID"), on: req.db) else {throw Abort(.notFound)}
        try await product.delete(on: req.db)
        return .ok
    }
    
    // MARK: UPDATE WITH ID
    func updateHandler(_ req: Request) async throws -> Product {
        guard let product = try await Product.find(req.parameters.get("productID"), on: req.db) else {throw Abort(.notFound)}
        let updatedProduct = try req.content.decode(Product.self)
        product.title = updatedProduct.title
        product.price = updatedProduct.price
        product.image = updatedProduct.image
        product.description = updatedProduct.description
        product.category = updatedProduct.category
        try await product.save(on: req.db)
        return product
    }
    
}
