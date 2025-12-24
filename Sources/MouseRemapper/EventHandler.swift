import CoreGraphics

enum ButtonAction {
    case mouseButton(UInt32)
    case keyCombo(key: CGKeyCode, modifiers: CGEventFlags)
    case passThrough
}

class EventHandler {
    private let config: Config
    private let buttonMap: [UInt32: ButtonAction]
    
    init(config: Config) {
        self.config = config
        self.buttonMap = Self.buildButtonMap(from: config)
    }
    
    private static func buildButtonMap(from config: Config) -> [UInt32: ButtonAction] {
        var map: [UInt32: ButtonAction] = [:]
        
        for mapping in config.buttonMappings {
            switch mapping.action.type {
            case "key":
                if let keyCode = mapping.action.keyCode {
                    let modifiers = parseModifiers(mapping.action.modifiers ?? [])
                    map[mapping.button] = .keyCombo(key: CGKeyCode(keyCode), modifiers: modifiers)
                }
            case "mouse":
                if let mouseButton = mapping.action.mouseButton {
                    map[mapping.button] = .mouseButton(mouseButton)
                }
            case "passthrough":
                map[mapping.button] = .passThrough
            default:
                print("Unknown action type: \(mapping.action.type)")
            }
        }
        
        return map
    }
    
    private static func parseModifiers(_ modifiers: [String]) -> CGEventFlags {
        var flags: CGEventFlags = []
        for mod in modifiers {
            switch mod.lowercased() {
            case "control", "ctrl":
                flags.insert(.maskControl)
            case "shift":
                flags.insert(.maskShift)
            case "command", "cmd":
                flags.insert(.maskCommand)
            case "option", "alt":
                flags.insert(.maskAlternate)
            default:
                print("Unknown modifier: \(mod)")
            }
        }
        return flags
    }
    
    func handleEvent(_ event: CGEvent) -> CGEvent? {
        let type = event.type
        
        if type == .scrollWheel {
            return handleScrollEvent(event)
        }
        
        let buttonNumber = UInt32(event.getIntegerValueField(.mouseEventButtonNumber))
        
        guard let action = buttonMap[buttonNumber] else {
            return event
        }
        
        let isDown = (type == .leftMouseDown || type == .rightMouseDown || type == .otherMouseDown)
        
        switch action {
        case .mouseButton(let mappedButton):
            return remapToMouseButton(event: event, targetButton: mappedButton, isDown: isDown)
        case .keyCombo(let key, let modifiers):
            if isDown {
                sendKeyCombo(key: key, modifiers: modifiers)
            }
            return nil
        case .passThrough:
            return event
        }
    }
    
    private func handleScrollEvent(_ event: CGEvent) -> CGEvent? {
        let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous)
        let isTrackpad = isContinuous != 0
        
        let shouldReverse = isTrackpad ? config.reverseTrackpadScroll : config.reverseMouseScroll
        
        if shouldReverse {
            let deltaY = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
            event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -deltaY)
            
            let pointDeltaY = event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)
            event.setDoubleValueField(.scrollWheelEventPointDeltaAxis1, value: -pointDeltaY)
        }
        
        return event
    }
    
    private func remapToMouseButton(event: CGEvent, targetButton: UInt32, isDown: Bool) -> CGEvent? {
        let newType = eventTypeForButton(targetButton, isDown: isDown)
        
        guard let newEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: newType,
            mouseCursorPosition: event.location,
            mouseButton: CGMouseButton(rawValue: targetButton)!
        ) else {
            return event
        }
        
        newEvent.flags = event.flags
        newEvent.setIntegerValueField(.mouseEventButtonNumber, value: Int64(targetButton))
        
        return newEvent
    }
    
    private func sendKeyCombo(key: CGKeyCode, modifiers: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)
        
        var fixedModifiers = modifiers
        if modifiers.contains(.maskControl) {
            fixedModifiers.insert(.maskSecondaryFn)
        }
        
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true) else {
            return
        }
        
        keyDown.flags = fixedModifiers
        keyDown.post(tap: .cghidEventTap)
        
        usleep(10000)
        
        guard let keyUp = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false) else {
            return
        }
        
        keyUp.flags = fixedModifiers
        keyUp.post(tap: .cghidEventTap)
    }
    
    private func eventTypeForButton(_ button: UInt32, isDown: Bool) -> CGEventType {
        switch button {
        case 0:
            return isDown ? .leftMouseDown : .leftMouseUp
        case 1:
            return isDown ? .rightMouseDown : .rightMouseUp
        default:
            return isDown ? .otherMouseDown : .otherMouseUp
        }
    }
    
    var mappingDescription: String {
        var lines: [String] = []
        for (button, action) in buttonMap.sorted(by: { $0.key < $1.key }) {
            lines.append("  \(buttonName(button)) -> \(actionDescription(action))")
        }
        return lines.joined(separator: "\n")
    }
    
    private func buttonName(_ button: UInt32) -> String {
        switch button {
        case 0: return "Left (0)"
        case 1: return "Right (1)"
        case 2: return "Middle (2)"
        case 3: return "Back (3)"
        case 4: return "Forward (4)"
        default: return "Button \(button)"
        }
    }
    
    private func actionDescription(_ action: ButtonAction) -> String {
        switch action {
        case .mouseButton(let button):
            return "Mouse \(buttonName(button))"
        case .keyCombo(let key, let modifiers):
            var parts: [String] = []
            if modifiers.contains(.maskControl) { parts.append("Ctrl") }
            if modifiers.contains(.maskShift) { parts.append("Shift") }
            if modifiers.contains(.maskAlternate) { parts.append("Option") }
            if modifiers.contains(.maskCommand) { parts.append("Cmd") }
            parts.append(keyName(key))
            return parts.joined(separator: "+")
        case .passThrough:
            return "Pass through"
        }
    }
    
    private func keyName(_ keyCode: CGKeyCode) -> String {
        switch keyCode {
        case 123: return "Left Arrow"
        case 124: return "Right Arrow"
        case 125: return "Down Arrow"
        case 126: return "Up Arrow"
        case 53: return "Escape"
        case 48: return "Tab"
        case 49: return "Space"
        case 51: return "Delete"
        case 36: return "Return"
        default: return "Key \(keyCode)"
        }
    }
}
