import Foundation
import SwiftUI

enum MockData {
    static var habitGroups:
        [(
            name: String, color: Color,
            tasks: [(title: String, description: String)]
        )]
    {
        [
            (
                "Nutrition",
                .orange,
                [
                    (
                        "Eat a fruit",
                        "How many apple/orange/banana have you eaten today?"
                    ),
                    ("Drink 8 glasses of water", "No Coca Cola"),
                ]
            ),
            (
                "Coding",
                .teal,
                [
                    (
                        "Submit one LeetCode",
                        "One LeetCode a day keeps the doctor away"
                    )
                ]
            ),
            (
                "Sport",
                .green,
                [
                    ("Run 20 minutes", "It's not much"),
                    ("Do some stretching", "Please"),
                    ("Do 100 pushups", "I bet you can't"),
                ]
            ),
        ]
    }

    static var pastReports:
        [(title: String, date: Date, color: Color, text: String)]
    {
        [
            (
                "Approaching the marathon",
                Date.fromString("2025-03-11T14:30:00"),
                .orange,
                "The marathon is just around the corner. Preparation is key, and this journey will test endurance. The training sessions have ramped up, and we're aiming for a new personal best."
            ),
            (
                "Fishing the biggest fish can be difficult, but we'll get there",
                Date.fromString("2025-03-04T14:30:00"),
                .teal,
                "Fishing isn't just about patience, but precision. The biggest fish require strategic planning and understanding of the environment. We're getting closer to our goal with each cast."
            ),
            (
                "Run to 100 LeetCode problems",
                Date.fromString("2025-02-25T14:30:00"),
                .red,
                "Completing 100 problems on LeetCode isn't just about solving problems, it's about improving problem-solving skills. Each challenge adds a layer of complexity, but with persistence, it will be achieved."
            ),
            (
                "Hitting 100kg on bench press",
                Date.fromString("2025-02-18T14:30:00"),
                .green,
                "Strength training is all about consistency. Reaching 100kg on the bench press is a milestone, but it's also a reminder that hard work pays off. With the right approach, the next challenge is within reach."
            ),
            (
                "Love your mama",
                Date.fromString("2025-02-11T14:30:00"),
                .pink,
                "Call you mama"
            ),
        ]
    }

    static var pastData:
        [String:
            [(
                name: String, color: Color,
                tasks: [(title: String, quantity: Int)]
            )]]
    {
        [
            "2025-03-06":
                [
                    (
                        "Nutrition",
                        .orange,
                        [
                            ("Eat a fruit", 3),
                            ("Drink 8 glasses of water", 14),
                        ]
                    ),
                    (
                        "Meditation",
                        .teal,
                        [
                            ("Do yoga for 30 minutes", 45),
                            ("Stare at the ceiling", 15),
                            ("Restroom breaks", 2),
                        ]
                    ),
                ]
        ]
    }

    static let chart1: [(day: Int, steps: Int)] = (1...31).map { day in
        (day: day, steps: Int.random(in: 1000...15000))
    }
    static let chart2: [(day: Int, steps: Int)] = (1...28).map { day in
        (day: day, steps: Int.random(in: 0...100))
    }
    static let chart3: [(day: Int, steps: Int)] = (1...10).map { day in
        (day: day, steps: Int.random(in: 1...5))
    }
}
