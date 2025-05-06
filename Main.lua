--[[
	AirHub V2.1 by Exunys © CC0 1.0 Universal (2025)
	https://github.com/Exunys
]]

--// Loaded Check
if getgenv().AirHubV2Loaded then
	return
end
getgenv().AirHubV2Loading = true

--// Cache
local game = game
local loadstring, typeof, select, next, pcall = loadstring, typeof, select, next, pcall
local tablefind, tablesort = table.find, table.sort
local mathfloor = math.floor
local stringgsub = string.gsub
local wait, spawn = task.wait, task.spawn
local osdate = os.date

--// Dependencies
local success, err = pcall(function()
	getgenv().Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub-V2/main/src/UI%20Library.lua"))()
	getgenv().ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Exunys-ESP/main/src/ESP.lua"))()
	getgenv().Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
end)

if not success then
	warn("Failed to load dependencies: " .. err)
	getgenv().AirHubV2Loading = nil
	return
end

local GUI, ESP, Aimbot = getgenv().Library, getgenv().ESP, getgenv().Aimbot

--// Variables
local MainFrame = GUI:Load({ sizex = 400, sizey = 450, theme = "AirHub" })
local ESP_Settings = ESP.Settings
local ESP_Properties = ESP.Properties
local Crosshair = ESP_Properties.Crosshair
local Aimbot_Settings = Aimbot.Settings
local Aimbot_FOV = Aimbot.FOVSettings

ESP_Settings.Enabled = false
Crosshair.Enabled = false
Aimbot_Settings.Enabled = false

local Fonts = {"UI", "System", "Plex", "Monospace"}
local TracerPositions = {"Bottom", "Center", "Mouse"}
local HealthBarPositions = {"Top", "Bottom", "Left", "Right"}

--// Utility Functions
local function AddToggles(section, settings, prefix, exceptions)
	exceptions = exceptions or {}
	for key, value in next, settings do
		if typeof(value) == "boolean" and not tablefind(exceptions, key) then
			section:Toggle({
				Name = stringgsub(key, "(%l)(%u)", "%1 %2"),
				Flag = prefix .. key,
				Default = value,
				Callback = function(v)
					settings[key] = v
				end
			})
		end
	end
end

local function AddColorPickers(section, settings, prefix, exceptions)
	exceptions = exceptions or {}
	for key, value in next, settings do
		if typeof(value) == "Color3" and not tablefind(exceptions, key) then
			section:ColorPicker({
				Name = stringgsub(key, "(%l)(%u)", "%1 %2"),
				Flag = prefix .. key,
				Default = value,
				Callback = function(v)
					settings[key] = v
				end
			})
		end
	end
end

--// Tabs
local CombatTab = MainFrame:Tab("Combat")
local VisualsTab = MainFrame:Tab("Visuals")
local SettingsTab = MainFrame:Tab("Settings")

--// Combat Tab
local AimbotSection = CombatTab:Section({ Name = "Aimbot", Side = "Left" })
local AimbotFOVSection = CombatTab:Section({ Name = "FOV", Side = "Right" })

AimbotSection:Toggle({
	Name = "Enabled",
	Flag = "Aimbot_Enabled",
	Default = Aimbot_Settings.Enabled,
	Callback = function(v)
		Aimbot_Settings.Enabled = v
	end
})

AddToggles(AimbotSection, Aimbot_Settings, "Aimbot_", {"Enabled", "Sensitivity", "LockMode", "LockPart", "TriggerKey"})
AddColorPickers(AimbotSection, Aimbot_Settings, "Aimbot_")

AimbotSection:Slider({
	Name = "Sensitivity",
	Flag = "Aimbot_Sensitivity",
	Min = 0,
	Max = 100,
	Default = Aimbot_Settings.Sensitivity * 100,
	Callback = function(v)
		Aimbot_Settings.Sensitivity = v / 100
	end
})

AimbotSection:Dropdown({
	Name = "Lock Mode",
	Flag = "Aimbot_LockMode",
	Content = {"CFrame", "mousemoverel"},
	Default = Aimbot_Settings.LockMode == 1 and "CFrame" or "mousemoverel",
	Callback = function(v)
		Aimbot_Settings.LockMode = v == "CFrame" and 1 or 2
	end
})

AimbotSection:Dropdown({
	Name = "Lock Part",
	Flag = "Aimbot_LockPart",
	Content = {"Head", "HumanoidRootPart", "Torso"},
	Default = Aimbot_Settings.LockPart,
	Callback = function(v)
		Aimbot_Settings.LockPart = v
	end
})

AimbotSection:Keybind({
	Name = "Trigger Key",
	Flag = "Aimbot_TriggerKey",
	Default = Aimbot_Settings.TriggerKey,
	Callback = function(k)
		Aimbot_Settings.TriggerKey = k
	end
})

local UserBox = AimbotSection:Box({
	Name = "Player Name",
	Flag = "Aimbot_PlayerName",
	Placeholder = "Enter username"
})

AimbotSection:Button({
	Name = "Blacklist Player",
	Callback = function()
		pcall(Aimbot.Blacklist, Aimbot, GUI.flags["Aimbot_PlayerName"])
		UserBox:Set("")
	end
})

AimbotSection:Button({
	Name = "Whitelist Player",
	Callback = function()
		pcall(Aimbot.Whitelist, Aimbot, GUI.flags["Aimbot_PlayerName"])
		UserBox:Set("")
	end
})

AddToggles(AimbotFOVSection, Aimbot_FOV, "Aimbot_FOV_")
AddColorPickers(AimbotFOVSection, Aimbot_FOV, "Aimbot_FOV_")

AimbotFOVSection:Slider({
	Name = "Radius",
	Flag = "Aimbot_FOV_Radius",
	Min = 0,
	Max = 500,
	Default = Aimbot_FOV.Radius,
	Callback = function(v)
		Aimbot_FOV.Radius = v
	end
})

AimbotFOVSection:Slider({
	Name = "Transparency",
	Flag = "Aimbot_FOV_Transparency",
	Min = 1,
	Max = 10,
	Default = Aimbot_FOV.Transparency * 10,
	Callback = function(v)
		Aimbot_FOV.Transparency = v / 10
	end
})

--// Visuals Tab
local ESPSection = VisualsTab:Section({ Name = "ESP", Side = "Left" })
local CrosshairSection = VisualsTab:Section({ Name = "Crosshair", Side = "Right" })

ESPSection:Toggle({
	Name = "Enabled",
	Flag = "ESP_Enabled",
	Default = ESP_Settings.Enabled,
	Callback = function(v)
		ESP_Settings.Enabled = v
	end
})

AddToggles(ESPSection, ESP_Settings, "ESP_", {"LoadConfigOnLaunch"})
AddColorPickers(ESPSection, ESP_Properties.ESP, "ESP_")

ESPSection:Dropdown({
	Name = "Text Font",
	Flag = "ESP_TextFont",
	Content = Fonts,
	Default = Fonts[ESP_Properties.ESP.Font + 1],
	Callback = function(v)
		ESP_Properties.ESP.Font = Drawing.Fonts[v]
	end
})

ESPSection:Slider({
	Name = "Text Transparency",
	Flag = "ESP_TextTransparency",
	Min = 1,
	Max = 10,
	Default = ESP_Properties.ESP.Transparency * 10,
	Callback = function(v)
		ESP_Properties.ESP.Transparency = v / 10
	end
})

CrosshairSection:Toggle({
	Name = "Enabled",
	Flag = "Crosshair_Enabled",
	Default = Crosshair.Enabled,
	Callback = function(v)
		Crosshair.Enabled = v
	end
})

AddToggles(CrosshairSection, Crosshair, "Crosshair_", {"Enabled"})
AddColorPickers(CrosshairSection, Crosshair, "Crosshair_")

CrosshairSection:Slider({
	Name = "Size",
	Flag = "Crosshair_Size",
	Min = 1,
	Max = 20,
	Default = Crosshair.Size,
	Callback = function(v)
		Crosshair.Size = v
	end
})

CrosshairSection:Slider({
	Name = "Transparency",
	Flag = "Crosshair_Transparency",
	Min = 1,
	Max = 10,
	Default = Crosshair.Transparency * 10,
	Callback = function(v)
		Crosshair.Transparency = v / 10
	end
})

--// Settings Tab
local ConfigSection = SettingsTab:Section({ Name = "Configuration", Side = "Left" })
local InfoSection = SettingsTab:Section({ Name = "Information", Side = "Right" })

ConfigSection:Keybind({
	Name = "Toggle GUI",
	Flag = "UI_Toggle",
	Default = Enum.KeyCode.RightShift,
	Callback = function(_, key)
		if not key then
			GUI:Close()
		end
	end
})

ConfigSection:Button({
	Name = "Unload Script",
	Callback = function()
		GUI:Unload()
		ESP:Exit()
		Aimbot:Exit()
		getgenv().AirHubV2Loaded = nil
	end
})

local ConfigDropdown = ConfigSection:Dropdown({
	Name = "Configs",
	Flag = "Config_Dropdown",
	Content = GUI:GetConfigs()
})

ConfigSection:Box({
	Name = "Config Name",
	Flag = "Config_Name",
	Placeholder = "Enter config name"
})

ConfigSection:Button({
	Name = "Load Config",
	Callback = function()
		GUI:LoadConfig(GUI.flags["Config_Dropdown"])
	end
})

ConfigSection:Button({
	Name = "Save Config",
	Callback = function()
		GUI:SaveConfig(GUI.flags["Config_Dropdown"] or GUI.flags["Config_Name"])
		ConfigDropdown:Refresh(GUI:GetConfigs())
	end
})

ConfigSection:Button({
	Name = "Delete Config",
	Callback = function()
		GUI:DeleteConfig(GUI.flags["Config_Dropdown"])
		ConfigDropdown:Refresh(GUI:GetConfigs())
	end
})

InfoSection:Label("AirHub V2.1 by Exunys")
InfoSection:Button({
	Name = "Copy GitHub",
	Callback = function()
		setclipboard("https://github.com/Exunys")
	end
})
InfoSection:Label("© 2022 - " .. osdate("%Y"))
InfoSection:Button({
	Name = "Copy Discord",
	Callback = function()
		setclipboard("https://discord.gg/Ncz3H3quUZ")
	end
})

--// Initialization
ESP:Load()
Aimbot:Load()
getgenv().AirHubV2Loaded = true
getgenv().AirHubV2Loading = nil
GUI:Close()
