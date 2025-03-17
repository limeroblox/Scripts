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
    LoadingTitle = "Loading gui...",
    LoadingSubtitle = " ",
    Theme = BlackWhiteTheme, 

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, 

    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, 
       FileName = "TransfurOutbreak Script By @Limeroblox On Discord!"
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

-- Local Variables

local FireRate = 0.5 -- Default Fire Rate
local RayCastMaterial = "Neon" -- Default Material
local RayCastColor = Color3.fromRGB(0, 255, 0) -- Default RayCast Color
local disabled = true -- Auto Fire State (If it is true, no auto, if false auto is on)

local AutoFireToggle = HumanTab:CreateToggle({
    Name = "Auto Fire",
    CurrentValue = false,
    Flag = "AutoFire",
    Callback = function(Value)
        disabled = not Value
        if Value then
            spawn(function()
                local UIS = game:GetService("UserInputService")
                local Camera = workspace.CurrentCamera
                local shoot_event = game:GetService("ReplicatedStorage").PEW
                local TweenService = game:GetService("TweenService")
                local localplayer = game.Players.LocalPlayer
                local settings = nil
                local target_part = "Head"

                local replacement = {
                    [3] = 0.1,
                    [4] = nil,
                    [5] = nil,
                    [7] = nil
                }

                -- Function to draw and animate raycast lines (Grows Outwards with Fade Delay)
                local function Draw(p22, p23)
                    local v24 = Instance.new("Part", workspace.RayCast or workspace)
                    v24.Material = RayCastMaterial
                    v24.Anchored = true
                    v24.CanCollide = false
                    v24.Transparency = 0
                    v24.Color = RayCastColor

                    -- Set initial small size for growing effect
                    local rayLength = (p22 - p23).Magnitude
                    v24.Size = Vector3.new(0.1, 0, 0.1)

                    -- Position the raycast correctly
                    v24.CFrame = CFrame.new(p22, p23) * CFrame.new(0, 0, -rayLength / 2) * CFrame.Angles(math.pi / 2, 0, 0)

                    -- Tween for growth
                    local growTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local growGoal = {
                        Size = Vector3.new(0.1, rayLength, 0.1)
                    }
                    local growTween = TweenService:Create(v24, growTweenInfo, growGoal)
                    growTween:Play()

                    -- Delay the fade-out to ensure full growth before shrinking
                    task.wait(1.05)

                    -- Tween for fading and shrinking after delay
                    local fadeTweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local fadeGoal = {
                        Transparency = 1, -- Fade out
                        Size = Vector3.new(0.1, rayLength * 0.8, 0.1) -- Slight shrink for visual effect
                    }
                    local fadeTween = TweenService:Create(v24, fadeTweenInfo, fadeGoal)
                    fadeTween:Play()

                    -- Cleanup after 1.5 seconds total
                    game.Debris:AddItem(v24, 1.5)
                end

                -- Function to get the player's current weapon
                local function get_weapon()
                    return localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
                end

                -- Get the 2D screen position of a 3D point
                local function getScreenPosition(worldPosition)
                    local screenPosition, onScreen = Camera:WorldToViewportPoint(worldPosition)
                    return screenPosition, onScreen
                end

                -- Get the nearest enemy to the cursor
                local function getNearestToCursor()
                    local cursorPosition = UIS:GetMouseLocation()
                    local nearestTarget = nil
                    local shortestDistance = math.huge

                    for _, player in ipairs(game.Players:GetPlayers()) do
                        if player.Team ~= localplayer.Team and player.Character then
                            local character = player.Character
                            local hrp = character:FindFirstChild(target_part)
                            local humanoid = character:FindFirstChildOfClass("Humanoid")

                            if hrp and humanoid and humanoid.Health > 0 then
                                local screenPosition, onScreen = getScreenPosition(hrp.Position)
                                if onScreen then
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
                        end
                    end
                    return nearestTarget
                end

                -- Main target selection logic (Raycasting check)
                local function getTarget()
                    if not settings then return nil end

                    local nearest = getNearestToCursor()
                    if not nearest then return nil end

                    local torso = localplayer.Character and localplayer.Character:FindFirstChild("Torso")
                    if not torso then return nil end

                    local rayOrigin = torso.Position
                    local rayDirection = (nearest.position - rayOrigin).Unit * settings["RANGE"]
                    local ignoreList = {localplayer.Character, localplayer.Character.Parent, workspace.RayCast}
                    local ray = Ray.new(rayOrigin, rayDirection)

                    local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

                    if hitPart and hitPart:IsDescendantOf(nearest.target.Parent) then
                        Draw(rayOrigin, hitPos) -- Draws the ray with updated logic
                        return nearest
                    end
                    return nil
                end

                -- Main loop
                while not disabled do
                    task.wait(FireRate)
                    local weapon = get_weapon()
                    if not weapon then continue end

                    local data = weapon:FindFirstChild("SETTINGS")
                    if not data then continue end

                    settings = require(data)
                    replacement[3] = settings.FIRERATE

                    local aimbot = getTarget()
                    if aimbot and aimbot.target and aimbot.position then
                        replacement[4] = aimbot.target
                        replacement[5] = (aimbot.position - weapon.Barrel.Position).Unit
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
                print("AutoFire disabled")
            end)
        end
    end
})

-- Fire Rate Slider
local FireRateSlider = HumanTab:CreateSlider({
    Name = "Fire Rate",
    Range = {0.02, 1},
    Increment = 0.01,
    CurrentValue = FireRate,
    Flag = "FireRate",
    Callback = function(Value)
        FireRate = Value
    end,
})

-- RayCast Material Dropdown
local Dropdown = HumanTab:CreateDropdown({
   Name = "RayCast Materials",
   Options = {"Neon", "Plastic", "Wood", "Metal", "Glass", "DiamondPlate", "Foil", "Grass", "Ice", "Fabric", "Sand", "Granite", "Brick", "Pebble", "Cobblestone", "Marble", "Slate", "Concrete", "CorrodedMetal", "SmoothPlastic"},
   CurrentOption = {"Neon"}, -- Default
   MultipleOptions = false,
   Flag = "RayCastMaterialSet",
   Callback = function(Options)
      RayCastMaterial = Options[1] -- Updates local RayCastMaterial
   end,
})

-- RayCast Color Picker
local ColorPicker = HumanTab:CreateColorPicker({
    Name = "RayCast Color",
    Color = RayCastColor, -- Default RayCast Color
    Flag = "LineColorPicker",
    Callback = function(Color)
       if not isRainbowActive then
           RayCastColor = Color -- Update RayCastColor only if RainbowMode is OFF
       end
    end
})
 
local isRainbowActive = false -- Track Rainbow Mode state

local TurnRaycastRainbow = HumanTab:CreateToggle({
    Name = "RainbowMode",
    CurrentValue = false,
    Flag = "GAYMODE",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        -- Store original RayCastColor (from the ColorPicker)
        local originalRaycastColor = RayCastColor

        -- Function to generate a rainbow color
        local function RainbowColor()
            local hue = tick() % 5 / 5
            return Color3.fromHSV(hue, 1, 1)
        end

        -- Function to apply rainbow color to the RayCastColor
        local function ApplyRainbowToRaycast()
            while isRainbowActive do
                task.wait(0.05) -- Smooth color transition
                RayCastColor = RainbowColor() -- Update the RayCastColor for the AutoFire
            end
        end

        -- Function to restore original RayCastColor (from the ColorPicker)
        local function RestoreRaycastColor()
            RayCastColor = originalRaycastColor -- Restore to the ColorPicker's value
        end

        -- Start Rainbow effect
        if Value then
            isRainbowActive = true -- Enable Rainbow Mode

            -- Store the original RayCastColor if not already stored
            if not originalRaycastColor then
                originalRaycastColor = RayCastColor
            end

            -- Start applying the rainbow effect
            spawn(ApplyRainbowToRaycast)

        else
            isRainbowActive = false -- Disable Rainbow Mode

            -- Restore the original RayCastColor (from the ColorPicker)
            RestoreRaycastColor()
        end
    end
})

--End Of Human--
