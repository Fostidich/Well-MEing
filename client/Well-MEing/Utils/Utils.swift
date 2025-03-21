extension String {
    var capitalize: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
