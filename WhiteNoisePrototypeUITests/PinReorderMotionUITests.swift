import XCTest

@MainActor
final class PinReorderMotionUITests: XCTestCase {
    func testPinningLowerConversationReordersCleanly() throws {
        let app = XCUIApplication()
        app.launch()

        let initialSignUp = app.buttons["welcome.sign-up"]
        XCTAssertTrue(initialSignUp.waitForExistence(timeout: 3))
        initialSignUp.tap()

        let nameField = app.textFields["Name"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))

        let createProfile = app.buttons["sign-up.create"]
        XCTAssertTrue(createProfile.waitForExistence(timeout: 3))
        createProfile.tap()

        let hal = app.cells["chat.hal-finney"]
        XCTAssertTrue(hal.waitForExistence(timeout: 5))
        hal.swipeRight()

        let pin = app.buttons["Pin"].firstMatch
        XCTAssertTrue(pin.waitForExistence(timeout: 2))
        pin.tap()

        let judith = app.cells["chat.judith-milhon"]
        XCTAssertTrue(judith.waitForExistence(timeout: 2))
        XCTAssertLessThan(hal.frame.minY, judith.frame.minY)
    }
}
