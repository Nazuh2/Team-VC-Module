local ConfigUtil = {}

--[[ ConfigUtil:header
Util library to assist with creating and manipulating configs


## Config
```lua
{
	VoiceTypes: { VoiceType },
	VoiceEnabled: boolean?,
}
```

## Voice Effect
```lua
{
	Object: Instance,
	Properties: {
		[string]: any
	}
}
```

## Voice Type
```lua
{
	Type: string,
	VoiceEffects: { VoiceEffect }?
}
```

--]]

local VoiceTypeEnum = {} do
	local VoiceTypesFolder = script.Parent.Parent.VoiceTypes
	
	for _, Module in VoiceTypesFolder:GetChildren() do
		VoiceTypeEnum[Module.Name] = Module.Name
	end
end

local DefaultConfig: Config = {
	VoiceTypes = {
		{
			Type = 'TeamDirect',
			VoiceEffects = {}
		}
	},
	VoiceEnabled = true
}

export type VoiceEffect = {
	Object: Instance,
	Properties: {
		[string]: any
	}
}

export type VoiceType = {
	Type: string,
	VoiceEffects: { VoiceEffect }?
}

export type Config = {
	VoiceTypes: { VoiceType },
	VoiceEnabled: boolean?,
}

--[[ ConfigUtil.ReconcileConfig(ConfigPrototype)
Takes in the given config prototype and returns a reconciled version

Parameters:
- ConfigPrototype: The config data to reconcile against the default config

Returns:
- Config: A reconciled version of ConfigPrototype
--]]

function ConfigUtil.ReconcileConfig(ConfigPrototype: Config): Config
	for Key, Value in pairs(DefaultConfig) do
		-- if they didn't have the property, set it
		if ConfigPrototype[Key] == nil then
			ConfigPrototype[Key] = Value
			continue
		end
	end
	
	-- if they had the property, make sure it's valid
	for _, VoiceType in ConfigPrototype.VoiceTypes do
		if not VoiceTypeEnum[VoiceType.Type] then
			print('Invalid Voice Type Received! defaulting to:', DefaultConfig.VoiceTypes[1].Type)
			VoiceType.Type = DefaultConfig.VoiceTypes[1].Type
		end
	end
	
	if typeof(ConfigPrototype.VoiceEnabled) ~= 'boolean' then
		print('Invalid Voice Enabled Value Received! defaulting to:', DefaultConfig.VoiceEnabled)
		ConfigPrototype.VoiceEnabled = DefaultConfig.VoiceEnabled
	end
	
	return ConfigPrototype
end

--[[ ConfigUtil.CreateVoiceType(ModuleName, VoiceEffects)
Parameters:
- ModuleName: a name to refer to a module inside of TeamChat.VoiceTypes
- VoiceEffects: an optional field to put the voice effects for this module

Returns:
- VoiceType: The created voice type
--]]

function ConfigUtil.CreateVoiceType(ModuleName: string, VoiceEffects: {VoiceEffect}?)
	return {
		Type = ModuleName,
		VoiceEffects = VoiceEffects or {}
	} :: VoiceType
end

--[[ ConfigUtil.GetDefaultConfig()
Returns:
- Config: The Default Config used when reconciling
--]]

function ConfigUtil.GetDefaultConfig(): Config
	return table.clone(DefaultConfig)
end

--[[ ConfigUtil.CreateVoiceEffect(EffectName, EffectProperties)
Creates a VoiceEffect Object for use in a config

Parameters:
- EffectName: The name of the effect you want to create. Must refer to a valid effect name! refer to VoiceEffectEnum for more info.
- EffectProperties: A list of properties to apply to the effect upon creation. Invalid properties will error, but won't halt the effect creation process

Returns:
- VoiceEffect: A VoiceEffect object
--]]

function ConfigUtil.CreateVoiceEffect(EffectName: string, EffectProperties: { [string]: any })
	local Effect = Instance.new(EffectName)

	return {
		Object = Effect,
		Properties = EffectProperties or {}
	} :: VoiceEffect
end

--[[ ConfigUtil.GetVoiceTypeEnum()
Returns:
- Enum: a frozen version of the VoiceTypeEnum
--]]

function ConfigUtil.GetVoiceTypeEnum()
	return table.freeze(VoiceTypeEnum)
end

-- not meant to be accessed on the client
return
	(if game:GetService('RunService'):IsServer() then ConfigUtil
	else {}) :: typeof(ConfigUtil) -- for type annotations to work :)