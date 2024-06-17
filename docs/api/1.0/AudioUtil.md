# AudioUtil
Util library for dealing with the VoiceChatService AudioAPI

Functions:
- [.CreateWire(Source, Target, Parent?)](AudioUtil.html#audioutil-createwire-source-target-parent)
- [.GetPlayersAudioDeviceInput(Player, ShouldYield)](AudioUtil.html#audioutil-getplayersaudiodeviceinput-player-shouldyield)
- [.IsVoiceEnabledForTeam(Team)](AudioUtil.html#audioutil-isvoiceenabledforteam-team)
- [.GetVoiceEffectsForTeam(Team)](AudioUtil.html#audioutil-getvoiceeffectsforteam-team)

***

## AudioUtil.CreateWire(Source, Target, Parent?)

Creates a wire connecting an audio stream to an audio receiver

Parameters:
- Source: An Instance Emitting an Audio Stream
- Target: An Instance Receiving an Audio Stream
- Parent: Any Instance

***

## AudioUtil.GetPlayersAudioDeviceInput(Player, ShouldYield)

Returns a player's AudioDeviceInput

Parameters:
- Player: The player whose AudioDeviceInput you're trying to get
- ShouldYield: If the function should yield for up to 10 seconds while waiting for the Target Player's AudioDeviceInput to Replicate

***

## AudioUtil.IsVoiceEnabledForTeam(Team)

Returns true if there is no Instance parented to the team named 'VoiceDisabled', else false

Parameters:
- Team: The team to check

***

## AudioUtil.GetVoiceEffectsForTeam(Team)

Returns the folder of VoiceEffects unter the team if it exists

Paramters:
- Team: The team with the VoiceEffects you are trying to get
