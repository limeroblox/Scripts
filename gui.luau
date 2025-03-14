------[!!Do Not Touch!!]------
-- Finally a mobile edition
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
------[!!Do Not Touch!!]------

local TransfurTheme = {
    TextColor = Color3.fromRGB(255, 255, 255), -- White Text

    Background = Color3.fromRGB(20, 20, 30), -- Dark Blue Background
    Topbar = Color3.fromRGB(30, 30, 45), -- Slightly Lighter Topbar
    Shadow = Color3.fromRGB(15, 15, 25), -- Soft Shadow

    NotificationBackground = Color3.fromRGB(25, 25, 35),
    NotificationActionsBackground = Color3.fromRGB(40, 40, 60),

    TabBackground = Color3.fromRGB(30, 30, 45),
    TabStroke = Color3.fromRGB(50, 50, 70),
    TabBackgroundSelected = Color3.fromRGB(60, 60, 90),
    TabTextColor = Color3.fromRGB(200, 200, 255),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

    ElementBackground = Color3.fromRGB(35, 35, 50),
    ElementBackgroundHover = Color3.fromRGB(45, 45, 65),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 40),
    ElementStroke = Color3.fromRGB(100, 100, 150),
    SecondaryElementStroke = Color3.fromRGB(80, 80, 120),

    SliderBackground = Color3.fromRGB(40, 40, 60),
    SliderProgress = Color3.fromRGB(100, 150, 255),
    SliderStroke = Color3.fromRGB(120, 170, 255),

    ToggleBackground = Color3.fromRGB(30, 30, 45),
    ToggleEnabled = Color3.fromRGB(100, 200, 255),
    ToggleDisabled = Color3.fromRGB(50, 50, 70),
    ToggleEnabledStroke = Color3.fromRGB(120, 220, 255),
    ToggleDisabledStroke = Color3.fromRGB(70, 70, 100),
    ToggleEnabledOuterStroke = Color3.fromRGB(150, 220, 255),
    ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 60),

    DropdownSelected = Color3.fromRGB(40, 40, 60),
    DropdownUnselected = Color3.fromRGB(30, 30, 45),

    InputBackground = Color3.fromRGB(30, 30, 45),
    InputStroke = Color3.fromRGB(100, 150, 255),
    PlaceholderColor = Color3.fromRGB(200, 200, 255)
}


-- Window
local Window = Rayfield:CreateWindow({
    Name = "Transfur Outbreak | Lime.Cheat V2 | Mobile Edition",
    Icon = 6472368967, 
    LoadingTitle = "Loading gui..",
    LoadingSubtitle = "only mobile compatible ui :P",
    Theme = TransfurTheme, 

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
