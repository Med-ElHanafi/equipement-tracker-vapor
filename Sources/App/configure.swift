import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let databaseName: String
    let databasePort: Int
    if (app.environment == .testing) {
      databaseName = Environment.get("TEST_DATABASE_NAME") ?? "vapor_test_database"
      databasePort = Environment.get("TEST_DATABASE_PORT").flatMap(Int.init(_:)) ?? 3307
    } else {
      databaseName = Environment.get("DATABASE_NAME") ?? "vapor_database"
      databasePort = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber
    }
    
    app.databases.use(.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: databaseName,
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)

    app.migrations.add(UserMigration())
    
    app.logger.logLevel = .debug
    
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
