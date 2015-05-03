import sdl2, sdl2.image as img
import helpers

import typetraits

type Image* = ref object
    rw*: RWopsPtr
    format: string
    loaded: bool
    surface: SurfacePtr
    texture: TexturePtr
    src_rect*: Rect
    dst_rect*: Rect

method getFormat*(self: Image): string =
    if isNil(self.format):
        "none"
    else:
        self.format

method isLoaded*(self: Image): bool = 
    self.loaded

method getWidth*(self: Image): int =
    int(self.src_rect.w)

method getHeight*(self: Image): int =
    int(self.src_rect.h)

method setDimensions*(self: Image; src, dst: Rect) =
    self.src_rect = src
    self.dst_rect = dst

method setDimensions*(self: Image; src, dst: tuple[x, y, w, h: int]) =
    self.setDimensions(toRect(src), toRect(dst))

method setXY*(self: Image; x, y: int) =
    self.dst_rect.x = cint(x)
    self.dst_rect.y = cint(y)

    #if width/height isn't set, set them 
    if self.dst_rect.w == 0:
        self.dst_rect.w = cint(self.getWidth())

    if self.dst_rect.h == 0:
        self.dst_rect.h = cint(self.getHeight())

method setSrc*(self: Image, src: Rect) =
    self.src_rect = src

method setSrc*(self: Image, src: tuple[x, y, w, h: int]) =
    self.setSrc(toRect(src))

method setSrc*(self: Image, sx, sy, sw, sh: int) =
    self.setSrc((sx, sy, sw, sh))

method setSrcXY*(self: Image; src: tuple[x, y, w, h: int]; dst: tuple[x, y: int]) =
    self.setSrc(src)
    self.dst_rect = toRect(dst.x, dst.y, src.w, src.h)

method setSrcXY*(self: Image; sx, sy, sw, sh, dx, dy: int) =
    self.setSrcXY((sx, sy, sw, sh), (dx, dy))

method setDst*(self: Image, dst: Rect) =
    self.dst_rect = dst

method setDst*(self: Image, dst: tuple[x, y, w, h: int]) =
    self.setDst(toRect(dst))

method load*(self: Image, file: cstring, render: RendererPtr) =

    self.loaded = false
    self.rw = sdl2.rwFromFile(file, "rb")

    if not isNIl(self.rw):
        if img.isGIF(self.rw) == 1:
            self.format = "gif"
        elif img.isPNG(self.rw) == 1:
            self.format = "png"
        elif img.isJPG(self.rw) == 1:
            self.format = "jpg"
        elif img.isBMP(self.rw) == 1:
            self.format = "bmp"
        elif img.isWEBP(self.rw) == 1:
            self.format = "webp"
        else:
            self.format = nil

    if not isNil(self.format):

        # try loading surface
        self.surface = img.load_RW(self.rw, 1)
        if isNil(self.surface):
            #throw exception
            return

        #try loading texture
        self.texture = sdl2.createTextureFromSurface(render, self.surface)
        if isNil(self.texture):
            #throw exception
            return

        self.loaded = true

method draw*(self: Image, render: RendererPtr) =
    
    if isNil(self.texture):
        return

    # draw font to screen
    sdl2.copy(render, self.texture, addr(self.src_rect), addr(self.dst_rect))

# Release any resources used by the stream and free RWopsPtr memory
method close*(self: Image) =

    if not isNil(self.surface):
        destroy self.surface

    if not isNil(self.texture):
        destroy self.texture

proc loadImage*(file: cstring, render: RendererPtr): Image = 
    var img = Image()
    img.load(file, render)
    result = img