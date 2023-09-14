import Foundation
let programText = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
let program = Program(text: programText)
var interpreter = ThreadManager(program: program)
interpreter.run()
