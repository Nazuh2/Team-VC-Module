local AudioUtil = {}

--[[ AudioUtil:header
# AudioUtil
Util library for dealing with the VoiceChatService AudioAPI
--]]

--[[ AudioUtil.CreateWire(Source, Target, Parent?)
Creates a wire connecting an audio stream to an audio receiver

Parameters:
- Source: An Instance Emitting an Audio Stream
- Target: An Instance Receiving an Audio Stream
- Parent: Any Instance

Returns:
- Wire: The wire connecting the Source to the Target
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

Returns:
- AudioDeviceInput?: The player's AudioDeviceInput, if it exists
--]]

function AudioUtil.GetPlayersAudioDeviceInput(Player: Player, ShouldYield: boolean?) : AudioDeviceInput?
	if ShouldYield then
		return Player:WaitForChild('AudioDeviceInput', 10)
	end

	return Player:FindFirstChild('AudioDeviceInput')
end

--[[ AudioUtil.GetVoiceConfigForTeam(Team)
Returns the voice config for a team if it exists

Parameters:
- Team: The team whose voice config we are trying to fetch

Return:
- Configuration?: The voice config for the team, if it exists
--]]

function AudioUtil.GetVoiceConfigForTeam(Team: Team) : Configuration?
	if not Team then
		return
	end
	
	return Team:WaitForChild('VoiceConfig')
end

--[[ AudioUtil.IsVoiceEnabledForTeam(Team)
Returns true if there is no Instance parented to the team named 'VoiceDisabled', else false

Parameters:
- Team: The team to check

Returns:
- boolean: true if voice enabled, else false
--]]

function AudioUtil.IsVoiceEnabledForTeam(Team: Team) : boolean
	if not Team then
		return true -- assume that voice is enabled if the there are no teams
	end
	
	local VoiceConfigObject = AudioUtil.GetVoiceConfigForTeam(Team)
	if not VoiceConfigObject then
		return
	end
	
	local VoiceEnabledObject = VoiceConfigObject:WaitForChild('VoiceEnabled')

	return if VoiceEnabledObject 
		then VoiceEnabledObject.Value 
		else false
end

--[[ AudioUtil.GetVoiceTypesForTeam(Team)

Parameters:
- Team: The team to get the voice types from

Returns:
- Folder: A folder containing all the voice types for the team
--]]

function AudioUtil.GetVoiceTypesFolderForTeam(Team: Team): Folder
	if not Team then
		return
	end
	
	local VoiceConfigObject = AudioUtil.GetVoiceConfigForTeam(Team)
	local VoiceTypesObject = VoiceConfigObject:WaitForChild('VoiceTypes')
	
	return VoiceTypesObject
end

--[[ AudioUtil.GetVoiceTypesAsStringArrayForTeam(Team)
Returns a string array of the voice types for the given team

Parameters:
- Team: The team to get the voice types from

Returns:
- { string }: A string array of the voice types
--]]

function AudioUtil.GetVoiceTypesAsStringArrayForTeam(Team: Team)
	if not Team then
		return {}
	end
	
	local VoiceTypeFolder = AudioUtil.GetVoiceTypesFolderForTeam(Team)
	local Result = {}
	
	for _, VoiceTypeObject in VoiceTypeFolder:GetChildren() do
		table.insert(Result, VoiceTypeObject.Name)
	end
	
	return Result
end

--[[ AudioUtil.GetVoiceEffectsForVoiceType(VoiceType)
Returns the children under the given voice type, assuming they're all valid audio effects

Parameters:
- Team: The team that holds the VoiceType instance
- VoiceType: The VoiceType with the VoiceEffects you are trying to get

Returns:
- { Instance }: A list of the Voice Effects
--]]

function AudioUtil.GetVoiceEffectsForVoiceType(Team: Team, VoiceType: string): { Instance }?
	if not Team then
		return
	end
	
	local VoiceTypesFolder = AudioUtil.GetVoiceTypesFolderForTeam(Team)
	local VoiceTypeObject = VoiceTypesFolder:FindFirstChild(VoiceType)
	if not VoiceType then
		return
	end

	return VoiceTypeObject:GetChildren()
end

--[[ AudioUtil.ConnectWiresForVoiceEffects(Source, Target, Team)
Generates wires for all the voice effects in the team's VoiceEffects folder

Parameters:
- Source: The initial audio stream, presummably an AudioDeviceInput
- Target: An AudioDeviceOutput that gets connected as the TargetInstance of the final wire
- Team: The team the LocalPlayer is current apart of

Returns:
- { Wire }: The wires generated
--]]

function AudioUtil.ConnectWires(Source: Instance, Target: Instance, Team: Team, VoiceType: string)
	local Wires = {}
	
	local VoiceEffects = AudioUtil.GetVoiceEffectsForVoiceType(Team, VoiceType)
	if not VoiceEffects then
		return
	end
	
	local LastSource = Source
	for _, Effect in VoiceEffects do
		table.insert(
			Wires,
			AudioUtil.CreateWire(
				LastSource,
				Effect,
				Target
			)
		)
		
		LastSource = Effect
	end
	
	table.insert(
		Wires,
		AudioUtil.CreateWire(
			LastSource,
			Target
		)
	)
	
	return Wires
end

return AudioUtil