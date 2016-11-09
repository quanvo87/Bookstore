
protocol DictionaryConvertible {
    var dictionary: [String: Any] {get}
}

extension Array where Element : DictionaryConvertible {
    var dictionary: [[String: Any]] {
        return self.map { $0.dictionary }
    }
}