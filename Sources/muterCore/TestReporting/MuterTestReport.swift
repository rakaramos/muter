import Foundation
import SwiftSyntax

typealias FileName = String

public func jsonReport(from outcomes: [MutationTestOutcome]) -> String {
    let globalMutationScore = mutationScore(from: outcomes.map { $0.testSuiteOutcome })
    let totalAppliedMutationOperators = outcomes.count
    let fileReports = mutationScoreOfFiles(from: outcomes)
        .sorted(by: ascendingFilenameOrder)
        .map { mutationScoreByFilePath in
            let filePath = mutationScoreByFilePath.key
            let fileName = URL(fileURLWithPath: filePath).lastPathComponent
            let mutationScore = mutationScoreByFilePath.value
            let appliedMutations = outcomes
                .include { $0.filePath == mutationScoreByFilePath.key }
                .map{ MuterTestReport.AppliedMutationOperator(id: $0.appliedMutation, position: $0.position, testSuiteOutcome: $0.testSuiteOutcome) }

            return (fileName, filePath, mutationScore, appliedMutations)
        }
        .map(MuterTestReport.FileReport.init(fileName:filePath:mutationScore:appliedOperators:))

    let finishedRunningMessage = "Muter finished running!\n\n"
    let appliedMutationsMessage = """
    --------------------------
    Applied Mutation Operators
    --------------------------

    These are all of the ways that Muter introduced changes into your code.

    In total, Muter applied \(totalAppliedMutationOperators) mutation operators.

    \(generateAppliedMutationsCLITable(from: fileReports).description)



    """

    let coloredGlobalScore = coloredMutationScore(for: globalMutationScore, appliedTo: "\(globalMutationScore)/100")
    let mutationScoreMessage = "Mutation Score of Test Suite (higher is better)".bold + ": \(coloredGlobalScore)"
    let mutationScoresMessage = """
    --------------------
    Mutation Test Scores
    --------------------

    These are the mutation scores for your test suite, as well as the files that had mutants introduced into them.

    Mutation scores ignore build & runtime errors.

    \(mutationScoreMessage)

    \(generateMutationScoresCLITable(from: fileReports).description)
    """

    let description = finishedRunningMessage + appliedMutationsMessage + mutationScoresMessage

    // I'm sorry
    struct JSONReport: Codable {
        let globalMutationScore: Int
        let totalAppliedMutationOperators: Int
        let fileReports: [MuterTestReport.FileReport]
        let description: String

        init(
            globalMutationScore: Int,
            totalAppliedMutationOperators: Int,
            fileReports: [MuterTestReport.FileReport],
            description: String
        ) {
            self.globalMutationScore = globalMutationScore
            self.totalAppliedMutationOperators = totalAppliedMutationOperators
            self.fileReports = fileReports
            self.description = description
        }
    }

    let report = JSONReport(
        globalMutationScore: globalMutationScore,
        totalAppliedMutationOperators: totalAppliedMutationOperators,
        fileReports: fileReports,
        description: description
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
        let encoded = try encoder.encode(report)
        return String(data: encoded, encoding: .utf8) ?? ""
    } catch {
        return """
            Muter was unable to encode its report

            If you can reproduce this, please consider filing a bug
            at https://github.com/SeanROlszewski/muter

            Please include the following in the bug report:
            *********************
            \(error)
            """
    }
}

public struct MuterTestReport {
    let globalMutationScore: Int
    let totalAppliedMutationOperators: Int
    let fileReports: [FileReport]
    let reporter: ([MutationTestOutcome]) -> String
    let outcomes: [MutationTestOutcome]

    public init(from outcomes: [MutationTestOutcome] = [], reporter: @escaping ([MutationTestOutcome]) -> String) {
        self.outcomes = outcomes
        self.reporter = reporter
        globalMutationScore = mutationScore(from: outcomes.map { $0.testSuiteOutcome })
        totalAppliedMutationOperators = outcomes.count
        fileReports = mutationScoreOfFiles(from: outcomes)
            .sorted(by: ascendingFilenameOrder)
            .map { mutationScoreByFilePath in
                let filePath = mutationScoreByFilePath.key
                let fileName = URL(fileURLWithPath: filePath).lastPathComponent
                let mutationScore = mutationScoreByFilePath.value
                let appliedMutations = outcomes
                    .include { $0.filePath == mutationScoreByFilePath.key }
                    .map{ AppliedMutationOperator(id: $0.appliedMutation, position: $0.position, testSuiteOutcome: $0.testSuiteOutcome) }

                return (fileName, filePath, mutationScore, appliedMutations)
            }
            .map(FileReport.init(fileName:filePath:mutationScore:appliedOperators:))
    }
    
    public struct FileReport: Codable, Equatable {
        let fileName: FileName
        let filePath: String
        let mutationScore: Int
        let appliedOperators: [AppliedMutationOperator]
    }
    
    public struct AppliedMutationOperator: Codable, Equatable {
        let id: MutationOperator.Id
        let position: AbsolutePosition
        let testSuiteOutcome: TestSuiteOutcome
    }
}

extension MuterTestReport: Equatable {
    public static func == (lhs: MuterTestReport, rhs: MuterTestReport) -> Bool {
        return lhs.globalMutationScore == rhs.globalMutationScore
            && lhs.totalAppliedMutationOperators == rhs.totalAppliedMutationOperators
            && lhs.fileReports == rhs.fileReports
    }
}
//extension MuterTestReport: Codable {}

extension MuterTestReport: CustomStringConvertible {
    public var description: String {
        return reporter(outcomes)
    }
}

// MARK - Mutation Score Calculation

func mutationScore(from testResults: [TestSuiteOutcome]) -> Int {
    guard testResults.count > 0 else {
        return -1
    }

    let numberOfFailures = Double(testResults.count { $0 == .failed || $0 == .runtimeError })
    let totalResults = Double(testResults.count { $0 != .buildError })
    return Int((numberOfFailures / totalResults) * 100.0)
}

func mutationScoreOfFiles(from outcomes: [MutationTestOutcome]) -> [String: Int] {
    var mutationScores: [String: Int] = [:]

    let filePaths = outcomes.map { $0.filePath }.deduplicated()
    for filePath in filePaths {
        let testSuiteResults = outcomes.include { $0.filePath == filePath }.map { $0.testSuiteOutcome }
        mutationScores[filePath] = mutationScore(from: testSuiteResults)
    }

    return mutationScores
}

private func ascendingFilenameOrder(lhs: (String, Int), rhs: (String, Int)) -> Bool {
    return lhs.0 < rhs.0
}
