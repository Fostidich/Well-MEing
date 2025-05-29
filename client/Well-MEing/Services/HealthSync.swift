import HealthKit
import SwiftUI

class HealthSync {

    /// For each metric of the predefined habits built upon the Apple Health app, the aggregate value for the provided
    /// dates range is queried and put beside the habits themselves in the ``Actions`` binding.
    @MainActor static func healthActions(
        from begin: Date,
        to end: Date,
        into actions: Binding<Actions?>
    ) -> Bool {
        // TODO: build queries
        actions.wrappedValue = Actions(creations: healthHabits)
        return true
    }

    /// This is the list of predefines habits which metrics come from Apple Health app queries.
    @MainActor static let healthHabits: [Habit] = [

        // ACTIVITY:
        // stepCount,
        // distanceWalkingRunning,
        // flightsClimbed,
        // activeEnergyBurned,
        // basalEnergyBurned,
        Habit(
            name: "Activity",
            description:
                "Tracks your overall daily movement, including steps, distance, and calories burned.",
            metrics: [

                // stepCount
                Metric(
                    name: "Steps",
                    description: "Number of steps taken.",
                    input: .slider,
                    config: ["min": 0, "max": 20000, "type": "int"]
                ),

                // distanceWalkingRunning
                Metric(
                    name: "Distance",
                    description: "Distance covered while walking or running.",
                    input: .slider,
                    config: ["min": 0, "max": 10000, "type": "int"]
                ),

                // flightsClimbed
                Metric(
                    name: "Flights climbed",
                    description: "Floors climbed throughout the day.",
                    input: .slider,
                    config: ["min": 0, "max": 1000, "type": "int"]
                ),

                // activeEnergyBurned
                Metric(
                    name: "Active energy burned",
                    description: "Calories burned during activity.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

                // basalEnergyBurned
                Metric(
                    name: "Basal energy burned",
                    description: "Calories burned at rest.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

        // RUNNING:
        // distanceWalkingRunning,
        // runningPower,
        // runningSpeed,
        // respiratoryRate,
        // heartRate,
        // activeEnergyBurned,
        Habit(
            name: "Running",
            description:
                "Monitors your running performance, effort, and energy output.",
            metrics: [

                // distanceWalkingRunning
                Metric(
                    name: "Distance",
                    description: "Distance covered while walking or running.",
                    input: .slider,
                    config: ["min": 0, "max": 10000, "type": "int"]
                ),

                // runningPower
                Metric(
                    name: "Power",
                    description: "Force output while running.",
                    input: .slider,
                    config: ["min": 0, "max": 10000, "type": "int"]
                ),

                // runningSpeed
                Metric(
                    name: "Speed",
                    description: "Speed during running sessions.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // respiratoryRate
                Metric(
                    name: "Repiratory rate",
                    description: "Breaths per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // heartRate
                Metric(
                    name: "Heart rate",
                    description: "Beats per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // activeEnergyBurned
                Metric(
                    name: "Active energy burned",
                    description: "Calories burned during activity.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

        // CYCLING:
        // distanceCycling,
        // respiratoryRate,
        // heartRate,
        // activeEnergyBurned,
        Habit(
            name: "Cycling",
            description:
                "Captures your cycling distance and physical exertion metrics.",
            metrics: [

                // distanceCycling
                Metric(
                    name: "Distance",
                    description: "Distance traveled by cycling.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // respiratoryRate
                Metric(
                    name: "Repiratory rate",
                    description: "Breaths per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // heartRate
                Metric(
                    name: "Heart rate",
                    description: "Beats per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // activeEnergyBurned
                Metric(
                    name: "Active energy burned",
                    description: "Calories burned during activity.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

        // SWIMMING:
        // distanceSwimming,
        // swimmingStrokeCount,
        // underwaterDepth,
        // waterTemperature,
        // respiratoryRate,
        // heartRate,
        // activeEnergyBurned,
        Habit(
            name: "Swimming",
            description:
                "Measures swim performance, stroke efficiency, and water conditions.",
            metrics: [

                // distanceSwimming
                Metric(
                    name: "Distance",
                    description: "Distance swum in a session.",
                    input: .slider,
                    config: ["min": 0, "max": 1000, "type": "int"]
                ),

                // swimmingStrokeCount
                Metric(
                    name: "Strokes",
                    description: "Number of swim strokes.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

                // underwaterDepth
                Metric(
                    name: "Depth",
                    description: "Depth reached underwater.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // waterTemperature
                Metric(
                    name: "Water temperature",
                    description: "Temperature of the swimming water.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // respiratoryRate
                Metric(
                    name: "Repiratory rate",
                    description: "Breaths per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // heartRate
                Metric(
                    name: "Heart rate",
                    description: "Beats per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // activeEnergyBurned
                Metric(
                    name: "Active energy burned",
                    description: "Calories burned during activity.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

        // SNOW SPORT:
        // distanceDownhillSnowSports,
        // respiratoryRate,
        // heartRate,
        // activeEnergyBurned,
        Habit(
            name: "Snow sport",
            description:
                "Tracks snow sport activity with focus on distance and cardio effort.",
            metrics: [

                // distanceDownhillSnowSports
                Metric(
                    name: "Distance",
                    description: "Distance covered in snow sports.",
                    input: .slider,
                    config: ["min": 0, "max": 200, "type": "int"]
                ),

                // respiratoryRate
                Metric(
                    name: "Repiratory rate",
                    description: "Breaths per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // heartRate
                Metric(
                    name: "Heart rate",
                    description: "Beats per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // activeEnergyBurned
                Metric(
                    name: "Active energy burned",
                    description: "Calories burned during activity.",
                    input: .slider,
                    config: ["min": 0, "max": 2000, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

        // VITALS:
        // respiratoryRate,
        // oxygenSaturation,
        // heartRate,
        // bloodPressureSystolic,
        // bloodPressureDiastolic,
        // bodyTemperature,
        Habit(
            name: "Vitals",
            description:
                "Monitors key health indicators like heart rate, oxygen levels, and blood pressure.",
            metrics: [

                // respiratoryRate
                Metric(
                    name: "Repiratory rate",
                    description: "Breaths per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // oxygenSaturation
                Metric(
                    name: "Oxygen saturation",
                    description: "Percentage of oxygen in the blood.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // heartRate
                Metric(
                    name: "Heart rate",
                    description: "Beats per minute.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // bloodPressureSystolic
                Metric(
                    name: "Systolic blood pressure",
                    description: "Upper number of blood pressure.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // bloodPressureDiastolic
                Metric(
                    name: "Diastolic blood pressure",
                    description: "Lower number of blood pressure.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

                // bodyTemperature
                Metric(
                    name: "Body temperature",
                    description: "Measured body temperature.",
                    input: .slider,
                    config: ["min": 0, "max": 100, "type": "int"]
                ),

            ].compactMap { $0 }
        ),

    ].compactMap { $0 }

}
