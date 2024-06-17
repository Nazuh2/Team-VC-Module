-- Root
local TeamChatClient = {}

-- Services
local PlayerService = game:GetService('Players')
local RunService = game:GetService('RunService')

-- Imports
local Libraries = script.Parent.Libraries
local Signal = require(Libraries.FastSignal)
local Janitor = require(Libraries.Janitor).new()
local AudioUtil = require(Libraries.AudioUtil)

-- Local Variables
local IsInitialized = false

local LocalPlayer = PlayerService.LocalPlayer

local SpeakingCheckInterval = 0.1
local MinRmsLevelThreshold = 0.01

-- Events
local Remotes = script.Parent.Remotes
local PlayerChangedTeams = Remotes.TeamChanged
local PlayerStartedSpeaking = Remotes.StartedSpeaking
local PlayerStoppedSpeaking = Remotes.StoppedSpeaking

-- Functions

--[[ TeamChatClient:header
# TeamChatClient
Team Voice Chat System for the client.

Methods:
- [.Init()](TeamChatClient#TeamChatClient.Init())
- [:SetSpeakingCheckInterval(Value)](TeamChatClient#TeamChatClient:SetSpeakingCheckInterval(Value))
- [:GetSpeakingCheckInterval()](TeamChatClient#TeamChatClient:GetSpeakingCheckInterval())
- [:SetSpeakingCheckInterval(Value)](TeamChatClient#TeamChatClient:SetMinRmsLevelThreshold(Value))
- [:GetMinRmsLevelThreshold()](TeamChatClient#TeamChatClient:GetMinRmsLevelThreshold())
--]]


--[[ TeamChatClient.Init()
Called Upon TeamChat.Init() for the client.
Initializes the Team Voice Chat System on the Client.
--]]

function TeamChatClient.Init()
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
		
		local function SetupWiring(Player: Player)
			if Player == LocalPlayer then -- just so that we won't hear ourselves talking
				return
			end
			
			local AudioDeviceInput = AudioUtil.GetPlayersAudioDeviceInput(Player, true)
			if not AudioDeviceInput then
				warn('Player doesn\'t have a valid audio device input!', Player.Name, Player.UserId)
				return
			end
			
			if Player.Team == LocalPlayer.Team then
				local Source = AudioDeviceInput
				
				local VoiceEffects = AudioUtil.GetVoiceEffectsForTeam(LocalPlayer.Team)
				if VoiceEffects then
					for _, Effect in VoiceEffects do
						Janitor:Add(
							AudioUtil.CreateWire(
								Source,
								Effect,
								AudioDeviceOutput
							)
						)
						
						Source = Effect
					end
				end
				
				Janitor:Add(
					AudioUtil.CreateWire(
						Source,
						AudioDeviceOutput
					)
				)
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
	PlayerStartedSpeaking.OnClientEvent:Connect(function(Player)
		TeamChatClient.PlayerStartedSpeaking:Fire(Player) end)
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
		
		-- don't waste networking resources if voice chat is disabled
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
			
			print('Player Started Speaking')
			PlayerStartedSpeaking:FireServer(LocalPlayer)
		else
			if not WasSpeaking then -- vice versa of above statement
				return
			end
			
			print('Player Stopped Speaking')
			PlayerStoppedSpeaking:FireServer(LocalPlayer)
		end
		
		WasSpeaking = IsSpeaking
	end)
	
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
Returns SpeakingCheckInterval
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
Returns MinRmsLevelThreshold
--]]
function TeamChatClient:GetMinRmsLevelThreshold()
	return MinRmsLevelThreshold
end

return TeamChatClient
