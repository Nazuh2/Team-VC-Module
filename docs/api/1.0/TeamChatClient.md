# TeamChatClient
Team Voice Chat System for the client.

Methods:
- [.Init()](TeamChatClient#TeamChatClient.Init())
- [:SetSpeakingCheckInterval(Value)](TeamChatClient#TeamChatClient:SetSpeakingCheckInterval(Value))
- [:GetSpeakingCheckInterval()](TeamChatClient#TeamChatClient:GetSpeakingCheckInterval())
- [:SetSpeakingCheckInterval(Value)](TeamChatClient#TeamChatClient:SetMinRmsLevelThreshold(Value))
- [:GetMinRmsLevelThreshold()](TeamChatClient#TeamChatClient:GetMinRmsLevelThreshold())

***

## TeamChatClient.Init()

Called Upon TeamChat.Init() for the client.
Initializes the Team Voice Chat System on the Client.

***

## TeamChatClient:SetSpeakingCheckInterval(Value)

Sets the update inverval in which TeamChatClient checks if the local player
is speaking and if so, tells the server to fire the PlayerStartedSpeaking event.

Parameters:
- Value: The new value to set 'SpeakingCheckInterval' to

***

## TeamChatClient:GetSpeakingCheckInterval()

Returns SpeakingCheckInterval

***

## TeamChatClient:SetMinRmsLevelThreshold(Value)

Sets the Minimum Speaking Volume Threshold.

Parameters:
- Value: The new value to update 'MinRmsLevelThreshold' to

***

## TeamChatClient:GetMinRmsLevelThreshold()

Returns MinRmsLevelThreshold
