import XCTest

@MainActor
final class PinReorderMotionUITests: XCTestCase {
    func testPinningLowerConversationReordersCleanly() throws {
        let app = XCUIApplication()
        app.launch()

        let initialSignUp = app.buttons["Sign Up"].firstMatch
        XCTAssertTrue(initialSignUp.waitForExistence(timeout: 3))
        initialSignUp.tap()

        let nameField = app.textFields["Name"].firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))

        let createProfile = app.buttons["Sign Up"].firstMatch
        createProfile.tap()

        let nora = app.staticTexts["Nora Bennett"].firstMatch
        XCTAssertTrue(nora.waitForExistence(timeout: 5))

        let row = app.cells.containing(
            .staticText,
            identifier: "Nora Bennett"
        ).firstMatch
        XCTAssertTrue(row.exists)
        row.swipeRight()

        let pin = app.buttons["Pin"].firstMatch
        XCTAssertTrue(pin.waitForExistence(timeout: 2))
        pin.tap()

        let leo = app.staticTexts["Leo Martins"].firstMatch
        XCTAssertTrue(leo.waitForExistence(timeout: 2))
        XCTAssertLessThan(nora.frame.minY, leo.frame.minY)
    }
}
