import sdl2, sdl2.audio, sdl2.mixer
import eapp
import sound
import font
import image
import config
import keyboard
import controllers
import os, parsecfg, strutils, streams

# set defaults
enable_options.net = false
enable_options.all = false
enable_options.ttf = false
enable_options.audio = false
enable_options.image = false

audio_options.rate = mixer.MIX_DEFAULT_FREQUENCY
audio_options.format = audio.AUDIO_S16MSB
audio_options.buffers = 4096
audio_options.channels = mixer.MIX_DEFAULT_CHANNELS

# load config.ini options if available
let config_file_name = "../config.ini"
var config_file = newFIleStream(config_file_name, fmRead)

if not isNIl(config_file):
    var cfg_parser : CfgParser
    open(cfg_parser, config_file, config_file_name)

    # loop
    var current_section : string
    while true:
        var line = next(cfg_parser)
        case line.kind:
        of cfgEof:
            break;
        of cfgSectionStart:
            current_section = line.section
        of cfgKeyValuePair:
            case current_section:
            of "build":
                case line.key:
                of "enable_all":
                    enable_options.all = parseBool(line.value)
                of "enable_net":
                    enable_options.net = parseBool(line.value)
                of "enable_font":
                    enable_options.ttf = parseBool(line.value)
                of "enable_audio":
                    enable_options.audio = parseBool(line.value)
                of "enable_image":
                    enable_options.image = parseBool(line.value)
                else: discard

            of "audio":
                case line.key:
                of "rate":
                    audio_options.rate = parseInt(line.value)
                of "format":
                    audio_options.format = uint16(parseInt(line.value))
                of "channels":
                    audio_options.channels = parseInt(line.value)
                of "buffers":
                    audio_options.buffers = parseInt(line.value)
                else: discard
            else: discard
        else: discard

    close(cfg_parser)

# enable all?
if enable_options.all == true:
    enable_options.net = true
    enable_options.ttf = true
    enable_options.audio = true
    enable_options.image = true

# store options
cfg_options.audio   = audio_options
cfg_options.enable  = enable_options