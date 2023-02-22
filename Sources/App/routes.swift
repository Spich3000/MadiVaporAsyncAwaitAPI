import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // Add routes
    try app.register(collection: ProductsController())
    try app.register(collection: UsersController())
    
    app.routes.defaultMaxBodySize = "5Mb" // Max Body size for req
}
