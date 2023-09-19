struct ThreadManager: ~Copyable {
    var program: Program
    var threads = LinkedList()

    private var hasThreads: Bool {
        program.contains(Instruction.threadEast.i24) || program.contains(Instruction.threadWest.i24)
    }

    init(program: consuming Program) {
        self.program = program
    }

    mutating func run() {
        var firstThread = ThreadStorage(stack: Array(), ip: IP(row: 0, column: 0, direction: .southwest), status: .active)
        if !hasThreads {
            loop: while true {
                switch tick(thread: &firstThread) {
                case .exit:
                    break loop
                case .keep:
                    assert(firstThread.status != .waiting)
                default:
                    preconditionFailure()
                }
            }
        } else {
            self.threads.insert(firstThread)
            repeat {
                tick()
            } while !threads.isEmpty
        }
    }

    private mutating func tick() {
        // These three variables have such a massive impact on performance I've special-cased for when it's statically
        // known they aren't needed. It doesn't even call `tick()` in that case.
        // Removing that special case makes the code 2-3x slower. perf says a significant fraction of the time is spent
        // in swift_release, which is almost certainly due to RC/CoW. The rest of it is likely just the difference
        // between iterating over a linked list vs holding the one value on the stack.
        var removals: [LinkedList.Node] = Array()
        var additions: [ThreadStorage] = Array()
        var waiting: [Location: LinkedList.Node] = Dictionary()

        for node in threads.nodes {
            switch tick(thread: &node.value) {
            case .remove:
                removals.append(node)
            case .add(let newThread):
                additions.append(newThread)
            case .keep:
                if _slowPath(node.value.status == .waiting) {
                    if let match = waiting[node.value.ip.location] {
                        removals.append(node)
                        removals.append(match)
                        waiting.removeValue(forKey: node.value.ip.location)

                        var stack: [Int24]

                        let matchDepth = Int(match.value.stack.removeLast())
                        if matchDepth < 0 {
                            stack = match.value.stack
                        } else {
                            stack = match.value.stack.suffix(matchDepth)
                        }

                        let ownDepth = Int(node.value.stack.removeLast())
                        if ownDepth < 0 {
                            stack += node.value.stack
                        } else {
                            stack += node.value.stack.suffix(ownDepth)
                        }

                        var newThreadIP = node.value.ip
                        newThreadIP.direction = newThreadIP.direction.flattenNS()
                        newThreadIP.advance(sideLength: program.sideLength)

                        additions.append(.init(
                            stack: stack,
                            ip: newThreadIP,
                            status: .active
                        ))
                    } else {
                        waiting[node.value.ip.location] = node
                    }
                }
            case .exit:
                threads.removeAll()
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

        guard let instruction = Instruction(i24: program[thread.ip]) else {
            fatalError("Unrecognized instruction")
        }

        // https://forums.swift.org/t/bool-is-not-optional/67289
        let goLeft = { thread.stack.last.map { $0 < .zero } ?? true }

        switch instruction {
        case .nop:
            break
        case .exit:
            return .exit
        case .skip:
            thread.status = .skipping
            thread.ip.advance(sideLength: program.sideLength)
        case .add:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] += last
        case .subtract: 
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] -= last
        case .multiply:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] *= last
        case .divide:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] /= last
        case .modulo:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] %= last
        case .increment:
            thread.stack[thread.stack.count - 1] &+= 1
        case .decrement: 
            thread.stack[thread.stack.count - 1] &-= 1
        case .bitAnd:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] &= last
        case .bitOr:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] |= last
        case .bitXor:
            let last = thread.stack.removeLast()
            thread.stack[thread.stack.count - 1] ^= last
        case .bitNot:
            thread.stack[thread.stack.count - 1] = ~thread.stack[thread.stack.count - 1]
        case .exponential:
            thread.stack[thread.stack.count - 1] = 1 << thread.stack[thread.stack.count - 1]
        case .pushInt:
            thread.ip.advance(sideLength: program.sideLength)
            let scalar = program[thread.ip].scalar!
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
        case .index:
            let index = thread.stack.removeLast()
            thread.stack.append(thread.stack[thread.stack.count - Int(index) - 1])
        case .duplicate:
            thread.stack.append(thread.stack.last!)
        case .twoDupe:
            thread.stack.append(contentsOf: thread.stack.suffix(2))
        case .swap:
            thread.stack.swapAt(thread.stack.count - 1, thread.stack.count - 2)
        case .getChar:
            thread.stack.append(IO.getCharacter())
        case .putChar:
            print(thread.stack.last!.scalar!, terminator: "")
        case .getInt:
            thread.stack.append(IO.getNumber())
        case .putInt:
            print(thread.stack.last!)
        case .random:
            thread.stack.append(.random(in: .min ... .max))
        case .getTime:
            thread.stack.append(DateTime.getScaledTime())
        case .getDate:
            thread.stack.append(DateTime.getDateNumber())
        case .branchNorthwest:
            thread.ip.direction.branch(.northwest, goLeft)
        case .branchNortheast:
            thread.ip.direction.branch(.northeast, goLeft)
        case .branchEast:
            thread.ip.direction.branch(.east, goLeft)
        case .branchSoutheast:
            thread.ip.direction.branch(.southeast, goLeft)
        case .branchSouthwest:
            thread.ip.direction.branch(.southwest, goLeft)
        case .branchWest:
            thread.ip.direction.branch(.west, goLeft)
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
        case .mirrorHorizontal:
            thread.ip.direction.reflect(.horizontal)
        case .mirrorVertical:
            thread.ip.direction.reflect(.vertical)
        case .mirrorForward:
            thread.ip.direction.reflect(.forwardSlash)
        case .mirrorBack:
            thread.ip.direction.reflect(.backslash)
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
