import RegexBuilder

enum IO {
    private static var inputBuffer = ""

    private static let int24Regex: some RegexComponent<(Substring, Int24)> = TryCapture {
        Optionally(.anyOf("+-"))
        OneOrMore(.digit)
    } transform: {
        Int24.init($0)
    }
    
    private static func tryFillBuffer() -> Bool {
        while inputBuffer.isEmpty {
            guard let line = readLine(strippingNewline: false) else {
                return false
            }
            inputBuffer = line
        }
        return true
    }

    static func getCharacter() -> Int24 {
        if tryFillBuffer() {
            return Int24(scalar: inputBuffer.unicodeScalars.removeFirst())
        }
        return -1
    }

    static func getNumber() -> Int24 {
        while tryFillBuffer() {
            if let match = inputBuffer.prefixMatch(of: int24Regex) {
                inputBuffer.removeSubrange(..<match.output.0.endIndex)
                return match.output.1
            } else {
                inputBuffer.unicodeScalars.removeFirst()
            }
        }
        return -1
    }
}
