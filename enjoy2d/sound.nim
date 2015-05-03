import sdl2, sdl2.mixer, sdl2.audio

### ------------------ ###
###      enjoy2d       ###
### ------------------ ###
### SDL2_Mixer Wrapper ###
### ------------------ ###

type Sound* = ref object of RootObj
    play : bool
    sound : ChunkPtr
    loaded : bool
    paused : bool
    volume : cint
    channel: cint
    audio_file : string

method play*(self: Sound) =
    self.play = false
    self.paused = false

method isPlaying*(self: Sound) : bool =
    self.play

method playing*(self: Sound; loop: int = 0) =
    
    # only play if we can
    if self.paused == false and mixer.playing(self.channel) == 0:
        self.channel = mixer.playChannel(self.channel, self.sound, cint(loop))
    
    # stop loop
    if mixer.playing(self.channel) == 1:
        self.paused = true

method stop*(self: Sound) =
    
    # stop channel from playing
    self.play = false
    self.paused = true
    discard mixer.haltChannel(self.channel)

method pause*(self: Sound) =

    # pause if sound is playing
    self.paused = true
    mixer.pause(self.channel)

method resume*(self: Sound) =
        
    # resume playing
    if self.paused == true:
        self.paused = false
        mixer.resume(self.channel)

method setVolume*(self: Sound; volume: int) =
    
    self.volume = cint(volume)

    if self.volume < 0:
        self.volume = 0
    elif self.volume > mixer.MIX_MAX_VOLUME:
        self.volume = 128
    else:
        discard

    discard mixer.volume(self.channel, self.volume)

method load*(self: Sound; file: string) =
    
    # not paused by default
    self.play = false
    self.paused = true

    # store file
    self.audio_file = file
    self.sound = mixer.loadWAV(self.audio_file)
    if isNil(self.sound):
        echo "Unable to load sound file: ", sdl2.getError()
        quit(QuitFailure)
    else:
        self.loaded = true
        
    # set default volume
    self.volume = cint(mixer.MIX_MAX_VOLUME)
    self.setVolume(self.volume)

method cleanUp*(self: Sound) =
    mixer.freeChunk(self.sound)

proc setupMixer*(rate : int = mixer.MIX_DEFAULT_FREQUENCY; format: uint16 = audio.AUDIO_S16MSB; 
    channels: int = mixer.MIX_DEFAULT_CHANNELS; buffers : int = 4096) =
    
    #echo(rate, " ", format, " ", channels, " ", buffers)

    if mixer.openAudio(cint(rate), format, cint(channels), cint(buffers)) != 0:
        quit("There was a problem initializing the mixer")

proc initSound*(file: string): Sound = 
    
    # create sound instance & load file
    var sound = Sound()
    sound.load(file)

    # return sound object
    return sound