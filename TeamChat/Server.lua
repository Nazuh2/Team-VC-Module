-- Root
local TeamChatServer = {}

-- Services
local PlayerService = game:GetService('Players')
local RunService = game:GetService('RunService')

-- Imports
local Libraries = script.Parent.Libraries
local AudioUtil = require(Libraries.AudioUtil)

-- Events
local Remotes = script.Parent.Remotes
local PlayerChangedTeams = Remotes.TeamChanged
local PlayerStartedSpeaking = Remotes.StartedSpeaking
local PlayerStoppedSpeaking = Remotes.StoppedSpeaking

-- Local Variables
local IsInitialized = false

local CachedPlayerSpeakingStates: { [Player]: boolean } = {} -- [Player]: IsSpeaking

-- Functions
function TeamChatServer.Init()
	if IsInitialized then
		warn('Attempted to reinitialize TeamChatServer!')
		return
	end
	
	local function PlayerAdded(Player: Player)
		-- Setup Audio Device Input
		local AudioDeviceInput = Player:FindFirstChildWhichIsA('AudioDeviceInput')
		if not AudioDeviceInput then
			AudioDeviceInput = Instance.new('AudioDeviceInput')
			
			AudioDeviceInput.Parent = Player
		end
		
		AudioDeviceInput.Name = 'AudioDeviceInput'
		AudioDeviceInput.Player = Player
		
		local AudioAnalyzer do
			AudioAnalyzer = Instance.new('AudioAnalyzer')
			AudioAnalyzer.Parent = AudioDeviceInput
		end
		
		AudioUtil.CreateWire(AudioDeviceInput, AudioAnalyzer)
		
		-- inform the client of anyone who was speaking and still is before they joined
		for PlayerWhoIsSpeaking, IsSpeaking in pairs(CachedPlayerSpeakingStates) do
			if not IsSpeaking then
				continue
			end
			
			local IsOnSameTeam = PlayerWhoIsSpeaking.Team == Player.Team
			if not IsOnSameTeam then
				continue
			end
			
			PlayerStartedSpeaking:FireClient(true, Player, PlayerWhoIsSpeaking)
		end
		
		local PreviousTeam = Player.Team
		Player:GetPropertyChangedSignal('Team'):Connect(function()
			PlayerChangedTeams:FireAllClients()
			
			---------------------------------------------------
			-- Handle case where player was talking during team change
			-- by firing PlayerStoppedSpeaking upon team change
			---------------------------------------------------
			
			-- fire PlayerStoppedTalking for previous team
			local PlayerWasSpeaking = CachedPlayerSpeakingStates[Player]
			if not PlayerWasSpeaking then
				return
			end
			
			for _, PreviousTeamMember in PreviousTeam:GetPlayers() do
				PlayerStoppedSpeaking:FireClient(PreviousTeamMember, Player)
			end
		end)
		
		-- Initial Call
		PlayerChangedTeams:FireAllClients()
	end
	
	
	PlayerService.PlayerAdded:Connect(PlayerAdded)
	for _, Player in PlayerService:GetPlayers() do
		task.spawn(PlayerAdded, Player)
	end
	
	------------------------------------------------
	-- Player Speaking Detection
	------------------------------------------------
	PlayerStartedSpeaking.OnServerEvent:Connect(function(PlayerWhoIsSpeaking)
		if CachedPlayerSpeakingStates[PlayerWhoIsSpeaking] then
			return
		end
		
		for _, Player in PlayerWhoIsSpeaking.Team:GetPlayers() do
			PlayerStartedSpeaking:FireClient(
				Player,
				PlayerWhoIsSpeaking
			)
		end
		
		CachedPlayerSpeakingStates[PlayerWhoIsSpeaking] = true
	end)
	
	PlayerStoppedSpeaking.OnServerEvent:Connect(function(Player, PlayerWhoStoppedSpeaking)
		if not CachedPlayerSpeakingStates[PlayerWhoStoppedSpeaking] then
			return
		end
		
		for _, Player in PlayerWhoStoppedSpeaking.Team:GetPlayers() do
			PlayerStoppedSpeaking:FireClient(
				Player,
				PlayerWhoStoppedSpeaking
			)
		end
		
		CachedPlayerSpeakingStates[PlayerWhoStoppedSpeaking] = false
	end)
	
	PlayerService.PlayerRemoving:Connect(function(Player)
		local IsSpeaking = CachedPlayerSpeakingStates[Player]
		if not IsSpeaking then
			return
		end
		
		PlayerStoppedSpeaking:FireAllClients(Player)
	end)
	
	return TeamChatServer
end

return TeamChatServer