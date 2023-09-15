enum Mirror: Int {
    case vertical = 0, horizontal, forwardSlash, backslash
}

private let mirrorMatrix: [[Direction]] = [
//         |           _           /           \
/* NE */ [.northwest, .southeast, .northeast, .west     ],
/* E  */ [.west,      .east,      .northwest, .southwest],
/* SE */ [.southwest, .northeast, .west,      .southeast],
/* SW */ [.southeast, .northwest, .southwest, .east     ],
/* W  */ [.east,      .west,      .southeast, .northeast],
/* NW */ [.northeast, .southwest, .east,      .northwest],
]

private let branchMatrix: [[(Direction, Direction)]] = [
//         7           >           v           L           <           ^
/* NE */ [(.sw, .sw), (.e,  .e ), (.sw, .sw), (.e,  .nw), (.sw, .sw), (.nw, .nw)],
/* E  */ [(.ne, .ne), (.w,  .w ), (.se, .se), (.w,  .w ), (.se, .ne), (.w,  .w )],
/* SE */ [(.nw, .nw), (.e,  .e ), (.nw, .nw), (.sw, .sw), (.nw, .nw), (.sw, .e )],
/* SW */ [(.w,  .se), (.ne, .ne), (.se, .se), (.ne, .ne), (.w,  .w ), (.ne, .ne)],
/* W  */ [(.e,  .e ), (.nw, .sw), (.e,  .e ), (.sw, .sw), (.e,  .e ), (.nw, .nw)],
/* NW */ [(.ne, .ne), (.se, .se), (.ne, .w ), (.se, .se), (.w,  .w ), (.se, .se)],
]

extension Direction {
    mutating func reflect(_ mirror: Mirror) {
        self = mirrorMatrix[self.rawValue][mirror.rawValue]
    }

    mutating func branch(_ branch: Direction, _ goLeft: () throws -> Bool) rethrows {
        let pair = branchMatrix[self.rawValue][branch.rawValue]
        self = try goLeft() ? pair.1 : pair.0
    }
}