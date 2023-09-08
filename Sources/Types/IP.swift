enum Direction {
    case southwest, west, northwest, northeast, east, southeast

    var nsToggled: Direction {
        switch self {
        case .southwest:
            return .northwest
        case .northwest:
            return .southwest
        case .northeast:
            return .southeast
        case .southeast:
            return .northeast
        case .west, .east:
            return self
        }
    }
}

struct IP {
    var row: Int
    var column: Int
    var direction: Direction
}
