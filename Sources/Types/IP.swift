enum Direction: Int {
    case northeast = 0, east, southeast, southwest, west, northwest

    static let ne = Direction.northeast
    static let e = Direction.east
    static let se = Direction.southeast
    static let sw = Direction.southwest
    static let w = Direction.west
    static let nw = Direction.northwest

    func flattenNS() -> Direction {
        switch self {
        case .northeast, .east, .southeast:
            return .east
        case .southwest, .west, .northwest:
            return .west
        }
    }
}

struct Location: Hashable {
    var row: Int
    var column: Int
}

struct IP {
    var location: Location
    var direction: Direction

    var row: Int {
        get { location.row }
        set { location.row = newValue }
    }

    var column: Int {
        get { location.column }
        set { location.column = newValue }
    }

    init(location: Location, direction: Direction) {
        self.location = location
        self.direction = direction
    }

    init(row: Int, column: Int, direction: Direction) {
        assert(row >= 0 && column >= 0)
        self.location = .init(row: row, column: column)
        self.direction = direction
    }

    mutating func advance(sideLength: Int) {
        precondition(sideLength > 0)
        assert(row >= 0 && column >= 0)

        switch direction {
        case .west:
            if column == 0 {
                row += 1
                if row >= sideLength {
                    row = 0
                }
                column = row
            } else {
                column -= 1
            }
        case .east:
            if column == row {
                column = 0
                if row == 0 {
                    row = sideLength - 1
                } else {
                    row -= 1
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
        case .southeast:
            // reasoning about this case hurts my head
            // copy-pasted from the C++ code without vetting it
            column &+= 1
            row &+= 1
            if row == sideLength {
                if column < sideLength {
                    row = sideLength &- column &- 1
                } else {
                    row = sideLength &- 1
                }
                column = 0
            }
        case .northwest:
            // same note as above
            if column == 0 {
                if row == sideLength &- 1 {
                    column = sideLength &- 1
                } else {
                    column = sideLength &- row &- 2
                    row = sideLength &- 1
                }
            } else {
                row &-= 1
                column &-= 1
            }
        }
    }
}

extension Program {
    subscript(ip: IP) -> Int24 {
        self[ip.row, ip.column]
    }
}
