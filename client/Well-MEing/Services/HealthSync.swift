import HealthKit
import SwiftUI

@MainActor
class HealthSync {

    /// Before being able to read health data, user must be prompted with an authorization request.
    static func requestAuthorization() {
        let healthStore = HKHealthStore()

        // Select all types that are going to be read
        let typesToRead: Set<HKQuantityType> = Set(
            healthHabits
                .compactMap { (habit: Habit) in
                    habit.metrics
                }
                .flatMap { (metrics: [Metric]) in
                    metrics
                }
                .compactMap { (metric: Metric) in
                    if let healthMetric = metric as? HealthMetric {
                        return HKQuantityType.quantityType(
                            forIdentifier: healthMetric.type
                        )
                    } else {
                        return nil
                    }
                }
        )

        // Ask authorization to read those
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) {
            _,
            _ in
        }
    }

    /// For each metric of the predefined habits built upon the Apple Health app, the aggregate value for the provided
    /// dates range is queried and put beside the habits themselves in the ``Actions`` binding.
    /// - SeeAlso: ``HealthMetric``
    static func healthActions(
        from begin: Date,
        to end: Date,
        into actions: Binding<Actions?>
    ) async -> Bool {
        // Check health store availability
        guard HKHealthStore.isHealthDataAvailable()
        else { return false }

        // Initialize loggins
        var loggings: [String: [Submission]] = [:]

        for habit in healthHabits {
            // Initialize metrics values dict
            var metricsDict: [String: Any] = [:]

            // Perform query for each metric
            for case let metric as HealthMetric in habit.metrics ?? [] {
                metricsDict[metric.name] = await extractMetricRecord(
                    metric,
                    begin: begin,
                    end: end
                )
            }

            // Create entry in loggings dict
            loggings[habit.name] = [
                Submission(
                    timestamp: end,
                    metrics: metricsDict
                )
            ]
        }

        // Build final actions object and return
        actions.wrappedValue = Actions(
            creations: healthHabits,
            loggings: loggings
        )
        return true
    }

    static private func extractMetricRecord(
        _ metric: HealthMetric,
        begin: Date,
        end: Date
    ) async -> Double {
        // Assure metric type
        guard
            let type =
                HKQuantityType
                .quantityType(forIdentifier: metric.type)
        else { return 0 }

        // Fix predicate with data range delimeter
        let predicate = HKQuery.predicateForSamples(
            withStart: begin,
            end: end,
            options: .strictStartDate
        )

        // Get rules for the health metric extraction
        let aggregation = metric.aggregation
        let quantity = metric.quantity
        let unit = metric.unit

        // Build the query for that health metric
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: aggregation
            ) { _, result, _ in
                // Try to get the value if retrieved successfully
                if let result,
                    let quantity = quantity(result)()?.doubleValue(for: unit)
                {
                    continuation.resume(returning: quantity)
                } else {
                    continuation.resume(returning: 0)
                }
            }

            // Make the query
            HKHealthStore().execute(query)
        }
    }

    /// This is the list of predefines habits which metrics come from Apple Health app queries.
    static let healthHabits: [Habit] = [
        healthActivityHabit,
        healthRunningHabit,
        healthCyclingHabit,
        healthSwimmingHabit,
        healthSnowSportHabit,
        healthVitalsHabit,
    ].compactMap { $0 }

    /// The "Activity" habit tracks the following metrics.
    /// ```
    /// stepCount
    /// distanceWalkingRunning
    /// flightsClimbed
    /// activeEnergyBurned
    /// basalEnergyBurned
    /// ```
    static let healthActivityHabit = Habit(
        name: "Activity",
        description:
            "Tracks your overall daily movement, including steps, distance, and calories burned.",
        metrics: [

            // stepCount
            HealthMetric(
                name: "Steps",
                description: "Number of steps taken.",
                input: .slider,
                config: ["min": 0, "max": 20000, "type": "int"],
                type: .stepCount,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .count()
            ),

            // distanceWalkingRunning
            HealthMetric(
                name: "Distance",
                description: "Distance covered while walking or running.",
                input: .slider,
                config: ["min": 0, "max": 10000, "type": "int"],
                type: .distanceWalkingRunning,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .meter()
            ),

            // flightsClimbed
            HealthMetric(
                name: "Flights climbed",
                description: "Floors climbed throughout the day.",
                input: .slider,
                config: ["min": 0, "max": 1000, "type": "int"],
                type: .flightsClimbed,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .count()
            ),

            // activeEnergyBurned
            HealthMetric(
                name: "Active energy burned",
                description: "Calories burned during activity.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .activeEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

            // basalEnergyBurned
            HealthMetric(
                name: "Basal energy burned",
                description: "Calories burned at rest.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .basalEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

        ].compactMap { $0 }
    )

    /// The "Running" habit tracks the following metrics.
    /// ```
    /// distanceWalkingRunning
    /// runningPower
    /// runningSpeed
    /// respiratoryRate
    /// heartRate
    /// activeEnergyBurned
    /// ```
    static let healthRunningHabit = Habit(
        name: "Running",
        description:
            "Monitors your running performance, effort, and energy output.",
        metrics: [

            // distanceWalkingRunning
            HealthMetric(
                name: "Distance",
                description: "Distance covered while walking or running.",
                input: .slider,
                config: ["min": 0, "max": 10000, "type": "int"],
                type: .distanceWalkingRunning,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .meter()
            ),

            // runningPower
            HealthMetric(
                name: "Power",
                description: "Force output while running.",
                input: .slider,
                config: ["min": 0, "max": 10000, "type": "int"],
                type: .runningPower,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .watt()
            ),

            // runningSpeed
            HealthMetric(
                name: "Speed",
                description: "Speed during running sessions.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .runningSpeed,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .meterUnit(with: .kilo).unitDivided(by: .hour())
            ),

            // respiratoryRate
            HealthMetric(
                name: "Repiratory rate",
                description: "Breaths per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .respiratoryRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // heartRate
            HealthMetric(
                name: "Heart rate",
                description: "Beats per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .heartRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // activeEnergyBurned
            HealthMetric(
                name: "Active energy burned",
                description: "Calories burned during activity.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .activeEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

        ].compactMap { $0 }
    )

    /// The "Cycling" habit tracks the following metrics.
    /// ```
    /// distanceCycling
    /// respiratoryRate
    /// heartRate
    /// activeEnergyBurned
    /// ```
    static let healthCyclingHabit = Habit(
        name: "Cycling",
        description:
            "Captures your cycling distance and physical exertion metrics.",
        metrics: [

            // distanceCycling
            HealthMetric(
                name: "Distance",
                description: "Distance traveled by cycling.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .distanceCycling,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .meterUnit(with: .kilo)
            ),

            // respiratoryRate
            HealthMetric(
                name: "Repiratory rate",
                description: "Breaths per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .respiratoryRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // heartRate
            HealthMetric(
                name: "Heart rate",
                description: "Beats per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .heartRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // activeEnergyBurned
            HealthMetric(
                name: "Active energy burned",
                description: "Calories burned during activity.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .activeEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

        ].compactMap { $0 }
    )

    /// The "Swimming" habit tracks the following metrics.
    /// ```
    /// distanceSwimming
    /// swimmingStrokeCount
    /// underwaterDepth
    /// waterTemperature
    /// respiratoryRate
    /// heartRate
    /// activeEnergyBurned
    /// ```
    static let healthSwimmingHabit = Habit(
        name: "Swimming",
        description:
            "Measures swim performance, stroke efficiency, and water conditions.",
        metrics: [

            // distanceSwimming
            HealthMetric(
                name: "Distance",
                description: "Distance swum in a session.",
                input: .slider,
                config: ["min": 0, "max": 1000, "type": "int"],
                type: .distanceSwimming,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .meter()
            ),

            // swimmingStrokeCount
            HealthMetric(
                name: "Strokes",
                description: "Number of swim strokes.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .swimmingStrokeCount,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .count()
            ),

            // underwaterDepth
            HealthMetric(
                name: "Depth",
                description: "Depth reached underwater.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "inot"],
                type: .underwaterDepth,
                aggregation: .discreteMax,
                quantity: HKStatistics.maximumQuantity,
                unit: .meter()
            ),

            // waterTemperature
            HealthMetric(
                name: "Water temperature",
                description: "Temperature of the swimming water.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .waterTemperature,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .degreeCelsius()
            ),

            // respiratoryRate
            HealthMetric(
                name: "Repiratory rate",
                description: "Breaths per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .respiratoryRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // heartRate
            HealthMetric(
                name: "Heart rate",
                description: "Beats per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .heartRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // activeEnergyBurned
            HealthMetric(
                name: "Active energy burned",
                description: "Calories burned during activity.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .activeEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

        ].compactMap { $0 }
    )

    /// The "Snow sport" habit tracks the following metrics.
    /// ```
    /// distanceDownhillSnowSports
    /// respiratoryRate
    /// heartRate
    /// activeEnergyBurned
    /// ```
    static let healthSnowSportHabit = Habit(
        name: "Snow sport",
        description:
            "Tracks snow sport activity with focus on distance and cardio effort.",
        metrics: [

            // distanceDownhillSnowSports
            HealthMetric(
                name: "Distance",
                description: "Distance covered in snow sports.",
                input: .slider,
                config: ["min": 0, "max": 200, "type": "int"],
                type: .distanceDownhillSnowSports,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .meterUnit(with: .kilo)

            ),

            // respiratoryRate
            HealthMetric(
                name: "Repiratory rate",
                description: "Breaths per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .respiratoryRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // heartRate
            HealthMetric(
                name: "Heart rate",
                description: "Beats per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .heartRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // activeEnergyBurned
            HealthMetric(
                name: "Active energy burned",
                description: "Calories burned during activity.",
                input: .slider,
                config: ["min": 0, "max": 2000, "type": "int"],
                type: .activeEnergyBurned,
                aggregation: .cumulativeSum,
                quantity: HKStatistics.sumQuantity,
                unit: .kilocalorie()
            ),

        ].compactMap { $0 }
    )

    /// The "Vitals" habit tracks the following metrics.
    /// ```
    /// respiratoryRate
    /// oxygenSaturation
    /// heartRate
    /// bloodPressureSystolic
    /// bloodPressureDiastolic
    /// bodyTemperature
    /// ```
    static let healthVitalsHabit = Habit(
        name: "Vitals",
        description:
            "Monitors key health indicators like heart rate, oxygen levels, and blood pressure.",
        metrics: [

            // respiratoryRate
            HealthMetric(
                name: "Repiratory rate",
                description: "Breaths per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .respiratoryRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // oxygenSaturation
            HealthMetric(
                name: "Oxygen saturation",
                description: "Percentage of oxygen in the blood.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .oxygenSaturation,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .percent()
            ),

            // heartRate
            HealthMetric(
                name: "Heart rate",
                description: "Beats per minute.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .heartRate,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .count().unitDivided(by: .minute())
            ),

            // bloodPressureSystolic
            HealthMetric(
                name: "Systolic blood pressure",
                description: "Upper number of blood pressure.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .bloodPressureSystolic,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .millimeterOfMercury()
            ),

            // bloodPressureDiastolic
            HealthMetric(
                name: "Diastolic blood pressure",
                description: "Lower number of blood pressure.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .bloodPressureDiastolic,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .millimeterOfMercury()
            ),

            // bodyTemperature
            HealthMetric(
                name: "Body temperature",
                description: "Measured body temperature.",
                input: .slider,
                config: ["min": 0, "max": 100, "type": "int"],
                type: .bodyTemperature,
                aggregation: .discreteAverage,
                quantity: HKStatistics.averageQuantity,
                unit: .degreeCelsius()
            ),

        ].compactMap { $0 }
    )

}
