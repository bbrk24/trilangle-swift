import CStdLib

struct LinkedList {
    private var storage: UnsafeMutableBufferPointer<Element>
    private var unusedIndices: [Int] = Array()
    private var head = -1
    private var tail = -1

    init() {
        let ptr = calloc(4, MemoryLayout<Element>.stride).unsafelyUnwrapped
        storage = .init(start: ptr.bindMemory(to: Element.self, capacity: 4), count: 4)
        storage.initialize(repeating: Element(prev: -1, next: -1))
        unusedIndices = [3, 2, 1, 0]
    }

    var nodes: Nodes {
        Nodes(head == -1 ? nil : Node(index: head, storage: storage))
    }

    var isEmpty: Bool {
        head == -1
    }

    mutating func deallocate() {
        storage.deinitialize()
        free(storage.baseAddress)
        head = -1
        tail = -1
        unusedIndices.removeAll()
        storage = .init(start: nil, count: 0)
    }

    mutating func insert(_ value: __owned ThreadStorage) {
        if unusedIndices.isEmpty {
            let oldCount = storage.count
            let newPtr = realloc(storage.baseAddress, 2 * oldCount * MemoryLayout<Element>.stride).unsafelyUnwrapped
            (newPtr + oldCount).bindMemory(to: Element.self, capacity: oldCount)

            storage = .init(
                start: newPtr.assumingMemoryBound(to: Element.self),
                count: 2 * oldCount
            )
            storage[oldCount...].initialize(repeating: Element(prev: -1, next: -1))
            unusedIndices = Array(oldCount..<storage.count)
        }
        let location = unusedIndices.removeLast()

        storage[location] = Element(prev: tail, next: -1, value: value)
        if tail != -1 {
            storage[tail].next = location
        }
        tail = location
        if head == -1 {
            head = location
        }
    }

    mutating func remove(index: Int) {
        let el = storage[index]
        if el.prev != -1 {
            storage[el.prev].next = el.next
        }
        if el.next != -1 {
            storage[el.next].prev = el.prev
        }

        if index == head {
            head = el.next
        }

        if index == tail {
            tail = el.prev
        }

        unusedIndices.append(index)
    }

    mutating func remove(node: Node) {
        remove(index: node.index)
    }

    struct Node {
        fileprivate var index: Int
        fileprivate var storage: UnsafeMutableBufferPointer<Element>

        var value: ThreadStorage {
            get { storage[index].value }
            nonmutating _modify { yield &storage[index].value }
        }
    }

    struct Element {
        var prev: Int
        var next: Int
        var value: ThreadStorage!
    }

    struct Nodes: Sequence, IteratorProtocol {
        private var curr: Node?

        init(_ node: Node?) {
            self.curr = node
        }

        mutating func next() -> Node? {
            defer {
                _onFastPath()
                if let curr,
                   curr.storage[curr.index].next != -1 {
                    self.curr!.index = curr.storage[curr.index].next
                } else {
                    curr = nil
                }
            }
            return curr
        }
    }
}

extension LinkedList: CustomDebugStringConvertible {
    var debugDescription: String {
        nodes.map(\.value).debugDescription
    }
}
