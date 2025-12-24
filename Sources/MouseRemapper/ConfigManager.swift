import Foundation

class ConfigManager {
    static let defaultConfigPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/mouse-remapper/config.json")
    
    static func loadConfig(from path: String? = nil) -> Config {
        let configPath = path.map { URL(fileURLWithPath: $0) } ?? defaultConfigPath
        
        if !FileManager.default.fileExists(atPath: configPath.path) {
            let defaultConfig = Config.createDefault()
            saveConfig(defaultConfig, to: configPath)
            print("Created default config at: \(configPath.path)")
            return defaultConfig
        }
        
        do {
            let data = try Data(contentsOf: configPath)
            let config = try JSONDecoder().decode(Config.self, from: data)
            print("Loaded config from: \(configPath.path)")
            return config
        } catch {
            print("Error loading config: \(error)")
            print("Using default config")
            return Config.createDefault()
        }
    }
    
    static func saveConfig(_ config: Config, to url: URL) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(config)
            try data.write(to: url)
        } catch {
            print("Error saving config: \(error)")
        }
    }
}
