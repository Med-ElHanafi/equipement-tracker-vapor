@testable import App
import Fluent

extension User {
  static func create(
    firstname: String = "jhon",
    lastname: String = "doe",
    email: String = "jhon.doe@test.com",
    password: String = "password",
    on database: Database
  ) throws -> User {
    let user = User(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password
    )
    return try user.save(on: database).map{user}.wait()
  }
}

extension User: Hashable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id?.uuidString == rhs.id?.uuidString
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
