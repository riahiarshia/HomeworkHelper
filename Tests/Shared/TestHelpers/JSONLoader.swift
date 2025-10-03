import Foundation

/// Helper class for loading JSON test fixtures
class JSONLoader {
    
    /// Load JSON data from a file in the test bundle
    static func loadJSON(named filename: String, bundle: Bundle = Bundle.main) throws -> Data {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw JSONLoaderError.fileNotFound(filename)
        }
        
        return try Data(contentsOf: url)
    }
    
    /// Load and decode JSON from a file
    static func loadJSON<T: Codable>(named filename: String, as type: T.Type, bundle: Bundle = Bundle.main) throws -> T {
        let data = try loadJSON(named: filename, bundle: bundle)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: data)
    }
    
    /// Create a temporary JSON file for testing
    static func createTemporaryJSONFile(named filename: String, content: Data) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(filename).json")
        try content.write(to: fileURL)
        return fileURL
    }
}

enum JSONLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file '\(filename).json' not found in bundle"
        }
    }
}
