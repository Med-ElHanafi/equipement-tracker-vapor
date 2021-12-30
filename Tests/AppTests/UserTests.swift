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
    
    func test_postUser_isSaved_withAPI() throws {
        let user = User(firstname: "test", lastname: "test", email: "test@email.com", password: "1234567")
        
        try app.test(.POST, usersURI, beforeRequest: { req in
            try req.content.encode(user)
        }, afterResponse: { response in
            let receivedUser = try response.content.decode(User.self)
            XCTAssertEqual(receivedUser.firstname, user.firstname)
            XCTAssertEqual(receivedUser.lastname, user.lastname)
            XCTAssertEqual(receivedUser.email, user.email)
            XCTAssertNotNil(receivedUser.id)
            
            try app.test(.GET, usersURI, afterResponse: { secondResponse in
                let users = try secondResponse.content.decode([User].self)
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users[0].firstname, user.firstname)
                XCTAssertEqual(users[0].lastname, user.lastname)
                XCTAssertEqual(users[0].email, user.email)
                XCTAssertEqual(users[0].id, receivedUser.id)
            })
        })
    }
    
    func test_retrieveSingleUser_fromAPI_withOneUserCreated_returnCorrectUser() throws {
        let user = try User.create(on: app.db)
        
        try app.test(.GET, "\(usersURI)\(user.id!)", afterResponse: { response in
            let receivedUser = try response.content.decode(User.self)
            XCTAssertEqual(receivedUser.firstname, user.firstname)
            XCTAssertEqual(receivedUser.lastname, user.lastname)
            XCTAssertEqual(receivedUser.email, user.email)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }
    
    func test_updateCreatedUser_withAPI_returnCorrectUpdatedUser() throws {
        let user = try User.create(on: app.db)
        
        let updatedUser = User(id: user.id, firstname: "updated", lastname: "updated", email: "updated@test.com", password: "update")
        
        try app.test(.PUT, usersURI, beforeRequest: { req in
            try req.content.encode(updatedUser)
        }, afterResponse: { response in
            let receivedUser = try response.content.decode(User.self)
            XCTAssertEqual(receivedUser.firstname, updatedUser.firstname)
            XCTAssertEqual(receivedUser.lastname, updatedUser.lastname)
            XCTAssertEqual(receivedUser.email, updatedUser.email)
            XCTAssertEqual(receivedUser.id, updatedUser.id)
            
            XCTAssertNotEqual(receivedUser.firstname, user.firstname)
            XCTAssertNotEqual(receivedUser.lastname, user.lastname)
            XCTAssertNotEqual(receivedUser.email, user.email)
            
            try app.test(.GET, "\(usersURI)\(updatedUser.id!)", afterResponse: { response in
                let receivedUser = try response.content.decode(User.self)
                XCTAssertEqual(receivedUser.firstname, updatedUser.firstname)
                XCTAssertEqual(receivedUser.lastname, updatedUser.lastname)
                XCTAssertEqual(receivedUser.email, updatedUser.email)
                XCTAssertEqual(receivedUser.id, updatedUser.id)
            })
        })
    }
    
    func test_searchUserByFirstname_withOneCreatedUser_returnCorrectUser() throws {
        let firstname = "test"
        let user = try User.create(firstname: firstname, on: app.db)
        
        try app.test(.GET, "\(usersURI)search?term=\(firstname)", afterResponse: { response in
            let result = try response.content.decode([User].self)
            XCTAssertEqual(result.count, 1)
            
            let receivedUser = try XCTUnwrap(result.first)
            
            XCTAssertEqual(receivedUser.firstname, user.firstname)
            XCTAssertEqual(receivedUser.lastname, user.lastname)
            XCTAssertEqual(receivedUser.email, user.email)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }
}
