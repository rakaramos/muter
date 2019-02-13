@testable import muterCore
import Foundation

public extension MuterConfiguration {
    public static func fromFixture(at path: String) -> MuterConfiguration? {

        guard let data = FileManager.default.contents(atPath: path),
            let configuration = try? JSONDecoder().decode(MuterConfiguration.self, from: data) else {
                fatalError("Unable to load a valid Muter configuration file from \(path)")
        }
        return configuration
    }
}
