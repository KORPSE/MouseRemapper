import XCTest
@testable import MouseRemapper

final class ConfigTests: XCTestCase {
    func testDefaultConfig() {
        let config = Config.createDefault()
        XCTAssertTrue(config.reverseMouseScroll)
        XCTAssertFalse(config.reverseTrackpadScroll)
        XCTAssertEqual(config.buttonMappings.count, 2)
    }
}
