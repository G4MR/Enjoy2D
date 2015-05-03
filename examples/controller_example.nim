include ../enjoy2d/lib

var ctrls = Controller()
var game = initApp("Controller Example", 800, 600)

# after game loop
game.after(proc(app: EAppMain) =
    ctrls.closeControllers()
)

game.events(proc(app: EAppMain, e: var Event) =

    # check if we've attached/disconnected a controller
    if e.kind == JoyDeviceAdded:
        ctrls.getConnectedControllers()        

    if e.kind == JoyDeviceRemoved:
        ctrls.getConnectedControllers()

    # check if we've pressed button A on the first connected controller
    if e.kind == JoyButtonDown:
        if ctrls.getButton(1, BTN_A):
            echo "Pressed A"

    # check if we're moving the first connected controller's left/right stick
    if e.kind == JoyAxisMotion:

        # all the settings are for the first connected controller
        # you'll notice a pattern that each function takes 1
        # which stands for the first controller, use 2, 3, 4 for
        # checking for multiple connected controllers

        # check the direction we're pressing on each thumb stick
        # North, South, East, West, NorthWest, NorthEast, SouthWest
        # and SouthEast as well as Invalid 
        var leftAxis = ctrls.getLeftAxisDirection(1)
        var rightAxis = ctrls.getRightAxisDirection(1)

        # returns the controller left/right fire triggers 
        # goes from 0 to 32000 depending on how much pressure
        var leftTrigger = ctrls.getLeftTrigger(1)
        var rightTrigger = ctrls.getRightTrigger(1)

        # I just don't want console spam
        if leftTrigger > 0 or rightTrigger > 0:
            echo leftTrigger, ", ", rightTrigger

        # prints the direction of the left thumbstick 
        if leftAxis != ControllerDirection.Invalid:
            echo "Left Stick: ", leftAxis

        # prints the direction of the right thumbstick
        if rightAxis != ControllerDirection.Invalid:
            echo "Right Stick: ", rightAxis
)

game.setFps(30)
game.run()