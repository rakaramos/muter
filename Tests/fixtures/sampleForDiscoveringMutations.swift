struct Example2 {
    func areEqualAsString(_ a: Int) -> String {
        let b = a != a
        return b == a ? "equal" : "not equal"
    }
    func < (lhs: String, rhs: String) -> Bool {
        return false
    }
}
