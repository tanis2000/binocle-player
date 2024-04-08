---@meta

---@class audio
audio = {}

---@class Audio
local Audio = {}

---@class AudioMusic
local AudioMusic = {}

---@class AudioSound
local AudioSound = {}

---@return Audio the audio system
function audio.new() end

---@param audio Audio the audio system to initialize
function audio.init(audio) end


---@param audio Audio the audio system
---@param filename string the filename including the path of the music to load
---@return AudioMusic the music
function audio.load_music(audio, filename) end

---@param audio Audio the audio system
---@param filename string the filename including the path of the music to load
---@return AudioMusic the music
function audio.load_music_from_assets(audio, filename) end

---@param audio Audio the audio system
---@param music AudioMusic the music to play
function audio.play_music(audio, music) end

---@param audio Audio the audio system
---@param music AudioMusic the music to play
---@param volume number the volume 0..1
function audio.set_music_volume(audio, music, volume) end

---Updates the audio stream and advances music playback for this music instance
---@param audio Audio the audio system
---@param music AudioMusic the music to play
function audio.update_music_stream(audio, music) end

---@param audio Audio the audio system
---@param filename string the filename including the path of the music to load
---@return AudioSound the sound
function audio.load_sound(audio, filename) end

---@param audio Audio the audio system
---@param filename string the filename including the path of the music to load
---@return AudioSound the sound
function audio.load_sound_from_assets(audio, filename) end

---@param sound AudioSound the sound to play
function audio.play_sound(sound) end

---@param sound AudioSound the sound to play
---@param volume number the volume 0..1
function audio.set_sound_volume(sound, volume) end

return audio