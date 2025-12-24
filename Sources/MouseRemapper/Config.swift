import Foundation

struct Config: Codable {
    var reverseMouseScroll: Bool = true
    var reverseTrackpadScroll: Bool = false
    var buttonMappings: [ButtonMapping] = []
    
    struct ButtonMapping: Codable {
        var button: UInt32
        var action: ActionConfig
    }
    
    struct ActionConfig: Codable {
        var type: String  // "key", "mouse", "passthrough"
        var keyCode: UInt16?
        var modifiers: [String]?  // ["control", "shift", "command", "option"]
        var mouseButton: UInt32?
    }
    
    static func createDefault() -> Config {
        return Config(
            reverseMouseScroll: true,
            reverseTrackpadScroll: false,
            buttonMappings: [
                ButtonMapping(
                    button: 3,
                    action: ActionConfig(
                        type: "key",
                        keyCode: 124,
                        modifiers: ["control"],
                        mouseButton: nil
                    )
                ),
                ButtonMapping(
                    button: 4,
                    action: ActionConfig(
                        type: "key",
                        keyCode: 123,
                        modifiers: ["control"],
                        mouseButton: nil
                    )
                )
            ]
        )
    }
}
