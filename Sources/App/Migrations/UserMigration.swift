import Fluent

struct UserMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("firstname", .string, .required)
            .field("lastname", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
