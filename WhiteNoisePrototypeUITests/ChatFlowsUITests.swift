import XCTest

@MainActor
final class ChatFlowsUITests: XCTestCase {
    private lazy var app: XCUIApplication = {
        let application = XCUIApplication()
        application.launchArguments = ["-ui-testing-chats"]
        application.launch()
        XCTAssertTrue(application.buttons["chats.profile"].waitForExistence(timeout: 8))
        return application
    }()

    override func setUp() {
        continueAfterFailure = false
    }

    func testDirectSendPersistsAndUpdatesRowPreview() {
        openChat("maya-chen")
        let composer = app.textFields["conversation.composer"]
        XCTAssertTrue(composer.waitForExistence(timeout: 5))
        composer.tap()
        composer.typeText("A message from the UI test")
        app.buttons["conversation.send"].tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "A message from the UI test")
        ).firstMatch.waitForExistence(timeout: 3))

        app.navigationBars.buttons.firstMatch.tap()
        let row = locateChat("maya-chen")
        XCTAssertTrue(row.label.contains("A message from the UI test"))

        row.tap()
        XCTAssertTrue(app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "A message from the UI test")
        ).firstMatch.waitForExistence(timeout: 3))
    }

    func testNewGroupCreatesAdminAndInitialEvent() {
        app.buttons["chats.new"].tap()
        XCTAssertTrue(app.navigationBars["New Chat"].waitForExistence(timeout: 3))
        app.buttons["New Group"].tap()
        XCTAssertTrue(app.navigationBars["New Group"].waitForExistence(timeout: 3))

        let peopleSearch = app.searchFields["Search People"]
        XCTAssertTrue(peopleSearch.waitForExistence(timeout: 3))
        peopleSearch.tap()
        peopleSearch.typeText("Maya Chen")
        button(containing: "Maya Chen").tap()
        peopleSearch.tap()
        app.buttons["Clear text"].tap()
        peopleSearch.typeText("Elias Moreno")
        button(containing: "Elias Moreno").tap()
        if app.buttons["close"].exists {
            app.buttons["close"].tap()
        }
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 3))
        app.buttons["Continue"].tap()

        let name = app.textFields["new-group.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText("UI Test Walks")
        app.buttons["Create Group"].tap()

        XCTAssertTrue(app.staticTexts["UI Test Walks"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["You created the group."].waitForExistence(timeout: 3))
        app.buttons["conversation.info"].tap()
        XCTAssertTrue(app.staticTexts["Admin"].waitForExistence(timeout: 3))
    }

    func testMayaRetryReplyReactDeleteAndSearch() {
        openChat("maya-chen")

        let retry = app.buttons["Not sent. Retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 3))
        retry.tap()
        XCTAssertFalse(retry.exists)

        app.buttons["Search"].tap()
        let search = app.searchFields["Messages"]
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText("Weekend Notes")
        XCTAssertTrue(app.staticTexts["Weekend Notes.pdf"].firstMatch.waitForExistence(timeout: 3))
        let searchResult = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "message-search-result.")
        ).firstMatch
        XCTAssertTrue(searchResult.waitForExistence(timeout: 3))
        searchResult.tap()

        let incoming = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@ AND label CONTAINS %@", "Maya Chen", "Weekend Notes.pdf")
        ).firstMatch
        XCTAssertTrue(incoming.waitForExistence(timeout: 3))
        incoming.press(forDuration: 1)
        app.buttons["Reply"].tap()
        XCTAssertTrue(app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Replying to")
        ).firstMatch.waitForExistence(timeout: 3))

        incoming.press(forDuration: 1)
        app.buttons["React"].tap()
        app.buttons["🦫"].tap()
        XCTAssertTrue(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "🦫")
        ).firstMatch.waitForExistence(timeout: 3))

        let composer = app.textFields["conversation.composer"]
        composer.tap()
        composer.typeText("Delete this message")
        app.buttons["conversation.send"].tap()
        let sent = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Delete this message")
        ).firstMatch
        XCTAssertTrue(sent.waitForExistence(timeout: 3))
        sent.press(forDuration: 1)
        app.buttons["Delete"].tap()
        app.buttons["Delete Message"].tap()
        XCTAssertTrue(app.staticTexts["You deleted this message."].waitForExistence(timeout: 3))
    }

    func testWeekendGroupMetadataAndMemberManagement() {
        openChat("weekend-walks")
        app.buttons["conversation.info"].tap()
        XCTAssertTrue(app.navigationBars["Group Info"].waitForExistence(timeout: 3))
        reveal(app.buttons["Edit Group"]).tap()
        let name = app.textFields["edit-group.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30))
        name.typeText("Saturday Walks")
        app.buttons["Save"].tap()
        XCTAssertTrue(revealFromTop(app.staticTexts["Saturday Walks"].firstMatch).exists)

        reveal(app.buttons["Add People"]).tap()
        let peopleSearch = app.searchFields["Search People"]
        XCTAssertTrue(peopleSearch.waitForExistence(timeout: 3))
        peopleSearch.tap()
        peopleSearch.typeText("Avery Stone")
        button(containing: "Avery Stone").tap()
        if app.buttons["close"].exists {
            app.buttons["close"].tap()
        }
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 3))
        app.buttons["Add"].tap()
        let avery = app.buttons["group-member.avery-stone"]
        XCTAssertTrue(reveal(avery).exists)

        reveal(app.buttons["group-member.maya-chen"]).tap()
        XCTAssertTrue(app.navigationBars["Group Member"].waitForExistence(timeout: 3))
        reveal(app.buttons["Make Admin"]).tap()
        app.sheets.buttons["Make Admin"].tap()
        XCTAssertTrue(app.staticTexts["Admin"].waitForExistence(timeout: 3))
        app.buttons["Remove Admin"].tap()
        app.sheets.buttons["Remove Admin"].tap()

        app.navigationBars.buttons.firstMatch.tap()
        reveal(avery).tap()
        reveal(app.buttons["Remove from Group"]).tap()
        app.sheets.buttons["Remove from Group"].tap()
        XCTAssertTrue(app.navigationBars["Group Info"].waitForExistence(timeout: 3))
    }

    func testOnlyAdminCannotLeave() {
        openChat("weekend-walks")
        app.buttons["conversation.info"].tap()
        reveal(app.buttons["Leave Group"]).tap()
        XCTAssertTrue(app.alerts["Can’t Leave Group"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts[
            "You’re the only admin in this group. Make another member an admin before you leave."
        ].exists)
        app.alerts.buttons["OK"].tap()
    }

    func testRemovingFinalChatRelayDisablesAndAddingRestoresComposer() {
        openChat("maya-chen")
        app.buttons["conversation.info"].tap()
        app.buttons["Chat Relays"].tap()

        for _ in 0..<3 {
            let remove = app.buttons.matching(
                NSPredicate(format: "label BEGINSWITH %@", "Remove wss://")
            ).firstMatch
            XCTAssertTrue(remove.waitForExistence(timeout: 2))
            remove.tap()
            app.buttons["Remove Relay"].tap()
        }

        app.navigationBars.buttons.firstMatch.tap()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["Check Chat Relays"].waitForExistence(timeout: 3))
        app.buttons["Check Chat Relays"].tap()
        let input = app.textFields["chat-relays.input"]
        input.tap()
        input.typeText("wss://restored.example.com")
        app.buttons["Add Relay"].tap()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.textFields["conversation.composer"].waitForExistence(timeout: 3))
    }

    func testVoiceReleaseSendsAndSlideCancelDoesNot() {
        openChat("maya-chen")
        let voiceMessages = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "Voice message")
        )
        let initialCount = voiceMessages.count
        let voice = app.descendants(matching: .any)["conversation.voice"]
        XCTAssertTrue(voice.waitForExistence(timeout: 3))
        voice.press(forDuration: 0.6)
        XCTAssertEqual(voiceMessages.count, initialCount + 1)

        let destination = app.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@", "Add Attachment")
        ).firstMatch
        XCTAssertTrue(destination.waitForExistence(timeout: 3))
        voice.press(forDuration: 0.6, thenDragTo: destination)
        XCTAssertEqual(voiceMessages.count, initialCount + 1)
    }

    private func openChat(_ id: String) {
        let row = locateChat(id)
        row.tap()
        XCTAssertTrue(app.textFields["conversation.composer"].waitForExistence(timeout: 5))
    }

    private func locateChat(_ id: String) -> XCUIElement {
        let row = app.cells["chat.\(id)"]
        if !row.exists {
            app.buttons["Search Chats"].tap()
            let search = app.searchFields["Search Chats"]
            search.typeText(id == "weekend-walks" ? "Weekend Walks" : "Maya Chen")
        }
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        return row
    }

    private func button(containing text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    @discardableResult
    private func reveal(_ element: XCUIElement) -> XCUIElement {
        for _ in 0..<10 {
            if element.exists, element.isHittable { return element }
            app.swipeUp()
        }
        XCTAssertTrue(element.exists)
        XCTAssertTrue(element.isHittable)
        return element
    }

    @discardableResult
    private func revealFromTop(_ element: XCUIElement) -> XCUIElement {
        for _ in 0..<8 {
            if element.exists, element.isHittable { return element }
            app.swipeDown()
        }
        XCTAssertTrue(element.exists)
        XCTAssertTrue(element.isHittable)
        return element
    }
}
