<div align="center"><h1 style="text-align: right;">Team Voice Chat Module</h1></div>
<hr>

<div align='center'>
Hello! For a Brief Introduction, my name is Nazuh, and I've been working on a team voice chat module and thought I'd share it with you guys. Anothering thing to note, this is my first devforum post so any suggestions or helpful comments are extremely appreciated ♥ : ). Feel free to add me on discord, @nazuh, if you have any questions or concerns and I will try my best to get back to you.

<h4>NOTE 1:</h4> <b style="color: red;">This requires VoiceChatService.EnableDefaultVoice to be false,<br> and VoiceChatService.UseAudioApi to be set to Enabled!</b>

<h4>NOTE 2:</h4>
To disable the Overhead Voice Toggle Bubble, head over to<br> 'TextChatService.BubbleChatConfiguration' and set 'MaxDistance' to 0.<br>WARNING:<br>
THIS WILL HIDE BUBBLE CHAT!

</div>
<br>

<div align="center"><h1>Links</h1>
<hr>
<h6>
RBXM File: <a href="https://github.com/Nazuh2/Team-VC-Module/releases/latest/download/TeamChat.rbxm">Link</a>
<br>Test World: <a href="https://www.roblox.com/games/17875064977" target="_blank">Link</a>
<br>Github: <a href="https://github.com/Nazuh2/Team-VC-Module" target="_blank">Link</a>
</h6>
</div>

<div align="center">
<h1>Setup</h1>
</div>
<hr>
The setup is quite simple, just make sure you have the TeamChat module in a place accessible to both the server and the client.</br>

<div align="center">
<h4>Server:</h4>
</div>

```lua
local TeamChat = require(path.to.module)
local TeamChatServer = TeamChat.Init()
```

<div align="center">
<h4>Client:</h4>
</div>

```lua
local TeamChat = require(path.to.module)
local TeamChatClient = TeamChat.Init()

TeamChatClient.PlayerStartedSpeaking:Connect(function(Player)
    print(Player.Name .. 'Has Started Speaking!')
end)

TeamChatClient.PlayerStoppedSpeaking:Connect(function(Player)
    print(Player.Name .. 'Has Stopped Speaking!')
end)

-- How frequent your client checks if there was a change in your speaking state
-- and sends it to the server if there was a change.
-- also has a corresponding get function: GetSpeakingCheckInterval()
TeamChatClient:SetSpeakingCheckInterval(5) -- default 0.1


-- essentially just the minimum volume that is considered you speaking
-- also has a corresponding get function: GetMinRmsLevelThreshold()
TeamChatClient:SetMinRmsLevelThreshold(0.02) -- default 0.01
```
