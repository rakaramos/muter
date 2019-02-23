@testable import muterCore
import Foundation

class RunCommandIODelegateSpy: Spy, RunCommandIODelegate {
    private(set) var methodCalls: [String] = []
    private(set) var directories: [String] = []
    private(set) var configurations: [MuterConfiguration] = []
    private(set) var reports: [MuterTestReport] = []
    private(set) var reporters: [Reporter] = []
    public var reportToReturn: MuterTestReport?
    public var configurationToReturn: MuterConfiguration!

    func loadConfiguration() -> MuterConfiguration? {
        methodCalls.append(#function)
        return configurationToReturn
    }

    func backupProject(in directory: String) {
        methodCalls.append(#function)
        directories.append(directory)
    }

    func executeTesting(using configuration: MuterConfiguration, reporter: @escaping Reporter) -> MuterTestReport? {
        methodCalls.append(#function)
        configurations.append(configuration)
        reporters.append(reporter)
        return reportToReturn
    }

    func saveReport(_ report: MuterTestReport, to directory: String) {
        methodCalls.append(#function)
        reports.append(report)
        directories.append(directory)
    }
}
