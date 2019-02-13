import Quick
import Nimble
import TestingExtensions
@testable import muterCore

class MuterTestReportSpec: QuickSpec {
    override func spec() {
        describe("MuterTestReport") {
            context("when given a nonempty collection of MutationTestOutcomes") {
                it("calculates all its fields as part of its initialization") {

                    let report = MuterTestReport(from: self.exampleMutationTestResults)

                    expect(report.globalMutationScore).to(equal(55))
                    expect(report.totalAppliedMutationOperators).to(equal(9))
                    expect(report.fileReports).to(haveCount(4))

                    expect(report.fileReports).to(contain(MuterTestReport.FileReport(fileName: "file1.swift", mutationScore: 66, appliedOperators: [
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .failed),
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .failed),
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .passed)
                    ])))

                    expect(report.fileReports).to(contain(MuterTestReport.FileReport(fileName: "file2.swift", mutationScore: 100, appliedOperators: [
                        MuterTestReport.AppliedMutationOperator(id: .removeSideEffects, position: .firstPosition, testSuiteOutcome: .failed),
                        MuterTestReport.AppliedMutationOperator(id: .removeSideEffects, position: .firstPosition, testSuiteOutcome: .failed)
                    ])))

                    expect(report.fileReports).to(contain(MuterTestReport.FileReport(fileName: "file3.swift", mutationScore: 33, appliedOperators: [
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .failed),
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .passed),
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .passed)
                    ])))

                    expect(report.fileReports).to(contain(MuterTestReport.FileReport(fileName: "file 4.swift", mutationScore: 0, appliedOperators: [
                        MuterTestReport.AppliedMutationOperator(id: .negateConditionals, position: .firstPosition, testSuiteOutcome: .passed)
                    ])))
                }
            }

            context("when given an empty collection of MutationTestOutcomes") {
                it("calculates all its fields to empty values as part of its initialization") {
                    let report = MuterTestReport(from: [])

                    expect(report.globalMutationScore).to(equal(-1))
                    expect(report.totalAppliedMutationOperators).to(equal(0))
                    expect(report.fileReports).to(beEmpty())
                }
            }
        }
    }
}

