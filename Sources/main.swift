let p = Program(text: """
     ?
    ! @
    """)
var interpreter = ThreadManager(program: p)
interpreter.run()
