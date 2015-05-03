import sdl2

proc keyPressed*(key: cint): bool =
    
    var scancode = sdl2.getScancodeFromKey(key)
    var keystate = sdl2.getKeyboardState()

    if keystate[scancode.uint8] == 1:
        true
    else:
        false