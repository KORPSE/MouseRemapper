import Testing
import Foundation
@testable import MouseRemapper

@Test func defaultConfig() {
    let config = Config.createDefault()
    #expect(config.reverseMouseScroll)
    #expect(!config.reverseTrackpadScroll)
    #expect(config.buttonMappings.count == 2)
}

@Test func defaultConfigRoundTripsThroughJSON() throws {
    let original = Config.createDefault()
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(Config.self, from: data)

    #expect(decoded.reverseMouseScroll == original.reverseMouseScroll)
    #expect(decoded.reverseTrackpadScroll == original.reverseTrackpadScroll)
    #expect(decoded.buttonMappings.count == original.buttonMappings.count)
    for (a, b) in zip(decoded.buttonMappings, original.buttonMappings) {
        #expect(a.button == b.button)
        #expect(a.action.type == b.action.type)
        #expect(a.action.keyCode == b.action.keyCode)
        #expect(a.action.modifiers ?? [] == b.action.modifiers ?? [])
        #expect(a.action.mouseButton == b.action.mouseButton)
    }
}

@Test func configDecodesFromLiteralJSON() throws {
    let json = """
    {
      "reverseMouseScroll": false,
      "reverseTrackpadScroll": true,
      "buttonMappings": [
        { "button": 3, "action": { "type": "mouse", "mouseButton": 0 } },
        { "button": 4, "action": { "type": "passthrough" } }
      ]
    }
    """.data(using: .utf8)!

    let config = try JSONDecoder().decode(Config.self, from: json)

    #expect(!config.reverseMouseScroll)
    #expect(config.reverseTrackpadScroll)
    #expect(config.buttonMappings.count == 2)
    #expect(config.buttonMappings[0].action.type == "mouse")
    #expect(config.buttonMappings[0].action.mouseButton == 0)
    #expect(config.buttonMappings[1].action.type == "passthrough")
}

@Test func configManagerLoadsCreatesAndReloadsConfig() throws {
    let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("mouse-remapper-tests-\(UUID().uuidString)")
    let configPath = tmpDir.appendingPathComponent("config.json")
    defer { try? FileManager.default.removeItem(at: tmpDir) }

    let first = ConfigManager.loadConfig(from: configPath.path)
    #expect(FileManager.default.fileExists(atPath: configPath.path))
    #expect(first.buttonMappings.count == Config.createDefault().buttonMappings.count)

    let second = ConfigManager.loadConfig(from: configPath.path)
    #expect(second.reverseMouseScroll == first.reverseMouseScroll)
    #expect(second.buttonMappings.count == first.buttonMappings.count)
}
