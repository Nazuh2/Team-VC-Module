local AudioUtil = {}

function AudioUtil.CreateWire(Source: Instance, Target: Instance, Parent: Instance?)
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

return AudioUtil