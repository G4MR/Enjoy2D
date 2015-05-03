import sdl2, sdl2.ttf, sdl2.gfx, sdl2.mixer, sdl2.joystick
import config, sound, controllers

type
    EAppMain* = ref object of RootObj
        fps: int
        width: int
        height: int
        title: string
        running: bool
        window*: WindowPtr
        render*: RendererPtr
    EApp* = ref object of EAppMain
        after_proc: proc(app: EAppMain): void {.closure.}
        before_proc: proc(app: EAppMain): void {.closure.}
        close_proc: proc(app: EAppMain): void {.closure.}
        draw_proc: proc(app: EAppMain, render: sdl2.RendererPtr): void {.closure.}
        events_proc: proc(app: EAppMain, e: var Event): void {.closure.}
        update_proc: proc(app: EAppMain, dt: float): void {.closure.}

# -----------------------------------
# EAppMain Methods
# -----------------------------------

method getTitle*(self: EAppMain): string = self.title
method getWidth*(self: EAppMain): int = self.width
method getHeight*(self: EAppMain): int = self.height

# -----------------------------------
# EApp Methods
# -----------------------------------

method after*(self: EApp, after: proc(a: EAppMain)): void =
    self.after_proc = after

method before*(self: EApp, before: proc(a: EAppMain)): void =
    self.before_proc = before

method close*(self: EApp, close: proc(a: EAppMain)): void =
    self.close_proc = close

method draw*(self: EApp, draw: proc(app: EAppMain, render: RendererPtr)): void =
    self.draw_proc = draw

method events*(self: EApp, events: proc(app: EAppMain, e: var Event)): void =
    self.events_proc = events

method update*(self: EApp, update: proc(app: EAppMain, delta: float)): void = 
    self.update_proc = update

method setFps*(self: EApp, fps: int): void =
    self.fps = fps

method init*(self: EApp) =
    
    # sdl init
    sdl2.init(INIT_EVERYTHING)

    # init ttf
    if cfg_options.enable.ttf == true:
        ttf.ttfInit()

    # init audio
    if cfg_options.enable.audio == true:
        sound.setupMixer(cfg_options.audio.rate, cfg_options.audio.format, 
            cfg_options.audio.channels, cfg_options.audio.buffers)

    # init defaults
    self.running = true
    
    # setup window & renderer 
    self.window = createWindow(self.title,
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        cint(self.width),
        cint(self.height),
        SDL_WINDOW_SHOWN)

    if isNil(self.window):
        quit("Couldn't create window", QuitFailure)

    self.render = createRenderer(self.window, -1,
        Renderer_Accelerated or Renderer_TargetTexture)

    if isNil(self.render):
        quit("Couldn't create renderer", QuitFailure)

method run*(self: EApp): void =

    # load stuff before game loop
    if not isNil(self.before_proc):
        self.before_proc(self)

    # setup fps manager
    var fpsManager: FpsManager
    fpsManager.init()

    # setup framerate
    if self.fps > 0:
        fpsManager.setFramerate(cint(self.fps))

    # sdl defaults
    var event: Event = defaultEvent

    # Game Loop
    while self.running == true:

        # poll events
        while pollEvent(event):

            # Quit event
            if event.kind == QuitEvent:
                self.running = false

            # Handle events
            if not isNil(self.events_proc):
                self.events_proc(self, event)

        # update
        if not isNil(self.update_proc):
            let deltaTime = fpsManager.getFrameRate() / 1000
            self.update_proc(self, deltaTime)

        # clear screen
        self.render.clear()
        self.render.setDrawColor(255, 0, 0, 255)
        
        # draw to screen
        if not isNil(self.draw_proc):
            self.draw_proc(self, self.render)

        # display screen
        self.render.present()

        # delay frames if necessary
        if self.fps > 0:
            fpsManager.delay()

    if not isNil(self.close_proc):
        self.close_proc(self)

    # clean up window/render
    destroy self.render 
    destroy self.window 

    #quit libraries
    if cfg_options.enable.ttf == true:
        ttf.ttfQuit()

    if cfg_options.enable.audio == true:
        mixer.closeAudio();

    # quit sdl
    sdl2.quit()

# -----------------------------------
# Initiate Application Object
# -----------------------------------
proc initApp*(t: string, w, h: int): EApp = 
    
    # init
    let app = EApp(width: w, height: h, title: t)
    
    # setup 
    app.init()

    # return 
    result = app