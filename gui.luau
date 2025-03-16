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
local HumanTab = Window:CreateTab("Human")
local InfectedTab = Window:CreateTab("Infected")
--Start Of Human--

-- Rage Label
local Label = HumanTab:CreateLabel("Rage", Color3.fromRGB(255, 255, 255), false)

-- Auto Fire Toggle
_G.FireRate = 0.1 -- Default Fire Rate

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
                local settings = nil
                local target_part = "Head"

                local replacement = {
                    [3] = 0.1,
                    [4] = nil,
                    [5] = nil,
                    [7] = nil
                }

                -- Function to draw debug lines
                function Draw(p22, p23, color)
                    local v24 = Instance.new("Part", workspace.RayCast)
                    v24.Material = _G.LineMaterial
                    v24.Anchored = true
                    v24.CanCollide = false
                    v24.Transparency = 0
                    v24.Color = _G.LineColor
                    v24.Size = Vector3.new(0, 0, 0)
                    local v25 = (p22 - p23).Magnitude
                    v24.Size = Vector3.new(0.1, v25, 0.1)
                    v24.CFrame = CFrame.new(p22, p23) * CFrame.new(0, 0, -v25 / 2) * CFrame.Angles(math.pi / 2, 0, 0)
                    game.Debris:AddItem(v24, 0.1)
                end

                -- Function to get the player's current weapon
                function get_weapon()
                    return localplayer.Character:FindFirstChildOfClass("Tool")
                end

                -- Get the 2D screen position of a 3D point
                function getScreenPosition(worldPosition)
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(worldPosition)
                    return screenPosition, onScreen
                end

                -- Get the nearest enemy to the cursor
                function getNearestToCursor()
                    local cursorPosition = UIS:GetMouseLocation()
                    local nearestTarget = nil
                    local shortestDistance = math.huge

                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player.Team ~= localplayer.Team then
                            local character = player.Character
                            if not character then continue end

                            local hrp = character:FindFirstChild(target_part)
                            if not hrp then continue end

                            local ability = character:FindFirstChild("Ability")
                            if not ability or ability.Value == "Blackvalk" then continue end

                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then continue end

                            local screenPosition, onScreen = getScreenPosition(hrp.Position)
                            if not onScreen then continue end

                            local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - cursorPosition).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                nearestTarget = {
                                    position = hrp.Position,
                                    target = hrp
                                }
                            end
                        end
                    end
                    return nearestTarget
                end

                -- Main target selection logic
                function getTarget()
                    if not settings then return nil end

                    local nearest = getNearestToCursor()
                    if not nearest then return nil end

                    local torso = localplayer.Character and localplayer.Character:FindFirstChild("Torso")
                    if not torso then return nil end

                    local rayOrigin = torso.Position
                    local rayDirection = (nearest.position - rayOrigin).Unit * settings["RANGE"]
                    local ignoreList = {localplayer.Character, localplayer.Character.Parent, workspace.RayCast}
                    local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(rayOrigin, rayDirection), ignoreList)

                    if hitPart and hitPart.Parent == nearest.target.Parent then
                        Draw(rayOrigin, hitPos, Color3.new(0, 1, 0))
                        return nearest
                    end
                    return nil
                end

                -- Main loop
                while not _G.disabled do
                    task.wait(_G.FireRate)
                    local weapon = get_weapon()
                    if not weapon then continue end

                    local data = weapon:FindFirstChild("SETTINGS")
                    if not data then continue end

                    settings = require(data)
                    replacement[3] = settings.FIRERATE

                    local aimbot = getTarget()
                    if aimbot and aimbot.target and aimbot.position then
                        replacement[4] = aimbot.target
                        replacement[5] = CFrame.new(weapon.Barrel.Position, aimbot.position).LookVector
                        replacement[7] = aimbot.position

                        shoot_event:FireServer(weapon,
                            settings.COUNT,
                            replacement[3],
                            replacement[4],
                            replacement[5],
                            false,
                            replacement[7],
                            settings.RANGE)
                    end
                end
                print("disabled")
            end)
        end
    end
})

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

local Dropdown = HumanTab:CreateDropdown({
   Name = "RayCast Materials",
   Options = {"Neon","Plastic","Wood","Metal","Glass","DiamondPlate"},
   CurrentOption = {"Neon"}, -- Default
   MultipleOptions = false,
   Flag = "RayCastMaterialSet", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
      _G.LineMaterial = Options
   end,
})

local ColorPicker = HumanTab:CreateColorPicker({
   Name = "RayCast Color",
   Color = Color3.fromRGB(0, 255, 0),
   Flag = "LineColorPicker", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Color)
      _G.LineColor = Value
   end
})
--End Of Human--
