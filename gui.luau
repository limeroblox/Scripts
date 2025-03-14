------[!!Do Not Touch!!]------
-- Finally a mobile edition
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
------[!!Do Not Touch!!]------

local BlackWhiteTheme = {
    TextColor = Color3.fromRGB(255, 255, 255), -- White Text

    Background = Color3.fromRGB(0, 0, 0), -- Black Background
    Topbar = Color3.fromRGB(20, 20, 20), -- Dark Grey Topbar
    Shadow = Color3.fromRGB(10, 10, 10), -- Soft Black Shadow

    NotificationBackground = Color3.fromRGB(15, 15, 15),
    NotificationActionsBackground = Color3.fromRGB(25, 25, 25),

    TabBackground = Color3.fromRGB(20, 20, 20),
    TabStroke = Color3.fromRGB(40, 40, 40),
    TabBackgroundSelected = Color3.fromRGB(60, 60, 60),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

    ElementBackground = Color3.fromRGB(30, 30, 30),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    SecondaryElementBackground = Color3.fromRGB(20, 20, 20),
    ElementStroke = Color3.fromRGB(80, 80, 80),
    SecondaryElementStroke = Color3.fromRGB(60, 60, 60),

    SliderBackground = Color3.fromRGB(50, 50, 50),
    SliderProgress = Color3.fromRGB(200, 200, 200),
    SliderStroke = Color3.fromRGB(220, 220, 220),

    ToggleBackground = Color3.fromRGB(25, 25, 25),
    ToggleEnabled = Color3.fromRGB(255, 255, 255),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    ToggleEnabledStroke = Color3.fromRGB(255, 255, 255),
    ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
    ToggleEnabledOuterStroke = Color3.fromRGB(200, 200, 200),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),

    DropdownSelected = Color3.fromRGB(40, 40, 40),
    DropdownUnselected = Color3.fromRGB(30, 30, 30),

    InputBackground = Color3.fromRGB(20, 20, 20),
    InputStroke = Color3.fromRGB(150, 150, 150),
    PlaceholderColor = Color3.fromRGB(180, 180, 180)
}


-- Window
local Window = Rayfield:CreateWindow({
    Name = "Transfur Outbreak | Lime.Cheat V2 | Mobile Edition",
    Icon = 6472368967, 
    LoadingTitle = "Loading gui..",
    LoadingSubtitle = "only mobile compatible ui :P",
    Theme = BlackWhiteTheme, 

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, 

    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, 
       FileName = "Big Hub"
    },

    Discord = {
       Enabled = false, 
       Invite = "noinvitelink", 
       RememberJoins = true 
    },

    KeySystem = false, 
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", 
       FileName = "Key", 
       SaveKey = true, 
       GrabKeyFromSite = false, 
       Key = {"Hello"} 
    }
 })

-- Tabs 
local HumanTab = Window:CreateTab("Human", 4483362458)
local InfectedTab = Window:CreateTab("Infected", 0)
local EspTab = Window:CreateTab("Esp", 0)
local MiscTab = Window:CreateTab("Misc", 0)

local Label = HumanTab:CreateLabel("Rage", Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
-- Auto Fire Toggle
local AutoFireToggle = HumanTab:CreateToggle({
    Name = "Auto Fire",
    CurrentValue = false,
    Flag = "AutoFire",
    Callback = function(Value)
        _G.disabled = not Value
        if Value then
            spawn(function()
                local UIS = game:GetService("UserInputService")
                local Camera = workspace.CurrentCamera
                local shoot_event = game:GetService("ReplicatedStorage").PEW
                local Debris = game:GetService("Debris")
                local localplayer = game.Players.LocalPlayer
                local target_part = "Head"
                local settings = nil
                local replacement = {
                    [3] = 0.1,
                    [4] = nil,
                    [5] = nil,
                    [7] = nil
                }

                function get_weapon()
                    return localplayer.Character:FindFirstChildOfClass("Tool")
                end

                function getNearestToCursor()
                    local cursorPosition = UIS:GetMouseLocation()
                    local nearestTarget = nil

                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player.Team ~= localplayer.Team then
                            local character = player.Character
                            if character then
                                local hrp = character:FindFirstChild(target_part)
                                if hrp and character:FindFirstChildOfClass("Humanoid").Health > 0 then
                                    return hrp
                                end
                            end
                        end
                    end
                    return nil
                end

                while _G.disabled == false do
                    task.wait(_G.FireRate)
                    local weapon = get_weapon()
                    if weapon then
                        local data = weapon:FindFirstChild("SETTINGS")
                        if data then
                            settings = require(data)
                            local target = getNearestToCursor()
                            if target then
                                replacement[4] = target
                                shoot_event:FireServer(weapon, settings.COUNT, replacement[3], replacement[4], replacement[5], false, replacement[7], settings.RANGE)
                            end
                        end
                    end
                end
            end)
        end
    end,
})

-- Fire Rate Slider
local FireRateSlider = HumanTab:CreateSlider({
    Name = "Fire Rate",
    Range = {0.02, 10},
    Increment = 0.01,
    CurrentValue = 0.1,
    Flag = "FireRate",
    Callback = function(Value)
        _G.FireRate = Value
    end,
})
