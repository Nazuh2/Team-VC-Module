local AudioUtil = {}

--[[ AudioUtil:header
# AudioUtil
Util library for dealing with the VoiceChatService AudioAPI

Functions:
- [.CreateWire(Source, Target, Parent?)](AudioUtil.html#audioutil-createwire-source-target-parent)
- [.GetPlayersAudioDeviceInput(Player, ShouldYield)](AudioUtil.html#audioutil-getplayersaudiodeviceinput-player-shouldyield)
- [.IsVoiceEnabledForTeam(Team)](AudioUtil.html#audioutil-isvoiceenabledforteam-team)
- [.GetVoiceEffectsForTeam(Team)](AudioUtil.html#audioutil-getvoiceeffectsforteam-team)
--]]

--[[ AudioUtil.CreateWire(Source, Target, Parent?)
Creates a wire connecting an audio stream to an audio receiver

Parameters:
- Source: An Instance Emitting an Audio Stream
- Target: An Instance Receiving an Audio Stream
- Parent: Any Instance
--]]

function AudioUtil.CreateWire(Source: Instance, Target: Instance, Parent: Instance?) : Wire
	local Wire = Instance.new('Wire')
	Wire.SourceInstance = Source
	Wire.TargetInstance = Target

	Wire.Parent = Parent or Target
	
	return Wire
end

--[[ AudioUtil.GetPlayersAudioDeviceInput(Player, ShouldYield)
Returns a player's AudioDeviceInput

Parameters:
- Player: The player whose AudioDeviceInput you're trying to get
- ShouldYield: If the function should yield for up to 10 seconds while waiting for the Target Player's AudioDeviceInput to Replicate
--]]

function AudioUtil.GetPlayersAudioDeviceInput(Player: Player, ShouldYield: boolean?) : AudioDeviceInput?
	if ShouldYield then
		return Player:WaitForChild('AudioDeviceInput', 10)
	end
	
	return Player:FindFirstChild('AudioDeviceInput')
end

--[[ AudioUtil.IsVoiceEnabledForTeam(Team)
Returns true if there is no Instance parented to the team named 'VoiceDisabled', else false

Parameters:
- Team: The team to check
--]]

function AudioUtil.IsVoiceEnabledForTeam(Team: Team) : boolean
	if not Team then
		return true -- assume that voice is enabled if the there are no teams
	end
	
	return Team:FindFirstChild('VoiceDisabled') == nil
end

--[[ AudioUtil.GetVoiceEffectsForTeam(Team)
Returns the folder of VoiceEffects unter the team if it exists

Paramters:
- Team: The team with the VoiceEffects you are trying to get
--]]

function AudioUtil.GetVoiceEffectsForTeam(Team: Team): { Instance }?
	if not Team then
		return
	end

	local VoiceEffectsFolder = Team:FindFirstChild('VoiceEffects')
	if not VoiceEffectsFolder then
		return
	end

	return VoiceEffectsFolder:GetChildren()
end

return AudioUtil
