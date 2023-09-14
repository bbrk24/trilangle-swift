struct ThreadManager {
    var program: Program
    var threads: LinkedList<ThreadStorage>

    init(program: Program) {
        self.program = program
        self.threads = .empty
        self.threads.insert(.init(stack: [], ip: IP(row: 0, column: 0, direction: .southwest), status: .active))
    }

    mutating func run() {
        while true {
            tick()

            if case .empty = threads {
                return
            }
        }
    }

    mutating func tick() {
        var removals: [LinkedList<ThreadStorage>.Node] = []
        var additions: [ThreadStorage] = []

        for node in threads.nodes {
            switch tick(thread: &node.value) {
            case .remove:
                removals.append(node)
            case .add(let newThread):
                additions.append(newThread)
            case .keep:
                break
            case .exit:
                threads = .empty
                return
            }
        }

        for node in removals {
            threads.remove(node: node)
        }
        for thread in additions {
            threads.insert(thread)
        }
    }

    private func tick(thread: inout ThreadStorage) -> ThreadResult {
        switch thread.status {
        case .waiting:
            return .keep
        case .skipping:
            thread.status = .active
            return .keep
        case .active:
            break
        }

        guard let instruction = Instruction(rawValue: program[thread.ip]) else {
            fatalError("Unrecognized instruction")
        }

        switch instruction {    
        case .nop:
            break
        case .exit:
            return .exit
        case .skip:
            thread.status = .skipping
            thread.ip.advance(sideLength: program.sideLength)
        case .add: break
        case .subtract: break
        case .multiply: break
        case .divide: break
        case .modulo: break
        case .increment: break
        case .decrement: break
        case .bitAnd: break
        case .bitOr: break
        case .bitXor: break
        case .bitNot: break
        case .exponential: break
        case .pushInt:
            thread.ip.advance(sideLength: program.sideLength)
            let operand = program[thread.ip]
            let scalar = Unicode.Scalar(UInt32(operand))!
            guard let value = Character(scalar).wholeNumberValue,
                  let i24Value = Int24(exactly: value) else {
                fatalError("Operand of push instruction (\(scalar)) is not a number")
            }
            thread.stack.append(i24Value)
            thread.status = .skipping
        case .pushChar:
            thread.ip.advance(sideLength: program.sideLength)
            let operand = program[thread.ip]
            thread.stack.append(operand)
            thread.status = .skipping
        case .pop:
            _ = thread.stack.popLast()
        case .index: break
        case .duplicate: break
        case .twoDupe: break
        case .swap: break
        case .getChar:
            thread.stack.append(IO.getCharacter())
        case .putChar: break
        case .getInt:
            thread.stack.append(IO.getNumber())
        case .putInt: break
        case .random:
            thread.stack.append(.random(in: .min ... .max))
        case .getTime:
            thread.stack.append(DateTime.getScaledTime())
        case .getDate:
            thread.stack.append(DateTime.getDateNumber())
        case .branchNorthwest: break
        case .branchNortheast: break
        case .branchEast: break
        case .branchSoutheast: break
        case .branchSouthwest: break
        case .branchWest: break
        case .threadWest:
            switch thread.ip.direction {
            case .southwest, .northwest:
                thread.status = .waiting
                return .keep
            case .west:
                return .remove
            case .northeast, .southeast:
                break
            case .east:
                var newThread = thread
                
                thread.ip.direction = .northeast
                thread.ip.advance(sideLength: program.sideLength)

                newThread.ip.direction = .southeast
                newThread.ip.advance(sideLength: program.sideLength)

                return .add(newThread)
            }
        case .threadEast:
            switch thread.ip.direction {
            case .southeast, .northeast:
                thread.status = .waiting
                return .keep
            case .east:
                return .remove
            case .northwest, .southwest:
                break
            case .west:
                var newThread = thread
                
                thread.ip.direction = .northwest
                thread.ip.advance(sideLength: program.sideLength)

                newThread.ip.direction = .southwest
                newThread.ip.advance(sideLength: program.sideLength)

                return .add(newThread)
            }
        case .mirrorHorizontal: break
        case .mirrorVertical: break
        case .mirrorForward: break
        case .mirrorBack: break
        }

        thread.ip.advance(sideLength: program.sideLength)

        return .keep
    }

    enum ThreadResult {
        case keep
        case remove
        case exit
        case add(ThreadStorage)
    }
}
