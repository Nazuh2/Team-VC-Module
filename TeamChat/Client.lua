-- Root
local TeamChatClient = {}

-- Services
local PlayerService = game:GetService('Players')
local RunService = game:GetService('RunService')
local TeamService = game:GetService('Teams')

-- Imports
local Libraries = script.Parent.Libraries
local Signal = require(Libraries.FastSignal)
local Janitor = require(Libraries.Janitor).new()
local AudioUtil = require(Libraries.AudioUtil)

-- Local Variables
local SpeakingCheckInterval = 0.1
local MinRmsLevelThreshold = 0.01

local LocalPlayer = PlayerService.LocalPlayer
local IsInitialized = false

local VoiceTypesModuleFolder = script.Parent.VoiceTypes
local CachedVoiceTypeModules: { [string]: () -> (boolean?) } = {}
local PlayersTheClientCanHear: { [Player]: true } = {}

-- Events
local Remotes = script.Parent.Remotes
local PlayerChangedTeams = Remotes:WaitForChild('TeamChanged')
local PlayerStartedSpeaking = Remotes:WaitForChild('StartedSpeaking')
local PlayerStoppedSpeaking = Remotes:WaitForChild('StoppedSpeaking')
local TeamConfigUpdated = Remotes:WaitForChild('TeamConfigUpdated')
local GetTeamConfig = Remotes:WaitForChild('GetTeamConfig')
local GetTeamConfigs = Remotes:WaitForChild('GetTeamConfigs')

-- Functions

--[[ TeamChatClient:header
# TeamChatClient
Team Voice Chat System for the client.

--[[ TeamChatClient.Init()
Called Upon TeamChat.Init() for the client.
Initializes the Team Voice Chat System on the Client.
--]]

function TeamChatClient.Init(): typeof(TeamChatClient)
	if IsInitialized then
		warn('Attempted to reinitialize TeamChatClient!')
		return
	end

	-- Setup Audio Device Ouput to listen directly to the other players
	local AudioDeviceOutput do
		AudioDeviceOutput = Instance.new('AudioDeviceOutput')
		AudioDeviceOutput.Player = LocalPlayer

		AudioDeviceOutput.Parent = workspace.CurrentCamera
	end

	local function EventReceived()
		Janitor:Cleanup()
		AudioDeviceOutput:ClearAllChildren()
		table.clear(PlayersTheClientCanHear)
		
		local TeamVoiceTypes = AudioUtil.GetVoiceTypesFolderForTeam(LocalPlayer.Team)

		local function SetupWiring(Player: Player)
			if Player == LocalPlayer then -- just so that we won't hear ourselves talking
				return
			end

			local AudioDeviceInput = AudioUtil.GetPlayersAudioDeviceInput(Player, true)
			if not AudioDeviceInput then
				warn('Player doesn\'t have a valid audio device input!', Player.Name, Player.UserId)
				return
			end
			
			for _, VoiceType in TeamVoiceTypes:GetChildren() do
				local ModuleName = VoiceType.Name
				
				-- get module from cache or add to cache if it isn't there, then require and call
				if not CachedVoiceTypeModules[ModuleName] then
					local VoiceTypeModule = VoiceTypesModuleFolder:FindFirstChild(ModuleName)
					if not VoiceTypeModule then
						warn('Attempted to activate unknown voice type!')
						continue
					end
					
					CachedVoiceTypeModules[ModuleName] = require(VoiceTypeModule)
				end
				
				local Result = CachedVoiceTypeModules[ModuleName](
					AudioDeviceInput,
					AudioDeviceOutput,
					Janitor
				)
				
				print(`RESULT FOR {Player.Name}: {Result}`)
				
				-- if a VoiceType module returns nil, it means it didn't affect
				-- whether the local client can hear the given player or not, so
				-- we won't change it from the previous value it was set to if it
				-- was set.
				if Result == nil then
					continue
				end
				
				PlayersTheClientCanHear[Player.UserId] = true
			end
		end
		
		if not AudioUtil.IsVoiceEnabledForTeam(LocalPlayer.Team) then
			return
		end

		for _, Player in PlayerService:GetPlayers() do
			task.spawn(SetupWiring, Player)
		end
	end

	-- Setup Signals
	TeamChatClient.PlayerStartedSpeaking = Signal.new()
	TeamChatClient.PlayerStoppedSpeaking = Signal.new()
	TeamChatClient.PlayerMuteStateChanged = Signal.new()

	-- Connect events
	PlayerChangedTeams.OnClientEvent:Connect(EventReceived)
	TeamConfigUpdated.OnClientEvent:Connect(EventReceived)
	
	PlayerStartedSpeaking.OnClientEvent:Connect(function(Player) 
		local IsLocalPlayer = Player.UserId == LocalPlayer.UserId
		local CanBeHeard = PlayersTheClientCanHear[Player.UserId] == true
		
		if CanBeHeard or IsLocalPlayer then
			TeamChatClient.PlayerStartedSpeaking:Fire(Player)
		end
	end)
	PlayerStoppedSpeaking.OnClientEvent:Connect(function(Player)
		TeamChatClient.PlayerStoppedSpeaking:Fire(Player) end)

	local WasSpeaking = false

	local ElapsedTimeSinceLastInterval = 0
	RunService.Heartbeat:Connect(function(dt)
		ElapsedTimeSinceLastInterval += dt
		if ElapsedTimeSinceLastInterval < SpeakingCheckInterval then
			return
		end
		ElapsedTimeSinceLastInterval = 0

		-- don't waste networking resources if voice chat is disabled for the player's team
		if not AudioUtil.IsVoiceEnabledForTeam(LocalPlayer.Team) then
			return
		end

		local AudioDeviceInput = AudioUtil.GetPlayersAudioDeviceInput(LocalPlayer)
		local AudioAnalyzer = AudioDeviceInput:WaitForChild('AudioAnalyzer')

		local IsSpeaking = AudioAnalyzer.RmsLevel >= MinRmsLevelThreshold

		if IsSpeaking then
			if WasSpeaking then -- if they already were speaking, meaning we already notified the server, don't notify the server again
				return
			end

			PlayerStartedSpeaking:FireServer(LocalPlayer)
		else
			if not WasSpeaking then 
				return
			end
			
			PlayerStoppedSpeaking:FireServer(LocalPlayer)
		end

		WasSpeaking = IsSpeaking
	end)
	
	-- Listen to changes in teams to detect changes with team voice configs
	local function OnTeamAdded(Team: Team)
		if not Team:IsA('Team') then
			return
		end
		
		-- Setup Connections for Team
		Team.ChildAdded:Connect(function(Child)
			if Child.Name ~= 'VoiceConfig' then
				return
			end 
			
			if not Child:IsA('Configuration') then
				return
			end
			
			-- Setup connections to listen for changes in
			-- the team's voice config
			local VoiceTypes, VoiceEnabled, VoiceEffects = 
				Child:WaitForChild('VoiceTypes'),
				Child:WaitForChild('VoiceEnabled'),
				Child:WaitForChild('VoiceEffects')
			
			VoiceTypes.ChildAdded:Connect(EventReceived)
			VoiceTypes.ChildRemoved:Connect(EventReceived)
			
			VoiceEnabled.Changed:Connect(EventReceived)
			
			VoiceEffects.ChildAdded:Connect(EventReceived)
			VoiceEffects.ChildRemoved:Connect(EventReceived)
		end)
	end
	
	TeamService.ChildAdded:Connect(OnTeamAdded)

	-- Inital Call
	EventReceived()

	return TeamChatClient
end

--[[ TeamChatClient:SetSpeakingCheckInterval(Value)
Sets the update inverval in which TeamChatClient checks if the local player
is speaking and if so, tells the server to fire the PlayerStartedSpeaking event.

Parameters:
- Value: The new value to set 'SpeakingCheckInterval' to
--]]

function TeamChatClient:SetSpeakingCheckInterval(Value: number)
	assert(typeof(Value) == 'number', 'SpeakingCheckInterval must be a valid number!')

	SpeakingCheckInterval = Value
end

--[[ TeamChatClient:GetSpeakingCheckInterval()
Returns:
- number: SpeakingCheckInterval
--]]

function TeamChatClient:GetSpeakingCheckInterval()
	return SpeakingCheckInterval
end

--[[ TeamChatClient:SetMinRmsLevelThreshold(Value)
Sets the Minimum Speaking Volume Threshold.

Parameters:
- Value: The new value to update 'MinRmsLevelThreshold' to
--]]

function TeamChatClient:SetMinRmsLevelThreshold(Value: number)
	assert(typeof(Value) == 'number', 'MinRmsLevelThreshold must be a valid number!')

	MinRmsLevelThreshold = Value
end


--[[ TeamChatClient:GetMinRmsLevelThreshold()
Returns:
- number: MinRmsLevelThreshold
--]]

function TeamChatClient:GetMinRmsLevelThreshold()
	return MinRmsLevelThreshold
end

return TeamChatClient