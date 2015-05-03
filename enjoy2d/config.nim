type 
    AudioOptions* = ref object
        rate* : int
        format* : uint16
        buffers* : int
        channels* : int
    
    EnableOptions* = ref object
        all* : bool
        net* : bool
        ttf* : bool
        audio* : bool
        image* : bool

    ConfigOptions* = ref object
        audio* : AudioOptions
        enable* : EnableOptions

var cfg_options*    = ConfigOptions()
var audio_options*  = AudioOptions()
var enable_options* = EnableOptions()