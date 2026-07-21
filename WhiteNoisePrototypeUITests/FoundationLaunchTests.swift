import XCTest

@MainActor
final class FoundationLaunchTests: XCTestCase {
    func testFoundationScaffoldLaunches() {
        let app = XCUIApplication()
        app.launchArguments = ["-WNUITesting", "-WNScenario", "onboarding.welcome.default"]
        app.launch()

        XCTAssertEqual(app.state, .runningForeground)
    }
}
