enum LinkedList<T> {
    case empty
    case notEmpty(head: Node, tail: Node)

    var nodes: Nodes {
        switch self {
        case .empty:
            return .init(nil)
        case .notEmpty(let head, tail: _):
            return .init(head)
        }
    }

    mutating func insert(_ value: T) {
        let newNode = Node(value)
        switch self {
        case .empty:
            self = .notEmpty(head: newNode, tail: newNode)
        case .notEmpty(let head, let tail):
            tail.next = newNode
            newNode.prev = tail
            self = .notEmpty(head: head, tail: newNode)
        }
    }

    mutating func remove(node: Node) {
        guard case .notEmpty(let head, let tail) = self else {
            preconditionFailure()
        }

        switch (node.prev, node.next) {
        case (nil, nil):
            precondition(head === tail && node === head)
            self = .empty
        case (let prev?, let next?):
            prev.next = next
            next.prev = prev
        case (nil, let next?):
            precondition(node === head)
            next.prev = nil
            self = .notEmpty(head: next, tail: tail)
        case (let prev?, nil):
            precondition(node === tail)
            prev.next = nil
            self = .notEmpty(head: head, tail: prev)
        }
    }

    final class Node {
        fileprivate var prev: Node?
        fileprivate var next: Node?
        var value: T

        init(_ value: T) {
            self.value = value
        }
    }

    struct Nodes: Sequence, IteratorProtocol {
        private var curr: Node?

        init(_ node: Node?) {
            self.curr = node
        }

        var underestimatedCount: Int {
            curr == nil ? 0 : 1
        }

        mutating func next() -> Node? {
            defer { curr = curr?.next }
            return curr
        }
    }
}

extension LinkedList: CustomDebugStringConvertible {
    var debugDescription: String {
        nodes.map(\.value).debugDescription
    }
}
