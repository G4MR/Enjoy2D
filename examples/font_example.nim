include ../enjoy2d/lib

var game = initApp("Font Example", 800, 600)
var myfont = initFontUtf8(
    "UTF8 Test ǽ Ǽ ǻ Ǿ I'm so happy this actually works", 
    20, 
    "assets/OpenSans.ttf", 
    (0, 0, 255, 255), 
    text_type = "blendwrap", 
    wrap_length = 400
)

# draw at the end of the game loop
game.draw(proc(app: EAppMain, render: RendererPtr) =
    myfont.draw(render, int((app.getWidth() / 2) - 200), 100)
)

game.setFps(30)
game.run()