import Foundation

enum AwakeDuration: Hashable, CaseIterable, Identifiable {
    case indefinitely
    case minutes(Int)
    case hours(Int)

    static let allCases: [AwakeDuration] = [
        .indefinitely,
        .minutes(15), .minutes(30), .minutes(45),
        .hours(1), .hours(4), .hours(8), .hours(12),
    ]

    var id: Self { self }

    var interval: TimeInterval? {
        switch self {
        case .indefinitely: nil
        case .minutes(let m): TimeInterval(m * 60)
        case .hours(let h): TimeInterval(h * 3600)
        }
    }

    var chipLabel: String {
        switch self {
        case .indefinitely: "∞"
        case .minutes(let m): String(format: "%02d", m)
        case .hours(let h): String(format: "%02d", h)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .indefinitely: "Indefinitely"
        case .minutes(let m): "\(m) minutes"
        case .hours(let h): h == 1 ? "1 hour" : "\(h) hours"
        }
    }

    var group: Int {
        switch self {
        case .indefinitely: 0
        case .minutes: 1
        case .hours: 2
        }
    }
}
