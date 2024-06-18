--[[
	Author: Nazuh (https://www.roblox.com/users/5545813473/profile)
]]

-- NOTE 1:
--	THIS REQUIRES VoiceChatService 'EnableDefaultVoice' to be 'False',
--	and 'UseAudioApi' to be 'Enabled'

-- NOTE 2:
-- To disable the overhead Voice Chat Bubble, go to TextChatService -> BubbleChatConfiguration
-- and set 'MaxDistance' to 0.
-- 	WARNING: This not only disables the Voice Chat Bubble, but also bubble chat in general

-- Root
local TeamChat = {}

-- Services
local RunService = game:GetService('RunService')
local VoiceChatService = game:GetService('VoiceChatService')

-- Local Variables
local TeamChatInstance = nil

-- Types
type TeamChatServer = typeof(require(script.Server).Init())
type TeamChatClient = typeof(require(script.Client).Init())

-- Functions
function TeamChat.Init(): TeamChatServer -- not sure if there's a way to determine if the script is a local script or server script to determine the type to send
	if TeamChatInstance then
		return TeamChatInstance
	end

	local IsServer = RunService:IsServer()
	local Required = if IsServer
		then require(script.Server)
		else require(script.Client)

	TeamChatInstance = Required

	return Required.Init()
end

return TeamChat