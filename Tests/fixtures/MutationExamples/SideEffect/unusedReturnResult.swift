struct Example {
    func containsSideEffect() -> Int {
        _ = causesSideEffect()
        return 1
    }

    func containsSideEffect() -> Int {
        print("something")

        _ = causesSideEffect()
    }

    @discardableResult
    func causesSideEffect() -> Int {
        return 0
    }

    func causesAnotherSideEffect() {
        let key = "some key"
        let value = aFunctionThatReturnsAValue()
        someFunctionThatWritesToADatabase(key: key, value: value)
    }

    func containsSpecialCases() {
        fatalError("this should never be deleted!")
        exit(1)
        abort()
    }

    func containsADeepMethodCall() {
        let containsIgnoredResult = statement.description.contains("lol")
        var anotherIgnoredResult = statement.description.contains("lol")
    }

    func containsAVoidFunctionCallThatSpansManyLine() {
        functionCall("some argument",
                     anArgumentLabel: "some argument that's different",
                     anotherArgumentLabel: 5)
    }
	
	func containsAVoidFunctionCallInsideAForLoop() {
		var positionsOfToken: [AbsolutePosition] = []
        for statement in body.statements where statementContainsMutableToken(statement) {
			positionsOfToken.append(position)
        }
	}
}
