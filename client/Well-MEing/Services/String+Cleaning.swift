extension String? {

    var clean: String? {
        self?.clean
    }
    
    var isWhite: Bool {
        self?.isWhite ?? true
    }

}

extension String {

    var clean: String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    var isWhite: Bool {
        self.clean == nil
    }

}
