// Inspired by https://github.com/nvzqz/Unreachable
// That repo is missing a swift-tools-version and is not consumable by the Swift 5 package manager.

@inlinable
func unreachable(
    _ message: @autoclosure () -> String = "Encountered unreachable path",
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    assertionFailure(message(), file: file, line: line)
    // Invoke nasal demons. LLVM will delete the code path containing this line at sufficiently high
    // optimization levels.
    return unsafeBitCast((), to: Never.self)
}

@inlinable @inline(__always)
func assume(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "Precondition violated",
    file: StaticString = #file,
    line: UInt = #line
) {
    guard condition() else {
        unreachable(message(), file: file, line: line)
    }
}
