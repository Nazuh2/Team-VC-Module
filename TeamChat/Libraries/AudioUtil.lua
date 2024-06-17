local AudioUtil = {}

function AudioUtil.CreateWire(Source: Instance, Target: Instance, Parent: Instance?) : Wire
	local Wire = Instance.new('Wire')
	Wire.SourceInstance = Source
	Wire.TargetInstance = Target

	Wire.Parent = Parent or Target
	
	return Wire
end

function AudioUtil.GetPlayersAudioDeviceInput(Player: Player, ShouldYield: boolean?) : AudioDeviceInput?
	if ShouldYield then
		return Player:WaitForChild('AudioDeviceInput', 10)
	end
	
	return Player:FindFirstChild('AudioDeviceInput')
end

function AudioUtil.IsVoiceEnabledForTeam(Team: Team) : boolean
	if not Team then
		return true -- assume that voice is enabled if the there are no teams
	end
	
	return Team:FindFirstChild('VoiceDisabled') == nil
end

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
