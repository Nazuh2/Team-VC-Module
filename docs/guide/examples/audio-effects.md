::: code-group
```lua [Server.lua]
-- Services
local TeamService = game:GetService('Teams')

-- Imports
local TeamChat = require(path.to.module)

-- Runtime

-- Setup Team Effects
local function CreateEffectFolder(Parent: Team) : Folder
	local Folder = Instance.new('Folder')
	Folder.Name = 'VoiceEffects'
	Folder.Parent = Parent
	
	return Folder
end

local BlueTeamFolder = CreateEffectFolder(TeamService.Blue)
Instance.new('AudioEcho').Parent = BlueTeamFolder

local RedTeamFolder = CreateEffectFolder(TeamService.Red)
Instance.new('AudioReverb').Parent = RedTeamFolder

local YellowTeamFolder = CreateEffectFolder(TeamService.Yellow)
Instance.new('AudioChorus').Parent = YellowTeamFolder

local TeamChatServer = TeamChat.Init()
```
```lua [Client.lua]
-- Imports
local TeamChat = require(path.to.module)

-- Runtime
local TeamChatClient = TeamChat.Init()
```
:::