enum ThreadStatus: Equatable {
    case active, skipping, waiting
}

struct ThreadStorage {
    var stack: [Int24]
    var ip: IP
    var status: ThreadStatus
}
