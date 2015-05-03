include ../enjoy2d/lib

var img : Image
var game = initApp("Draw Test", 800, 600)

# before game loop
game.before(proc(app: EAppMain) =

    # load image
    img = loadImage("assets/example.jpg", app.render)
    img.setSrc(0, 0, 500, 400)

    # set position in the middle of the window
    let imgx = int((app.getWidth() / 2) - (img.getWidth() / 2))
    let imgy = int((app.getheight() / 2) - (img.getheight() / 2))

    img.setXY(imgx, imgy)
)

# after game loop
game.after(proc(app: EAppMain) =
    img.close()
)

# draw to the screen 
game.draw(proc(app: EAppMain, render: RendererPtr) =
    img.draw(render)
)

game.setFps(30)
game.run()