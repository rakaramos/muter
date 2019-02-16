import Quick
import Nimble
import TestingExtensions
@testable import muterCore

class MuterTestReportSpec: QuickSpec {
    override func spec() {
        describe("MuterTestReport") {

            context("on a file report") {
                context("when given a nonempty collection of MutationTestOutcomes") {
                    var report: MuterTestReport!
                    beforeEach {
                        report = MuterTestReport(from: self.exampleMutationTestResults)
                    }

                    it("calculates all its fields as part of its initialization") {
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

                    it("reports the results") {
                        expect(report.description).notTo(beEmpty())
                        // TODO: Need to figure out the <0x1b> that Rainbow? adds
//                        expect(report.description).to(equal(
//        """
//        Muter finished running!
//        --------------------------
//        Applied Mutation Operators
//        --------------------------
//
//        These are all of the ways that Muter introduced changes into your code.
//
//        In total, Muter applied 9 mutation operators.
//
//        File           Position             Applied Mutation Operator   Mutation Test Result
//        ----           --------             -------------------------   --------------------
//        file 4.swift   Line: 0, Column: 0   Negate Conditionals         \(0x1b)[31mfailed\(0x1b)m
//        file1.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[32mpassed\(0x1b)m
//        file1.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[32mpassed\(0x1b)m
//        file1.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[31mfailed\(0x1b)m
//        file2.swift    Line: 0, Column: 0   Remove Side Effects         \(0x1b)[32mpassed\(0x1b)m
//        file2.swift    Line: 0, Column: 0   Remove Side Effects         \(0x1b)[32mpassed\(0x1b)m
//        file3.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[32mpassed\(0x1b)m
//        file3.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[31mfailed\(0x1b)m
//        file3.swift    Line: 0, Column: 0   Negate Conditionals         \(0x1b)[31mfailed\(0x1b)m
//
//
//
//        --------------------
//        Mutation Test Scores
//        --------------------
//
//        These are the mutation scores for your test suite, as well as the files that had mutants introduced into them.
//
//        Mutation scores ignore build & runtime errors.
//
//        \(0x1b)1mMutation Score of Test Suite (higher is better)\(0x1b)[0m: \(0x1b)[92m55/100\(0x1b)[0m
//
//        File           # of Applied Mutation Operators   Mutation Score
//        ----           -------------------------------   --------------
//        file 4.swift   1                                 \(0x1b)[31m0\(0x1b)[0m
//        file1.swift    3                                 \(0x1b)[92m66\(0x1b)[0m
//        file2.swift    2                                 \(0x1b)[32m100\(0x1b)[0m
//        file3.swift    3                                 \(0x1b)[33m33\(0x1b)[0m
//        """
//                        ))
                    }
                }

                context("when given an empty collection of MutationTestOutcomes") {
                    var report: MuterTestReport!
                    beforeEach {
                        report = MuterTestReport(from: [])
                    }

                    it("calculates all its fields to empty values as part of its initialization") {
                        expect(report.globalMutationScore).to(equal(-1))
                        expect(report.totalAppliedMutationOperators).to(equal(0))
                        expect(report.fileReports).to(beEmpty())
                    }

                    it("reports the results") {
                        expect(report.description).notTo(beEmpty())
                    }
                }
            }

            context("on xcode report") {
                context("when given a nonempty collection of MutationTestOutcomes") {
                    var report: MuterTestReport!
                    beforeEach {
                        report = MuterTestReport(from: self.exampleMutationTestResults, xcodeOutput: true)
                    }

                    // TODO: This doesn't make sense on this context, must...remove...it
                    it("calculates all its fields as part of its initialization") {
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

                    it("reports the results") {
                        expect(report.description).to(equal(""))
                    }
                }

                context("when given an empty collection of MutationTestOutcomes") {
                    var report: MuterTestReport!
                    beforeEach {
                        report = MuterTestReport(from: [], xcodeOutput: true)
                    }

                    // TODO: This doesn't make sense on this context, must...remove...it
                    it("calculates all its fields to empty values as part of its initialization") {
                        expect(report.globalMutationScore).to(equal(-1))
                        expect(report.totalAppliedMutationOperators).to(equal(0))
                        expect(report.fileReports).to(beEmpty())
                    }

                    it("reports the results") {
                        expect(report.description).to(equal(""))
                    }
                }
            }
        }
    }
}

