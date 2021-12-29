@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    let usersURI = "/api/users/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func test_retrieveAllUsers_fromAPI_withOneUserCreated_returnCorrectUser() throws {
        let firstUser = try User.create(firstname: "first", on: app.db)
        
        try app.test(.GET, usersURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 1)
            
            XCTAssertEqual(users[0].id, firstUser.id)
            XCTAssertEqual(users[0].firstname, firstUser.firstname)
            XCTAssertEqual(users[0].lastname, firstUser.lastname)
            XCTAssertEqual(users[0].password, firstUser.password)
        })
    }
    
    func test_retrieveAllUsers_fromAPI_withTwoUsersCreated_returnCorrectUsers() throws {
        var createdUsers = [User]()
        createdUsers.append(try User.create(firstname: "first", on: app.db))
        createdUsers.append(try User.create(firstname: "second", on: app.db))
        
        try app.test(.GET, usersURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            users.forEach {
                XCTAssertTrue(createdUsers.contains($0))
            }
        })
    }
}
