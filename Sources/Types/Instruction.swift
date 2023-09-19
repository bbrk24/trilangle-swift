@objc enum Instruction: Unicode.Scalar {
    case nop = "."
    case exit = "@"
    case skip = "#"

    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = ":"
    case modulo = "%"
    case increment = ")"
    case decrement = "("

    case bitAnd = "&"
    case bitOr = "r"
    case bitXor = "x"
    case bitNot = "~"
    case exponential = "e"

    case pushInt = "'"
    case pushChar = "\""
    case pop = ","
    case index = "j"
    case duplicate = "2"
    case twoDupe = "z"
    case swap = "S"

    case getChar = "i"
    case putChar = "o"
    case getInt = "?"
    case putInt = "!"
    case random = "$"
    case getTime = "T"
    case getDate = "D"

    case branchNorthwest = "^"
    case branchNortheast = "7"
    case branchEast = ">"
    case branchSoutheast = "v"
    case branchSouthwest = "L"
    case branchWest = "<"

    case threadWest = "{"
    case threadEast = "}"

    case mirrorHorizontal = "_"
    case mirrorVertical = "|"
    case mirrorForward = "/"
    case mirrorBack = "\\"
}

extension Instruction {
    init?(i24: Int24) {
        if let scalar = i24.scalar,
           let _self = Instruction(rawValue: scalar) {
            self = _self
        } else {
            return nil
        }
    }

    var i24: Int24 {
        Int24(scalar: rawValue)
    }
}
