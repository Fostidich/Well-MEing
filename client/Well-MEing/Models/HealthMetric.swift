import HealthKit

class HealthMetric: Metric {

    public let type: HKQuantityTypeIdentifier
    public let aggregation: HKStatisticsOptions
    public let quantity: @Sendable (HKStatistics) -> () -> HKQuantity?
    public let unit: HKUnit

    init?(
        name: String,
        description: String? = nil,
        input: InputType = .slider,
        config: [String: Any]? = nil,
        type: HKQuantityTypeIdentifier,
        aggregation: HKStatisticsOptions,
        quantity: @escaping @Sendable (HKStatistics) -> () -> HKQuantity?,
        unit: HKUnit
    ) {
        self.type = type
        self.aggregation = aggregation
        self.quantity = quantity
        self.unit = unit
        super.init(
            name: name,
            description: description,
            input: input,
            config: config
        )
    }

    required init?(dict: [String: Any]) {
        return nil
    }

}
