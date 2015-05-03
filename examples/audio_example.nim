include ../enjoy2d/lib

var audioclip : Sound
var game = initApp("Audio Test", 800, 600)

# before the game loop
game.before(proc(app: EappMain) =
    audioclip = initSound("assets/sound.ogg")
)

# after the game loop
game.after(proc(app: EAppMain) =
    audioclip.cleanUp()
)

# handle events
game.events(proc(app: EAppMain, e: var Event) =

    # up/down/left/right arrow keys 
    # to start/stop/pause/resume audio
    if e.kind == KeyDown:
        if keyPressed(K_UP):
            audioclip.play()

        if keyPressed(K_DOWN):
            audioclip.stop()

        if keyPressed(K_LEFT):
            audioclip.pause()

        if keyPressed(K_RIGHT):
            audioclip.resume()
)

# update stuff
game.update(proc(app: EAppMain, dt: float) =
    audioclip.playing()
)

game.setFps(30)
game.run()