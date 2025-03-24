import Foundation

enum MockData {
    static var habitGroups: [(name: String, tasks: [(String, String)])] {
        [
            ("Nutrition", [("Eat a fruit", "Apple/Orange/Banana"), ("Drink 8 glasses of water", "No Coca Cola")]),
            ("Sport", [("Run 20 minutes", "It's not much"), ("Do some stretching", "Please"), ("Do 100 pushups", "I bet you can't")]),
        ]
    }
}
