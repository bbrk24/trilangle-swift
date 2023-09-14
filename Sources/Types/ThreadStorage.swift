enum ThreadStatus: Equatable {
    case active, skipping, waiting
}

struct ThreadStorage {
    var stack: [Int24]
    var ip: IP
    var status: ThreadStatus
}

extension ThreadStorage: CustomDebugStringConvertible {
    var debugDescription: String {
        "(stack: \(stack), status: \(status), row: \(ip.row), column: \(ip.column), direction: \(ip.direction))"
    }
}
