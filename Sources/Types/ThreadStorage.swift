struct ThreadStorage {
    private(set) var stack: [Int24]
    private var ip: IP

    var location: (row: Int, column: Int) {
        (ip.row, ip.column)
    }
}
