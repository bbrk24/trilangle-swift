struct Int24: Hashable {
    private var value: Int32

    static let min = Int24(unchecked: -0x0080_0000)
    static let max = Int24(unchecked: +0x007f_ffff)
    static let bitWidth = 24

    private init(unchecked value: Int32) {
        self.value = value
    }

    /// True if the value is in bounds, false otherwise
    private static func boundsCheck(_ value: Int32) -> Bool {
        value >= Int24.min.value && value <= Int24.max.value
    }

    // For some reason, the default implementation by Strideable suppresses the automatic one by Equatable
    static func == (lhs: Int24, rhs: Int24) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: Literals
extension Int24: ExpressibleByIntegerLiteral {
    init(integerLiteral: Int32) {
        assert(Int24.boundsCheck(integerLiteral))
        self.value = integerLiteral
    }
}

extension Int24: ExpressibleByUnicodeScalarLiteral {
    init(unicodeScalarLiteral: Unicode.Scalar) {
        // Will always be in bounds
        self.value = Int32(bitPattern: unicodeScalarLiteral.value)
    }

    /// Like ``init(unicodeScalarLiteral:)``, but meant to be invoked at runtime.
    init(scalar: Unicode.Scalar) {
        self.value = Int32(bitPattern: scalar.value)
        assert(Int24.boundsCheck(self.value))
    }
}

// MARK: Empty conformances
// These conformances consist solely of default implementations.
extension Int24:
    CustomStringConvertible,
    LosslessStringConvertible,
    SignedNumeric,
    SignedInteger {}

// MARK: Operators
extension Int24: Comparable {
    // WARNING: Swift lets you have an empty conformance here, but the default implementations for > and < reference
    // each other, so at least one of them must be defined!
    static func < (lhs: Int24, rhs: Int24) -> Bool {
        lhs.value < rhs.value
    }
}

extension Int24: AdditiveArithmetic {
    static func + (lhs: Int24, rhs: Int24) -> Int24 {
        // This addition can never overflow, and I'm doing my own bounds check
        let value = lhs.value &+ rhs.value
        precondition(boundsCheck(value))
        return .init(unchecked: value)
    }

    static func - (lhs: Int24, rhs: Int24) -> Int24 {
        // This subtraction can never overflow, and I'm doing my own bounds check
        let value = lhs.value &- rhs.value
        precondition(boundsCheck(value))
        return .init(unchecked: value)
    }
}

extension Int24: Numeric {
    // Not making a whole UInt24 type just for this
    var magnitude: UInt32 { value.magnitude }

    static func * (lhs: Int24, rhs: Int24) -> Int24 {
        // This multiplication *can* overflow
        let value = lhs.value * rhs.value
        precondition(boundsCheck(value))
        return .init(unchecked: value)
    }

    static func *= (lhs: inout Int24, rhs: Int24) {
        // This multiplication *can* overflow
        lhs.value *= rhs.value
        precondition(boundsCheck(lhs.value))
    }
}

extension Int24: Strideable {
    typealias Stride = Int24
    
    func distance(to other: Int24) -> Int24 {
        other - self
    }

    func advanced(by n: Int24) -> Int24 {
        self + n
    }
}

extension Int24: BinaryInteger {
    var words: Int32.Words { value.words }

    var trailingZeroBitCount: Int { Swift.min(value.trailingZeroBitCount, bitWidth) }

    init(truncatingIfNeeded source: some BinaryInteger) {
        self.value = (Int32(truncatingIfNeeded: source) << 8) >> 8
    }

    static func / (lhs: Int24, rhs: Int24) -> Int24 {
        let value = lhs.value / rhs.value
        precondition(boundsCheck(value))
        return .init(unchecked: value)
    }

    static func /= (lhs: inout Int24, rhs: Int24) {
        lhs.value /= rhs.value
        precondition(boundsCheck(lhs.value))
    }

    static func % (lhs: Int24, rhs: Int24) -> Int24 {
        // Cannot overflow, but may divide by zero
        .init(unchecked: lhs.value % rhs.value)
    }

    static func %= (lhs: inout Int24, rhs: Int24) {
        lhs.value %= rhs.value
    }

    static func ^= (lhs: inout Int24, rhs: Int24) {
        lhs.value ^= rhs.value
    }

    static func |= (lhs: inout Int24, rhs: Int24) {
        lhs.value |= rhs.value
    }

    static func &= (lhs: inout Int24, rhs: Int24) {
        lhs.value &= rhs.value    
    }
}

extension Int24: FixedWidthInteger {
    var byteSwapped: Int24 {
        let lowByte  =  value & 0x0000ff
        let midByte  = (value & 0x00ff00) >> 8
        let highByte = (value & 0xff0000) >> 16

        let newValue = ((lowByte << 24) | (midByte << 16) | (highByte << 8)) >> 8
        return .init(unchecked: newValue)
    }

    var leadingZeroBitCount: Int {
        value < 0
            ? 0
            : value.leadingZeroBitCount - 8
    }

    var nonzeroBitCount: Int {
        value < 0
            ? value.nonzeroBitCount - 8
            : value.nonzeroBitCount
    }

    // wtf swift
    init(_truncatingBits bits: UInt) {
        self.value = (Int32(_truncatingBits: bits) << 8) >> 8
    }

    func addingReportingOverflow(_ rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        let value = self.value &+ rhs.value
        return (.init(truncatingIfNeeded: value), !Int24.boundsCheck(value))
    }

    func subtractingReportingOverflow(_ rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        let value = self.value &- rhs.value
        return (.init(truncatingIfNeeded: value), !Int24.boundsCheck(value))
    }

    func multipliedReportingOverflow(by rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        let (partialValue, overflow) = value.multipliedReportingOverflow(by: rhs.value)
        return (.init(truncatingIfNeeded: partialValue), overflow || !Int24.boundsCheck(partialValue))
    }

    func dividedReportingOverflow(by rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        let (partialValue, overflow) = value.dividedReportingOverflow(by: rhs.value)
        return (.init(truncatingIfNeeded: partialValue), overflow || !Int24.boundsCheck(partialValue))
    }

    func remainderReportingOverflow(dividingBy rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        let (partialValue, overflow) = value.remainderReportingOverflow(dividingBy: rhs.value)
        return (.init(truncatingIfNeeded: partialValue), overflow || !Int24.boundsCheck(partialValue))
    }

    func dividingFullWidth(_ dividend: (high: Int24, low: UInt32)) -> (quotient: Int24, remainder: Int24) {
        let (high, low) = dividend
        precondition(low.leadingZeroBitCount >= 8)
        let high32 = high.value >> 8
        let low32 = low | (UInt32(bitPattern: high.value) << 24)
        let (quotient, remainder) = value.dividingFullWidth((high32, low32))
        assert(Int24.boundsCheck(quotient) && Int24.boundsCheck(remainder))
        return (.init(unchecked: quotient), .init(unchecked: remainder))
    }

    static func &>> (lhs: Int24, rhs: Int24) -> Int24 {
        .init(unchecked: lhs.value &>> (rhs.value % 24))
    }
    
    static func &>>= (lhs: inout Int24, rhs: some BinaryInteger) {
        lhs.value &>>= (rhs % 24)
    }

    static func &<< (lhs: Int24, rhs: Int24) -> Int24 {
        let value = lhs.value << (rhs.value % 24)
        if rhs.value < 0 || !boundsCheck(value) {
            return 0
        }
        return .init(unchecked: value)
    }

    static func &<<= (lhs: inout Int24, rhs: some BinaryInteger) {
        lhs.value <<= (rhs % 24)
        if rhs < 0 || !boundsCheck(lhs.value) {
            lhs = 0
        }
    }

    static prefix func ~ (x: Int24) -> Int24 {
        .init(unchecked: ~x.value)
    }
}
