import Commandant
import Result
import Foundation

@available(OSX 10.13, *)
public struct InitCommand: CommandProtocol {
    public typealias Options = NoOptions<MuterError>
    public typealias ClientError = MuterError
    public let verb: String = "init"
    public let function: String = "Creates the configuration file that Muter uses."

    private let directory: String
    public init(directory: String = FileManager.default.currentDirectoryPath) {
        self.directory = directory
    }

    public func run(_ options: Options) -> Result<(), ClientError> {
        let configuration = MuterConfiguration(executable: "absolute path to the executable that runs your tests",
                                               arguments: ["an argument the test runner needs", "another argument the test runner needs"],
                                               excludeList: [])
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try! encoder.encode(configuration)

        FileManager.default.createFile(atPath: "\(self.directory)/muter.conf.json", contents: data, attributes: nil)

        return Result.success(())

    }
}
