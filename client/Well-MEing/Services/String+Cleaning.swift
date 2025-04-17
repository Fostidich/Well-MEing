extension String? {

    var clean: String? {
        return self?.clean
    }

}

extension String {

    var clean: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

}
