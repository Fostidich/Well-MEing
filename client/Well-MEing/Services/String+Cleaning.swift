extension String? {
    
    var clean: String? {
        return self?.clean
    }
    
}

extension String {
    
    var clean: String? {
        let emptyValue =
            self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        return emptyValue ? nil : self
    }
    
}
