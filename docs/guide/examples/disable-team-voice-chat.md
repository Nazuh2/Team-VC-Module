::: code-group

```lua [Server.lua]
-- Services
local TeamService = game:GetService('Teams')

-- Imports
local TeamChat = require(path.to.module)

-- Runtime
local Team = TeamService.Team.To.Disable.Voice.For

-- doesn't have to be a configuration instance, it could be any type of instance,
-- but it's name HAS to be 'VoiceDisabled', and it HAS to be parented to the team
-- you want to disable voice chat for
local Configuration = Instance.new('Configuration')
Configuration.Name = 'VoiceDisabled'
Configuration.Parent = Team

local TeamChatServer = TeamChat.Init()
```


```lua [Client.lua]
-- Imports
local TeamChat = require(path.to.module)

-- Runtime
local TeamChatClient = TeamChat.Init()
```


:::