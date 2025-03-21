import Foundation

enum MockData {
    static var items: [(title: String, action: () -> Void)] {
        [
            ("Task 1", { print("pop up 1") }),
            ("Task 2", { print("pop up 2") }),
            ("Task 3", { print("pop up 3") }),
            ("Task 4", { print("pop up 4") }),
            ("Task 5", { print("pop up 5") })
        ]
    }
}
