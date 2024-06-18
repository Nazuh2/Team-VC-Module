-- Root
local TeamChatServer = {}

-- Services
local PlayerService = game:GetService('Players')
local RunService = game:GetService('RunService')
local TeamService = game:GetService('Teams')

-- Imports
local Libraries = script.Parent.Libraries
local AudioUtil = require(Libraries.AudioUtil)
local ConfigUtil = require(Libraries.ConfigUtil)

-- Events
local Remotes = nil
local PlayerChangedTeams = nil
local PlayerStartedSpeaking = nil
local PlayerStoppedSpeaking = nil
local TeamConfigUpdated = nil
local GetTeamConfig = nil
local GetTeamConfigs = nil

-- Local Variables
local IsInitialized = false

local CachedPlayerSpeakingStates: { [Player]: boolean } = {} -- [Player]: IsSpeaking
local TeamConfigs: { [Team]: ConfigUtil.Config } = {}

--[[ TeamChatServer:header
# TeamChatServer
Team Voice Chat System for the Server.
--]]

--[[ TeamChatServer.Init()
Called Upon TeamChat.Init() for the Server.
Initializes the Team Voice Chat System on the Server.

Returns:
- TeamChatServer: The TeamChat Server Instance
--]]

-- Functions
function TeamChatServer.Init() : typeof(TeamChatServer)
	if IsInitialized then
		warn('Attempted to reinitialize TeamChatServer!')
		return
	end
	
	if #TeamService:GetTeams() == 0 then
		error('TeamChat requires there to be at least 1 team in the game!')
		return
	end

	-- Setup Remotes
	Remotes = Instance.new('Folder')
	Remotes.Name = 'Remotes'
	Remotes.Parent = script.Parent

	PlayerChangedTeams = Instance.new('RemoteEvent')
	PlayerChangedTeams.Name = 'TeamChanged'
	PlayerChangedTeams.Parent = Remotes

	PlayerStartedSpeaking = Instance.new('RemoteEvent')
	PlayerStartedSpeaking.Name = 'StartedSpeaking'
	PlayerStartedSpeaking.Parent = Remotes

	PlayerStoppedSpeaking = Instance.new('RemoteEvent')
	PlayerStoppedSpeaking.Name = 'StoppedSpeaking'
	PlayerStoppedSpeaking.Parent = Remotes
	
	TeamConfigUpdated = Instance.new('RemoteEvent')
	TeamConfigUpdated.Name = 'TeamConfigUpdated'
	TeamConfigUpdated.Parent = Remotes
	
	GetTeamConfig = Instance.new('RemoteFunction')
	GetTeamConfig.Name = 'GetTeamConfig'
	GetTeamConfig.Parent = Remotes
	
	GetTeamConfigs = Instance.new('RemoteFunction')
	GetTeamConfigs.Name = 'GetTeamConfigs'
	GetTeamConfigs.Parent = Remotes

	local function PlayerAdded(Player: Player)
		-- Setup Audio Device Input
		local AudioDeviceInput = Player:FindFirstChildWhichIsA('AudioDeviceInput')
		if not AudioDeviceInput then
			AudioDeviceInput = Instance.new('AudioDeviceInput')

			AudioDeviceInput.Parent = Player
		end

		AudioDeviceInput.Name = 'AudioDeviceInput'
		AudioDeviceInput.Player = Player
		
		-- Setup Audio Analzyer; This allows for us to detect when a player is speaking
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
			
			--local IsOnSameTeam = PlayerWhoIsSpeaking.Team == Player.Team
			--if not IsOnSameTeam then
			--	continue
			--end

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
	--local function GetPlayerPool(Player: Player)
	--	return
	--		if Player.Team 
	--		then Player.Team:GetPlayers()
	--		else PlayerService:GetPlayers()
	--end
	
	PlayerStartedSpeaking.OnServerEvent:Connect(function(PlayerWhoIsSpeaking)
		if CachedPlayerSpeakingStates[PlayerWhoIsSpeaking] then
			return
		end
		
		--for _, Player in PlayerService:GetPlayers() do
		--	PlayerStartedSpeaking:FireClient(
		--		Player,
		--		PlayerWhoIsSpeaking
		--	)
		--end
		PlayerStartedSpeaking:FireAllClients(PlayerWhoIsSpeaking)

		CachedPlayerSpeakingStates[PlayerWhoIsSpeaking] = true
	end)

	PlayerStoppedSpeaking.OnServerEvent:Connect(function(Player, PlayerWhoStoppedSpeaking)
		if not CachedPlayerSpeakingStates[PlayerWhoStoppedSpeaking] then
			return
		end
		
		--for _, Player in PlayerService:GetPlayers() do
		--	PlayerStoppedSpeaking:FireClient(
		--		Player,
		--		PlayerWhoStoppedSpeaking
		--	)
		--end
		PlayerStoppedSpeaking:FireAllClients(PlayerWhoStoppedSpeaking)

		CachedPlayerSpeakingStates[PlayerWhoStoppedSpeaking] = false
	end)

	PlayerService.PlayerRemoving:Connect(function(Player)
		local IsSpeaking = CachedPlayerSpeakingStates[Player]
		if not IsSpeaking then
			return
		end

		PlayerStoppedSpeaking:FireAllClients(Player)
	end)
	
	------------------------------------------------
	-- Connect to Events
	------------------------------------------------
	GetTeamConfig.OnServerInvoke = function(Player: Player)
		return TeamChatServer:GetTeamConfig()
	end
	
	GetTeamConfigs.OnServerInvoke = function(Player: Player)
		return TeamConfigs
	end
	
	-- set team configs to the default config
	for _, Team in TeamService:GetTeams() do
		TeamChatServer:SetTeamConfig(Team, ConfigUtil.GetDefaultConfig())
	end
	
	-- detect when teams get added and removed
	TeamService.ChildAdded:Connect(function(Team)
		if not Team:IsA('Team') then
			return
		end
		
		TeamChatServer:SetTeamConfig(Team, ConfigUtil.GetDefaultConfig())
	end)
	
	IsInitialized = true
	return TeamChatServer
end

--[[ TeamChatServer:SetTeamConfig(Team, Config)
Updates a teams configuration

Parameters:
- Team: Team
- Config: ConfigUtil.Config

--]]

function TeamChatServer:SetTeamConfig(Team: Team, Config: ConfigUtil.Config)
	if not TeamConfigs[Team] then
		TeamConfigs[Team] = {}
	end
	local ReconciledConfig = ConfigUtil.ReconcileConfig(Config)
	
	local ConfigurationObject = Team:FindFirstChild('VoiceConfig')
	if not ConfigurationObject then
		ConfigurationObject = Instance.new('Configuration')
		ConfigurationObject.Name = 'VoiceConfig'
		
		ConfigurationObject.Parent = Team
	end
	
	local VoiceEnabledObject = ConfigurationObject:FindFirstChild('VoiceEnabled')
	if not VoiceEnabledObject then
		VoiceEnabledObject = Instance.new('BoolValue')
		VoiceEnabledObject.Name = 'VoiceEnabled'
		
		VoiceEnabledObject.Parent = ConfigurationObject
	end
	VoiceEnabledObject.Value = ReconciledConfig.VoiceEnabled
	
	local VoiceTypesObject = ConfigurationObject:FindFirstChild('VoiceTypes')
	if not VoiceTypesObject then
		VoiceTypesObject = Instance.new('Folder')
		VoiceTypesObject.Name = 'VoiceTypes'
		
		VoiceTypesObject.Parent = ConfigurationObject
	end
	
	VoiceTypesObject:ClearAllChildren()
	for _, VoiceType in ReconciledConfig.VoiceTypes do
		local VoiceTypeObject = Instance.new('Configuration')
		VoiceTypeObject.Name = VoiceType.Type
		
		for _, VoiceEffect in VoiceType.VoiceEffects do
			VoiceEffect.Object.Parent = VoiceTypeObject

			for Property, Value in pairs(VoiceEffect.Properties) do
				task.spawn(function()
					VoiceEffect.Object[Property] = Value
				end)
			end
		end
		
		VoiceTypeObject.Parent = VoiceTypesObject
	end
end

--[[ TeamChatServer:GetTeamConfig(Team)
Returns the given team's config data

Returns:
- Config: ConfigUtil.Config
--]]

function TeamChatServer:GetTeamConfig(Team: Team): ConfigUtil.Config
	return TeamConfigs[Team] or ConfigUtil.GetDefaultConfig()
end

--[[ TeamChatServer:GetTeamConfigInstance(Team)
Returns the given team's config Instance

Returns:
- Configuration: A roblox Configuration Instance
--]]

function TeamChatServer:GetTeamConfigInstance(Team: Team): Configuration
	return Team:FindFirstChild('VoiceConfig')
end

--[[ TeamChatServer:GetTeamConfigs(Team)
Returns the config data for all teams

Returns:
- { Config }: An Array of ConfigUtil.Config
--]]

function TeamChatServer:GetTeamConfigs(): { [Team]: ConfigUtil.Config }
	local Result = {}
	
	for _, Team in TeamService:GetTeams() do
		Result[Team] = self:GetTeamConfig(Team)
	end
	
	return Result
end

return TeamChatServer