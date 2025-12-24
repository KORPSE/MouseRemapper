import Foundation

func printUsage() {
    print("""
    Mouse Remapper Daemon for macOS
    
    Usage:
        mouse-remapper [options]
    
    Options:
        --config PATH    Path to config file (default: ~/.config/mouse-remapper/config.json)
        --generate       Generate default config file and exit
        --help           Show this help message
    
    Key Codes Reference:
        Arrow keys: Left=123, Right=124, Up=126, Down=125
        Tab=48, Space=49, Escape=53, Return=36, Delete=51
    """)
}

func parseArguments() -> (configPath: String?, shouldGenerate: Bool, shouldShowHelp: Bool) {
    var configPath: String? = nil
    var shouldGenerate = false
    var shouldShowHelp = false
    
    var i = 1
    while i < CommandLine.arguments.count {
        let arg = CommandLine.arguments[i]
        switch arg {
        case "--config":
            i += 1
            if i < CommandLine.arguments.count {
                configPath = CommandLine.arguments[i]
            }
        case "--generate":
            shouldGenerate = true
        case "--help", "-h":
            shouldShowHelp = true
        default:
            print("Unknown option: \(arg)")
            shouldShowHelp = true
        }
        i += 1
    }
    
    return (configPath, shouldGenerate, shouldShowHelp)
}

// Main execution
let (configPath, shouldGenerate, shouldShowHelp) = parseArguments()

if shouldShowHelp {
    printUsage()
    exit(shouldShowHelp && CommandLine.arguments.count > 1 ? 1 : 0)
}

if shouldGenerate {
    let config = Config.createDefault()
    let path = configPath.map { URL(fileURLWithPath: $0) } ?? ConfigManager.defaultConfigPath
    ConfigManager.saveConfig(config, to: path)
    print("Generated default config at: \(path.path)")
    exit(0)
}

print("=== Mouse Remapper Daemon ===")

let config = ConfigManager.loadConfig(from: configPath)
let remapper = MouseRemapper(config: config)

signal(SIGINT) { _ in
    print("\nReceived SIGINT, shutting down...")
    exit(0)
}

signal(SIGTERM) { _ in
    print("\nReceived SIGTERM, shutting down...")
    exit(0)
}

remapper.start()
