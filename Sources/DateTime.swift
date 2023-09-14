import Foundation

enum DateTime {
    private static var lastMidnight: Date! {
        Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: Date(),
            direction: .backward
        )
    }

    static func getScaledTime() -> Int24 {
        let scale = TimeInterval(Int24.max) / 86400
        let seconds = Date().timeIntervalSince(lastMidnight)
        return Int24(seconds * scale)
    }

    static func getDateNumber() -> Int24 {
        Int24(Date().timeIntervalSince1970 / 86400)
    }
}
