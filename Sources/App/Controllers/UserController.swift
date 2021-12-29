import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let userRoute = routes.grouped("api", "user")
        userRoute.get(":id", use: getHandler)
        userRoute.get(use: getAllHandler)
        userRoute.post(use: createHandler)
        userRoute.put(use: updateHandler)
        userRoute.get("search", use: searchHandler)
    }
    
    func getHandler(req: Request) throws -> EventLoopFuture<User> {
        User.find(
            req.parameters.get("id"),
            on: req.db
        )
        .unwrap(or: Abort(.notFound))
    }
    
    func getAllHandler(req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func createHandler(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
    
    func updateHandler(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return User.find(
            user.id,
            on: req.db
        )
        .unwrap(or: Abort(.notFound))
        .flatMap { u in
            u.firstname = user.firstname
            u.lastname = user.lastname
            u.email = user.email
            return u.save(on: req.db)
        }
        .map { user }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
      guard let searchTerm = req
        .query[String.self, at: "term"] else {
          throw Abort(.badRequest)
      }
      return User.query(on: req.db).group(.or) { or in
          or.filter(\.$lastname == searchTerm)
          or.filter(\.$firstname == searchTerm)
          or.filter(\.$lastname == searchTerm)
      }.all()
    }
}
