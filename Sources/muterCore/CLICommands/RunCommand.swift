import Commandant
import Result
import Curry
import Foundation

@available(OSX 10.13, *)
public struct RunCommand: CommandProtocol {

    public typealias Options = RunCommandOptions
    public typealias ClientError = MuterError
    public let verb: String = "run"
    public let function: String = "Performs mutation testing for the Swift project contained within the current directory."

    private let delegate: RunCommandIODelegate
    private let currentDirectory: String
    public init(delegate: RunCommandIODelegate = RunCommandDelegate(),
                currentDirectory: String = FileManager.default.currentDirectoryPath) {
        self.delegate = delegate
        self.currentDirectory = currentDirectory
    }

    public func run(_ options: Options) -> Result<(), ClientError> {
        guard let configuration = delegate.loadConfiguration() else {
            return .failure(.configurationError)
        }

        delegate.backupProject(in: currentDirectory)

        let reporter: Reporter = options.shouldOutputJSON ? jsonReport(from:) : xcodeReport(from:)

        let report = delegate.executeTesting(using: configuration, reporter: reporter)

//        if let report = report,
//            options.shouldOutputJSON {
//            delegate.saveReport(report, to: currentDirectory)
//        }

        report.flatMap { [delegate, currentDirectory] in
            if options.shouldOutputJSON { delegate.saveReport($0, to: currentDirectory) }
            if options.shouldOutputXcode {  printMessage($0.description) }
        }

        return .success(())
    }
}

public struct RunCommandOptions: OptionsProtocol {
    public typealias ClientError = MuterError

    let shouldOutputJSON: Bool
    let shouldOutputXcode: Bool
    public init(shouldOutputJSON: Bool, shouldOutputXcode: Bool) {
        self.shouldOutputJSON = shouldOutputJSON
        self.shouldOutputXcode = shouldOutputXcode
    }

    public static func evaluate(_ mode: CommandMode) -> Result<RunCommandOptions, CommandantError<ClientError>>  {
        return curry(self.init)
            <*> mode <| Option(key: "output-json", defaultValue: false, usage: "Whether or not Muter should output a json report after it's finished running.")
            <*> mode <| Option(key: "output-xcode", defaultValue: false, usage: "Whether or not Muter should output to Xcode after it's finished running.")
    }
}
