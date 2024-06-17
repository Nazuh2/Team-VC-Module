# Getting Started
The setup is quite simple, you just need to require TeamChat and call the `.Init()` function.

::: code-group
```lua [Server.lua]
-- Imports
local TeamChat = require(path.to.module)

-- Runtime
local TeamChatServer = TeamChat.Init()
```

```lua [Client.lua]
-- Imports
local TeamChat = require(path.to.module)

-- Runtime
local TeamChatClient = TeamChat.Init()
```

:::