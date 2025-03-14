------[!!Do Not Touch!!]------
-- Finally a mobile edition
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
------[!!Do Not Touch!!]------

local HackerTheme = {
    TextColor = Color3.fromRGB(0, 255, 0), -- Neon Green Text

    Background = Color3.fromRGB(0, 0, 0), -- Pure Black Background
    Topbar = Color3.fromRGB(0, 0, 0), -- Black Topbar
    Shadow = Color3.fromRGB(0, 0, 0), -- No Shadow (Fully Black)

    NotificationBackground = Color3.fromRGB(0, 0, 0),
    NotificationActionsBackground = Color3.fromRGB(0, 0, 0),

    TabBackground = Color3.fromRGB(0, 0, 0),
    TabStroke = Color3.fromRGB(0, 0, 0),
    TabBackgroundSelected = Color3.fromRGB(0, 0, 0),
    TabTextColor = Color3.fromRGB(0, 255, 0),
    SelectedTabTextColor = Color3.fromRGB(0, 255, 0),

    ElementBackground = Color3.fromRGB(0, 0, 0),
    ElementBackgroundHover = Color3.fromRGB(0, 0, 0),
    SecondaryElementBackground = Color3.fromRGB(0, 0, 0),
    ElementStroke = Color3.fromRGB(0, 255, 0),
    SecondaryElementStroke = Color3.fromRGB(0, 0, 0),

    SliderBackground = Color3.fromRGB(0, 0, 0),
    SliderProgress = Color3.fromRGB(0, 255, 0),
    SliderStroke = Color3.fromRGB(0, 255, 0),

    ToggleBackground = Color3.fromRGB(0, 0, 0),
    ToggleEnabled = Color3.fromRGB(0, 255, 0),
    ToggleDisabled = Color3.fromRGB(0, 0, 0),
    ToggleEnabledStroke = Color3.fromRGB(0, 255, 0),
    ToggleDisabledStroke = Color3.fromRGB(0, 0, 0),
    ToggleEnabledOuterStroke = Color3.fromRGB(0, 255, 0),
    ToggleDisabledOuterStroke = Color3.fromRGB(0, 0, 0),

    DropdownSelected = Color3.fromRGB(0, 0, 0),
    DropdownUnselected = Color3.fromRGB(0, 0, 0),

    InputBackground = Color3.fromRGB(0, 0, 0),
    InputStroke = Color3.fromRGB(0, 255, 0),
    PlaceholderColor = Color3.fromRGB(0, 255, 0)
}


-- Window
local Window = Rayfield:CreateWindow({
    Name = "Transfur Outbreak | Lime.Cheat V2 | Mobile Edition",
    Icon = 0, 
    LoadingTitle = "Loading gui..",
    LoadingSubtitle = "only mobile compatible ui :P",
    Theme = HackerTheme, 

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
local Tab = Window:CreateTab("Human", 4483362458)

-- Auto Fire Toggle
local AutoFireToggle = Tab:CreateToggle({
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
local FireRateSlider = Tab:CreateSlider({
    Name = "Fire Rate",
    Range = {0.02, 10},
    Increment = 0.01,
    CurrentValue = 0.1,
    Flag = "FireRate",
    Callback = function(Value)
        _G.FireRate = Value
        print("Fire Rate set to:", Value)
    end,
})

-- Fade On Death Toggle
local FadeOnDeath = Tab:CreateToggle({
    Name = "Fade On Death",
    CurrentValue = false,
    Flag = "FadeOnDeath",
    Callback = function(Value)
        _G.ThanosSnap = Value
    end,
})
