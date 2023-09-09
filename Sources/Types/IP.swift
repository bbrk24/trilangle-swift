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

    mutating func advance(sideLength: Int) {
        precondition(sideLength > 0)
        assert(row >= 0 && column >= 0)

        switch direction {
        case .west:
            if column == 0 {
                if row == 0 {
                    row = sideLength - 1
                } else {
                    row -= 1
                }
                column = row
            } else {
                column -= 1
            }
        case .east:
            if column == row {
                column = 0
                row += 1
                if row >= sideLength {
                    row = 0
                }
            } else {
                column += 1
            }
        case .southwest:
            // Moving SW is usually just incrementing the row number...
            row += 1
            // ...but handle wraparound.
            if row >= sideLength {
                column += 1
                if column >= sideLength {
                    column = 0
                }
                row = column
            }
        case .northeast:
            if row == column {
                row = sideLength - 1
                if column == 0 {
                    column = sideLength - 1
                } else {
                    column -= 1
                }
            } else {
                row -= 1
            }
        case .northwest:
            // TODO
            break
        case .southeast:
            // TODO
            break
        }
    }
}
