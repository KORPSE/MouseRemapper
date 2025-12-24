import Cocoa
import CoreGraphics

class MouseRemapper {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let config: Config
    private let eventHandler: EventHandler
    
    init(config: Config) {
        self.config = config
        self.eventHandler = EventHandler(config: config)
    }
    
    func start() {
        guard checkAccessibilityPermissions() else {
            print("ERROR: Accessibility permissions not granted!")
            print("Please grant accessibility access in System Preferences > Privacy & Security > Accessibility")
            exit(1)
        }
        
        let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                       (1 << CGEventType.leftMouseUp.rawValue) |
                       (1 << CGEventType.rightMouseDown.rawValue) |
                       (1 << CGEventType.rightMouseUp.rawValue) |
                       (1 << CGEventType.otherMouseDown.rawValue) |
                       (1 << CGEventType.otherMouseUp.rawValue) |
                       (1 << CGEventType.scrollWheel.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, userInfo in
                guard let userInfo = userInfo else {
                    return Unmanaged.passRetained(event)
                }
                
                let remapper = Unmanaged<MouseRemapper>.fromOpaque(userInfo).takeUnretainedValue()
                
                if let modifiedEvent = remapper.eventHandler.handleEvent(event) {
                    return Unmanaged.passRetained(modifiedEvent)
                }
                
                return nil
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("ERROR: Failed to create event tap!")
            exit(1)
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        print("Mouse remapper daemon started successfully!")
        print("\nConfiguration:")
        print("  Reverse mouse scroll (Y-axis only): \(config.reverseMouseScroll)")
        print("  Reverse trackpad scroll: \(config.reverseTrackpadScroll)")
        print("\nButton mappings:")
        print(eventHandler.mappingDescription)
        print()
        
        CFRunLoopRun()
    }
    
    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
        CFRunLoopStop(CFRunLoopGetCurrent())
        print("\nMouse remapper daemon stopped")
    }
    
    private func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
}
