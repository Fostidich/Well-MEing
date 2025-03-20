extension String {
    var capitalize: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }
}
