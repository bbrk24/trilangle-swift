import Foundation
let programText = try! String(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
var interpreter = ThreadManager(program: Program(text: programText))
interpreter.run()
