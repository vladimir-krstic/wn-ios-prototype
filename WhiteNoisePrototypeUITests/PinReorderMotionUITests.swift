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

        let nora = app.cells["chat.nora-bennett"]
        XCTAssertTrue(nora.waitForExistence(timeout: 5))
        nora.swipeRight()

        let pin = app.buttons["Pin"].firstMatch
        XCTAssertTrue(pin.waitForExistence(timeout: 2))
        pin.tap()

        let leo = app.cells["chat.leo-martins"]
        XCTAssertTrue(leo.waitForExistence(timeout: 2))
        XCTAssertLessThan(nora.frame.minY, leo.frame.minY)
    }
}
