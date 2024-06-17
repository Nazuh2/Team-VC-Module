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

-- Functions
function TeamChat.Init()
	local IsServer = RunService:IsServer()
	
	return require(
		if IsServer
			then script.Server
			else script.Client
	).Init()
end

return TeamChat