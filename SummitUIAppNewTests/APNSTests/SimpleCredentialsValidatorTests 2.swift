import XCTest
@testable import SummitUIAppNew

class SimpleCredentialsValidatorTests: XCTestCase {

    var testNotifications: InjectableNotifications!
    var credentialsValidator: SimpleCredentialsValidator!

    override func setUpWithError() throws {
        testNotifications = InjectableNotifications.forUnitTests()
        credentialsValidator = SimpleCredentialsValidator(injectableNotifications: testNotifications)
    }

    override func tearDownWithError() throws {
        testNotifications = nil
        credentialsValidator = nil
    }

    func testValidUserLogin_expectsUserObjectAndUserLoggedInNotification() {
        let userLoggedInNotificationExpectation = XCTNSNotificationExpectation(name: testNotifications.userLoggedIn)
        let completionCalledExpectation = XCTestExpectation(description: "CrendentialsValidator should call its onCompletion handler")
        credentialsValidator.validate(username: "definedUser", onCompletion: { userOrNil in
            XCTAssertEqual(userOrNil?.username, "definedUser")
            completionCalledExpectation.fulfill()
        })
        wait(for: [completionCalledExpectation, userLoggedInNotificationExpectation], timeout: 3.0)
    }
    
    func testInvalidUser_expectsNilForUserAndNoNotification() {
        let userLoggedInNotificationExpectation = XCTNSNotificationExpectation(name: testNotifications.userLoggedIn)
        userLoggedInNotificationExpectation.isInverted = true
        let completionCalledExpectation = XCTestExpectation(description: "CrendentialsValidator should call its onCompletion handler")
        credentialsValidator.validate(username: nil, onCompletion: { userOrNil in
            XCTAssertNil(userOrNil)
            completionCalledExpectation.fulfill()
        })
        wait(for: [completionCalledExpectation, userLoggedInNotificationExpectation], timeout: 3.0)
    }
}
