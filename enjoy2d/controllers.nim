import sdl2, sdl2.joystick, sdl2.gamecontroller
import sequtils, tables

type Controller* = ref object of RootObj
    connected : Table[int, GameControllerPtr]

type ControllerDirection* = enum
    North, NorthWest, NorthEast,
    South, SouthWest, SouthEast,
    East, West, Invalid

type ControllerButtons* = enum
    BTN_A = SDL_CONTROLLER_BUTTON_A,
    BTN_B = SDL_CONTROLLER_BUTTON_B,
    BTN_X = SDL_CONTROLLER_BUTTON_X,
    BTN_Y = SDL_CONTROLLER_BUTTON_Y,
    BTN_BACK = SDL_CONTROLLER_BUTTON_BACK,
    BTN_GUIDE = SDL_CONTROLLER_BUTTON_GUIDE,
    BTN_START = SDL_CONTROLLER_BUTTON_START,
    BTN_LEFTSTICK = SDL_CONTROLLER_BUTTON_LEFTSTICK,
    BTN_RIGHTSTICK = SDL_CONTROLLER_BUTTON_RIGHTSTICK,
    BTN_LEFTSHOULDER = SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
    BTN_RIGHTSHOULDER = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
    BTN_DPAD_UP = SDL_CONTROLLER_BUTTON_DPAD_UP,
    BTN_DPAD_DOWN = SDL_CONTROLLER_BUTTON_DPAD_DOWN,
    BTN_DPAD_LEFT = SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    BTN_DPAD_RIGHT = SDL_CONTROLLER_BUTTON_DPAD_RIGHT

method closeControllers*(self: Controller) =
    
    if self.connected.len > 0:
        for i, ctrl in self.connected:
            gamecontroller.close(ctrl)

method getConnectedControllers*(self: Controller) =
    
    # close any opened controllers
    self.closeControllers()

    # new table
    self.connected = initTable[int, GameControllerPtr]()

    # get currently connected
    let connected = joystick.numJoysticks()

    # add controllers to connected table
    for i in 0..connected-1:
        var ctrl = gamecontroller.gameControllerOpen(i)
        if not isNil(ctrl):
            self.connected.add(i + 1, ctrl)
            echo "Connected controller: ", i + 1

method getButton*(self: Controller, ctrl: int, btn: ControllerButtons): bool =
    if self.connected.hasKey(ctrl):
        if gamecontroller.getButton(self.connected[ctrl], GameControllerButton(btn)) == 1:
            true
        else:
            false
    else:
        false

method getLeftTrigger*(self: Controller, ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_TRIGGERLEFT)
    else:
        0

method getRightTrigger*(self: Controller, ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_TRIGGERRIGHT)
    else:
        0

method getLeftXAxis*(self: Controller; ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_LEFTX)
    else:
        0

method getLeftYAxis*(self: Controller; ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_LEFTY)
    else:
        0

method getRightXAxis*(self: Controller; ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_RIGHTX)
    else:
        0

method getRightYAxis*(self: Controller; ctrl: int): int =
    if self.connected.hasKey(ctrl):
        gamecontroller.getAxis(self.connected[ctrl], SDL_CONTROLLER_AXIS_RIGHTY)
    else:
        0

method getDirection*(self: Controller; x, y: int): ControllerDirection =

    # north
    if x < 8000 and x >= -8000 and y <= -16000:
        return ControllerDirection.North

    # north east
    if x >= 13000 and y <= -13000:
        return ControllerDirection.NorthEast

    # north west
    if x <= -13000 and y <= -13000:
        return ControllerDirection.NorthWest

    # south
    if x <= 8000 and x >= -8000 and y >= 16000:
        return ControllerDirection.South

    # south east
    if x >= 13000 and y >= 13000:
        return ControllerDirection.SouthEast

    # south west
    if x <= -13000 and y >= 13000:
        return ControllerDirection.SouthWest

    # east
    if x >= 16000 and y <= 8000 and y >= -8000:
        return ControllerDirection.East

    # west
    if x <= -16000 and y <= 8000 and y >= -8000:
        return ControllerDirection.West

    return ControllerDirection.Invalid

method getLeftAxisDirection*(self: Controller; ctrl: int): ControllerDirection =
    
    var x = self.getLeftXAxis(ctrl)
    var y = self.getLeftYAxis(ctrl)

    return self.getDirection(x, y)

method getRightAxisDirection*(self: Controller; ctrl: int): ControllerDirection =
    
    var x = self.getRightXAxis(ctrl)
    var y = self.getRightYAxis(ctrl)

    return self.getDirection(x, y)