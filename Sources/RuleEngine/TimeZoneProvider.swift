public protocol TimeZoneProvider {
    var timezone: String { get }
    var dateFormat: String { get }
}
