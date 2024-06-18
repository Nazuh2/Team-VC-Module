-- Allows a team to hear the opposing teams, but the opposing teams cannot hear
-- the team unless they also have EnemyDirect enabled

-- Services
local PlayerService = game:GetService('Players')

-- Imports
local Libraries = script.Parent.Parent.Libraries
local AudioUtil = require(Libraries.AudioUtil)

-- Local Variables
local LocalPlayer = PlayerService.LocalPlayer

-- Module
return function(Input: AudioDeviceInput, Output: AudioDeviceOutput, Janitor: typeof(require(Libraries.Janitor).new()))
	if Input.Player.Team == LocalPlayer.Team then
		return
	end

	for _, Wire in AudioUtil.ConnectWires(Input, Output, LocalPlayer.Team, script.Name) do
		Janitor:Add(Wire)
	end

	return true
end