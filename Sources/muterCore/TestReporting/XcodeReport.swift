public func xcodeReport(from outcomes: [MutationTestOutcome]) -> String {
    return outcomes
        .filter { $0.testSuiteOutcome == .passed }
        .map {
            "\($0.filePath):" +
                "\($0.position.line):\($0.position.utf8Offset): " +
                "warning: " +
            "\"Your test suite did not kill this mutant: Changed \($0.appliedMutation.rawValue)\""
        }
        .joined(separator: "\n")
}
