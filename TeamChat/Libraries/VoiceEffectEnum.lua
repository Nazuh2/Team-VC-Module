local VoiceEffectEnum = {}

--[[ VoiceEffectEnum:header
# VoiceEffectEnum
Util data module to help with creating voice effects


## Voice Effects Table
```lua
{
	Reverb = 'AudioReverb',
	Echo = 'AudioEcho',
	Chorus = 'AudioChorus',
	Flanger = 'AudioFlanger',
	Fader = 'AudioFader',
	Equalizer = 'AudioEqualizer',
	Compressor = 'AudioCompressor',
	Distortion = 'AudioDistortion',
	PitchShifter = 'AudioPitchShifter'
}
```

--]]

--[[ VoiceEffectEnum.GetRandom()
Returns:
- string: A random voice effect from the VoiceEffects table
--]]

local VoiceEffects = {
	Reverb = 'AudioReverb',
	Echo = 'AudioEcho',
	Chorus = 'AudioChorus',
	Flanger = 'AudioFlanger',
	Fader = 'AudioFader',
	Equalizer = 'AudioEqualizer',
	Compressor = 'AudioCompressor',
	Distortion = 'AudioDistortion',
	PitchShifter = 'AudioPitchShifter'
}

local IndexTable = {}
for Key, _ in pairs(VoiceEffects) do
	table.insert(IndexTable, Key)
end

setmetatable(
	VoiceEffectEnum, {
		__index = function(self, key)
			if VoiceEffects[key] then
				return VoiceEffects[key]
			end
			
			return self[key]
		end
	}
)

function VoiceEffectEnum.GetRandom() : string
	local RandomIndex = math.random(#IndexTable)
	local Key = IndexTable[RandomIndex]
	
	return VoiceEffects[Key]
end

return VoiceEffectEnum :: typeof(VoiceEffectEnum) & typeof(VoiceEffects)