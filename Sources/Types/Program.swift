import CStdLib

struct Program {
    private var storage: [Int24]
    private(set) var sideLength: Int

    init(text: String) {
        self.storage = text.unicodeScalars.compactMap {
            $0 == " " || $0 == "\n" ? nil : Int24(scalar: $0)
        }

        // Determine the exact minimum side length
        let determinant = Double(8 * storage.count + 1)
        let underestimatedSideLength = (determinant.squareRoot() - 1) / 2
        self.sideLength = Int(ceil(underestimatedSideLength))

        // Pad it with NOPs
        let padding = self.storage.count - self.sideLength * (self.sideLength + 1) / 2
        self.storage.append(contentsOf: repeatElement(".", count: padding))
    }

    subscript(row: Int, column: Int) -> Int24 {
        get {
            assert(column >= 0 && column <= row)
            let idx = column + row * (row + 1) / 2
            return storage[idx]
        }
    }
}

extension Program: TextOutputStreamable {
    private var rows: some Sequence<ArraySlice<Int24>> {
        sequence(state: 0) { rowNum in
            guard rowNum < self.sideLength else { return nil }
            defer { rowNum += 1 }
            let offset = rowNum * (rowNum + 1) / 2
            return self.storage[offset...(offset + rowNum)]
        }
    }

    func write(to target: inout some TextOutputStream) {
        for (i, row) in rows.enumerated() {
            target.write(.init(repeating: " ", count: sideLength - i - 1))

            let rowStr = row.map { Unicode.Scalar(UInt32($0))!.description }
                .joined(separator: " ")
            target.write(rowStr)

            target.write("\n")
        }
    }
}
