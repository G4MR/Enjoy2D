import sdl2, sdl2.ttf
import helpers

type Font* = ref object of RootObj
    size: int
    text: cstring
    color: sdl2.Color
    bg_color: sdl2.Color
    width: int
    height: int
    loaded: bool
    surface: SurfacePtr
    texture: TexturePtr
    font_ptr*: FontPtr
    src_position: Rect
    dst_position: Rect
    text_type: string
    render_type: string
    wrap_length: uint32

method destroy*(self: Font) =
    destroy self.surface
    destroy self.texture

method setLoaded*(self: Font; loaded: bool) =
    self.loaded = loaded

method isLoaded*(self: Font): bool = 
    self.loaded

method setColor*(self: Font, color: sdl2.Color) =
    self.color = color

method setBgColor*(self: Font, color: sdl2.Color) =
    self.bg_color = color

method setText*(self: Font, text: cstring) =
    self.text = text

# getSurface()
# Allows multiple rendering based on type, currently doesn't support glyph/unicode
# directly.
method getSurface*(self: Font; text_type, render_type: string): SurfacePtr =
    case render_type:
        of "utf8":
            case text_type:
                of "shade":
                    ttf.renderUtf8Shaded(self.font_ptr, self.text, self.color, self.bg_color)
                of "solid":
                    ttf.renderUtf8Solid(self.font_ptr, self.text, self.color)
                of "blendwrap":
                    ttf.renderUtf8BlendedWrapped(self.font_ptr, self.text, self.color, self.wrap_length)
                else:
                    ttf.renderUtf8Blended(self.font_ptr, self.text, self.color)
        else:
            case text_type:
                of "shade":
                    ttf.renderTextShaded(self.font_ptr, self.text, self.color, self.bg_color)
                of "solid":
                    ttf.renderTextSolid(self.font_ptr, self.text, self.color)
                of "blendwrap":
                    echo "blendwrap"
                    ttf.renderTextBlendedWrapped(self.font_ptr, self.text, self.color, self.wrap_length)
                else:
                    ttf.renderTextBlended(self.font_ptr, self.text, self.color)


method createTexture*(self: Font, render: RendererPtr) =
    
    # do nothing
    if not self.isLoaded():
        return

    # create surface from font poitner
    #self.surface = ttf.renderTextBlended(self.font_ptr, self.text, self.color)
    self.surface = self.getSurface(self.text_type, self.render_type)

    if isNil(self.surface):
        self.setLoaded(false)
        # throw exception
        return

    #get size
    self.width = self.surface.w
    self.height = self.surface.h

    # get texture from surface
    self.texture = sdl2.createTextureFromSurface(render, self.surface)

    if isNil(self.texture):
        self.setLoaded(false)
        # throw exception
        return

method draw*(self: Font; render: RendererPtr; x, y: int) =

    # create texture
    self.createTexture(render)

    # do nothing if we have issues
    if not self.isLoaded():   
        return

    self.src_position = toRect(0, 0, self.width, self.height)
    self.dst_position = toRect(x, y, self.width, self.height)

    # draw font to screen
    sdl2.copy(render, self.texture, addr(self.src_position), addr(self.dst_position))

    # clean up
    self.destroy()

method init*(self: Font; text: cstring; size: int; file: cstring; color: tuple[r, g, b, a: int]; 
    bg_color: tuple[r, g, b, a: int] = (0,0,0,0); text_type: string = "", render_type: string = ""; wrap_length: uint32 = 0) =
    
    # font not loaded by default
    self.setLoaded(false)

    # set text
    self.setText(text)

    # set color
    self.setColor(toColor(color))

    # set color
    self.setBgColor(toColor(bg_color))

    self.size = size

    self.text_type = text_type

    self.render_type = render_type

    self.wrap_length = wrap_length

    # attempt to open file
    self.font_ptr = ttf.openFont(file, cint(self.size))

    # font loaded?
    if not isNil(self.font_ptr):
        self.setLoaded(true)
    else:
        echo "Couldn't load font: ", sdl2.getError()
        quit(QuitFailure)

proc initFont*(text: cstring; size: int; file: cstring; color: tuple[r, g, b, a: int]; 
    bg_color: tuple[r, g, b, a: int] = (0,0,0,0); text_type: string = ""; 
    render_type: string = "";  wrap_length: uint32 = 0): Font =
    var font = Font()
    font.init(text, size, file, color, bg_color, text_type, render_type, wrap_length)
    return font

proc initFontUtf8*(text: cstring; size: int; file: cstring; color: tuple[r, g, b, a: int]; 
    bg_color: tuple[r, g, b, a: int] = (0,0,0,0); text_type: string = ""; wrap_length: uint32 = 0): Font =
    var font = Font()
    font.init(text, size, file, color, bg_color, text_type, "utf8", wrap_length)
    return font