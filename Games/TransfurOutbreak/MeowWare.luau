-- 
loadstring(game:HttpGet('https://raw.githubusercontent.com/limeroblox/JanlibSupportForVelocity/refs/heads/main/janlib.lua'))()
--
local MainTab = library:AddTab("Main")
local MainCol = MainTab:AddColumn()
local AutoFireSection = MainCol:AddSection("AutoFire")
local KillAuraSection = MainCol:AddSection("KillAura")
local KillFieldPuddleCone_BypassSection = MainCol:AddSection("AntiPuddle/Void/Etc")
local ESPTab = library:AddTab("ESP")
local ESPCol = ESPTab:AddColumn()
local ESPSection = ESPCol:AddSection("ESP Settings")

local MiscTab = library:AddTab("Misc")
local MiscCol = MiscTab:AddColumn()
local FlySection = MiscCol:AddSection("Fly")

local SettingsTab = library:AddTab("Settings")
local SettingsCol = SettingsTab:AddColumn()
local SettingsCol2 = SettingsTab:AddColumn()
local MenuSection = SettingsCol:AddSection("Menu")
local ConfigSection = SettingsCol2:AddSection("Configs")
local Warning = library:AddWarning({type = "confirm"})
--FLAGS

_G.FireRate = 0.1
_G.KillAura = false

-- ESP Global Flags
_G.ESPEnabled = false
_G.ESP_ShowBox = false
_G.ESP_ShowName = false
_G.ESP_TeamCheck = false
_G.ESP_ShowHealth = false
_G.ESP_ShowTracer = false
_G.ESP_UseBoxESP = false

--FLAGS
local Whitelist = {
    "Speedrun390",
    "Imsakemother", 
    "XDhardkorexx",
    "Dem_xdd",
    "Heavens_Changed",
    "5777XDd",
    "TuxxyGooVania",
    "XxGeamer20x",
    "Ugwawaka2",
    "IceyWingss",
    "MAD_Moldy"
}

AutoFireSection:AddToggle({text = "Enabled", flag = "AutoFireEnabled", callback = function(Value)
    _G.AutoFireEnabled = Value
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

            local function Draw(p1, p2, color)
                local part = Instance.new("Part", workspace)
                part.Material = _G.LineMaterial or Enum.Material.Neon
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 0
                part.Color = color
                part.Size = Vector3.new(0.1, (p1 - p2).Magnitude, 0.1)
                part.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -(p1 - p2).Magnitude / 2) * CFrame.Angles(math.pi / 2, 0, 0)
                Debris:AddItem(part, 0.1)
            end

            local function get_weapon()
                return localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
            end

            local function isWhitelisted(player)
                for _, whitelistedPlayer in pairs(Whitelist) do
                    if player.Name == whitelistedPlayer then
                        return true
                    end
                end
                return false
            end

            local function getNearestToCursor()
                local nearestTarget = nil
                local shortestDistance = math.huge

                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= localplayer and player.Team ~= localplayer.Team and not isWhitelisted(player) then
                        local character = player.Character
                        if not character then continue end
                        local hrp = character:FindFirstChild(target_part)
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not hrp or not humanoid or humanoid.Health <= 0 then continue end
                        local torso = localplayer.Character and localplayer.Character:FindFirstChild("Torso")
                        if not torso then continue end
                        local rayOrigin = torso.Position
                        local rayDirection = (hrp.Position - rayOrigin).Unit * (settings and settings["RANGE"] or 1000)
                        local ignoreList = {localplayer.Character, workspace.RayCast}
                        local hitPart, hitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(rayOrigin, rayDirection), ignoreList)

                        if hitPart and hitPart.Parent == hrp.Parent then
                            Draw(rayOrigin, hitPos, library.flags["LineColor"])
                            return hrp
                        end
                    end
                end
                return nil
            end

            while _G.AutoFireEnabled do
                task.wait(_G.FireRate or 0.1)
                local weapon = get_weapon()
                if weapon then
                    local data = weapon:FindFirstChild("SETTINGS")
                    if data then
                        settings = require(data)
                        replacement[3] = settings.FIRERATE or 0.1
                        local target = getNearestToCursor()
                        if target and weapon:FindFirstChild("Barrel") then
                            replacement[4] = target
                            replacement[5] = (target.Position - weapon.Barrel.Position).Unit
                            replacement[7] = target.Position
                            shoot_event:FireServer(weapon, settings.COUNT, replacement[3], replacement[4], replacement[5], false, replacement[7], settings.RANGE)
                        end
                    end
                end
            end
        end)
    end
end})

AutoFireSection:AddBind({text = "Auto Fire Key", flag = "AutoFireBind", key = "Z"})
AutoFireSection:AddSlider({text = "Fire Rate", flag = "FireRate", min = 0.02, max = 10, value = 0.1, float = 0.01, suffix = "s", callback = function(v)
    _G.FireRate = v
end})
AutoFireSection:AddColor({text = "Line Color", flag = "LineColor", color = Color3.fromRGB(0, 255, 0)})
AutoFireSection:AddList({text = "Line Material", flag = "LineMaterial", value = "Neon", values = {
    "Neon", "Plastic", "Wood", "Metal", "Glass", "DiamondPlate", "Foil", "Grass", "Ice", "Fabric",
    "Sand", "Granite", "Brick", "Pebble", "Cobblestone", "Marble", "Slate", "Concrete", "CorrodedMetal", "SmoothPlastic"
}})

KillAuraSection:AddToggle({
    text = "Enabled", 
    flag = "KillAuraEnabled", 
    callback = function(v)
        _G.KillAura = v

        -- Reference the MeleeDamage remote correctly
        local remote = game.ReplicatedStorage:FindFirstChild("MeleeDamage")  -- Adjusted to the correct name 'MeleeDamage'
        if not remote then
            warn("Remote 'MeleeDamage' not found!")
            return
        end

        -- Define the Whitelist function early
        local function isWhitelisted(player)
            for _, whitelistedPlayer in pairs(Whitelist) do
                if player.Name == whitelistedPlayer then
                    return true
                end
            end
            return false
        end

        -- Utility Functions (inside the KillAura toggle)
        local function GetHumanoidAndHead(target)
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            local head = target:FindFirstChild("Head")
            return humanoid, head
        end

        local function IsOnSameTeam(Human, Infected)
            return Human.Team == Infected.Team
        end

        local function IsTargetValid(target, player)
            if not target then return false end

            local humanoid, head = GetHumanoidAndHead(target)
            if not humanoid or not head then return false end

            -- Skip the local player and whitelisted players
            if target == player or isWhitelisted(target) then
                return false
            end

            -- Check if the target is on the same team
            if IsOnSameTeam(player, game.Players:GetPlayerFromCharacter(target)) then
                return false
            end

            -- Ensure humanoid.Health is valid before comparing
            if humanoid.Health == nil or humanoid.Health <= 0 then
                return false
            end

            return true
        end

        -- Tool Check Function
        local function hasToolEquipped(player)
            local character = player.Character
            if character then
                -- Check for any tool in the character's backpack or in their hand
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    return true
                end
            end
            return false
        end

        if v then
            spawn(function()
                while _G.KillAura do
                    task.wait(0.15)  -- Delay between each loop iteration

                    -- Get the player using the KillAura (likely the local player)
                    local player = game.Players.LocalPlayer

                    -- Ensure the player has a tool equipped before proceeding
                    if not hasToolEquipped(player) then
                        continue  -- Skip this loop iteration if no tool is equipped
                    end

                    -- Get all players in the game to check for targets
                    for _, target in pairs(game.Players:GetPlayers()) do
                        -- Skip the local player or whitelisted players
                        if target == player or isWhitelisted(target) or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                            continue
                        end

                        -- Ensure target is valid
                        if not IsTargetValid(target.Character, player) then
                            continue
                        end

                        local humanoid, hitpart = GetHumanoidAndHead(target.Character)
                        if not humanoid or not hitpart then continue end

                        -- MeleeDamage remote call with valid arguments
                        local isHeavyAttack = (section and section.isHeavyAttack) or false  -- Default to false if section.isHeavyAttack is nil
                        print("Using isHeavyAttack: " .. tostring(isHeavyAttack))  -- Debugging print

                        -- Fire the MeleeDamage event with the correct arguments (humanoid, isHeavyAttack)
                        remote:FireServer(humanoid, isHeavyAttack)

                        -- Add a delay between `FireServer` calls to prevent packet kicking
                        task.wait(0.05)  -- 100ms delay between each packet
                    end
                end
            end)
        else
            -- Stop the loop
            if KillAuraConnection then
                task.cancel(KillAuraConnection)
                KillAuraConnection = nil
            end
        end
    end
})


KillAuraSection:AddBind({text = "KillAura Key", flag = "KillAuraKey", key = "X"})

FlySection:AddToggle({
    text = "Enabled",
    flag = "FlyEnabled",
    callback = function(v)
        _G.Flying = v
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()  -- Ensure character is loaded
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if humanoid and char then
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
            if torso then
                if v then
                    -- Create BodyGyro and BodyVelocity for flying
                    local bg = Instance.new("BodyGyro", torso)
                    local bv = Instance.new("BodyVelocity", torso)
                    bg.P = 9e4
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.new(0, 0.1, 0)  -- Small initial velocity to lift off
                    humanoid.PlatformStand = true

                    -- Disable collisions for all parts in the character
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end

                    -- Get current camera and input services
                    local cam = workspace.CurrentCamera
                    local input = game:GetService("UserInputService")

                    -- Flight loop
                    while _G.Flying and humanoid.Health > 0 do
                        task.wait(0.1)  -- Delay to prevent excessive loop execution
                        local f = (input:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (input:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                        local r = (input:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (input:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
                        bv.Velocity = cam.CFrame.LookVector * (f * 50) + cam.CFrame.RightVector * (r * 50)

                        -- Keep BodyGyro aligned with the camera to prevent rotation drift
                        bg.CFrame = cam.CFrame
                    end
                else
                    -- Cleanup flight and restore normal behavior
                    for _, obj in ipairs(torso:GetChildren()) do
                        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                            obj:Destroy()
                        end
                    end

                    -- Restore collisions for all parts in the character
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                    humanoid.PlatformStand = false  -- Restore platform standing to default
                end
            else
                warn("No valid torso part or HumanoidRootPart found.")
            end
        else
            warn("No humanoid found or character is invalid.")
        end
    end
})

local bypassConnection
local respawnConnection

KillFieldPuddleCone_BypassSection:AddToggle({
    text = "Enabled",
    flag = "KillFieldBypass",
    callback = function(enabled)
        local player = game.Players.LocalPlayer

        -- Clear existing loop and respawn connection
        if bypassConnection then
            task.cancel(bypassConnection)
            bypassConnection = nil
        end
        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end

        local function setCanTouch(char, state)
            -- Direct body parts
            for _, obj in pairs(char:GetChildren()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = state
                end
            end

            -- Parts inside folders
            for _, folderName in ipairs({"Humans", "Infecteds"}) do
                local folder = char:FindFirstChild(folderName)
                if folder then
                    for _, obj in pairs(folder:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            obj.CanTouch = state
                        end
                    end
                end
            end
        end

        if enabled then
            local function applyBypass(char)
                bypassConnection = task.spawn(function()
                    while true do
                        if not char or not char.Parent then break end
                        setCanTouch(char, false)
                        task.wait(0.5)
                    end
                end)
            end

            if player.Character then
                applyBypass(player.Character)
            end

            respawnConnection = player.CharacterAdded:Connect(function(char)
                task.wait(1)
                applyBypass(char)
            end)
        else
            -- On toggle off, re-enable CanTouch
            if player.Character then
                setCanTouch(player.Character, true)
            end
        end
    end
})


FlySection:AddBind({text = "Fly Key", flag = "FlyKey", key = "V"})

ESPSection:AddToggle({
    text = "Enable ESP",
    flag = "ESPEnabled",
    callback = function(v)
        _G.ESPEnabled = v
    end
})

ESPSection:AddToggle({
    text = "Show Box",
    flag = "ESP_ShowBox",
    callback = function(v)
        _G.ESP_ShowBox = v
    end
})

ESPSection:AddToggle({
    text = "Show Name",
    flag = "ESP_ShowName",
    callback = function(v)
        _G.ESP_ShowName = v
    end
})

ESPSection:AddToggle({
    text = "Team Check",
    flag = "ESP_TeamCheck",
    callback = function(v)
        _G.ESP_TeamCheck = v
    end
})

ESPSection:AddToggle({
    text = "Show Health",
    flag = "ESP_ShowHealth",
    callback = function(v)
        _G.ESP_ShowHealth = v
    end
})

ESPSection:AddToggle({
    text = "Tracer",
    flag = "ESP_ShowTracer",
    callback = function(v)
        _G.ESP_ShowTracer = v
    end
})

ESPSection:AddToggle({
    text = "Box ESP (Corners)",
    flag = "ESP_UseBoxESP",
    callback = function(v)
        _G.ESP_UseBoxESP = v
    end
})
--// SETTINGS
local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom",
    Tracer_FollowMouse = false,
    Tracers = true
}
local Team_Check = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}
local TeamColor = true

--// GLOBAL TOGGLES
_G.ESPEnabled = true
_G.ESP_ShowBox = true
_G.ESP_ShowTracer = true
_G.ESP_ShowHealth = true
_G.ESP_ShowName = true

--// SERVICES
local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

--// UTILITY
local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function NewText(size, color, font)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = size
    text.Color = color
    text.Font = font or Drawing.Fonts.UI
    text.Text = ""
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    return text
end

local function Visibility(state, lib)
    for _, x in pairs(lib) do
        x.Visible = state
    end
end

local function SafeSetVisibility(elements, condition)
    for _, element in ipairs(elements) do
        if element then
            element.Visible = condition
        end
    end
end

--// TRACKED ESP OBJECTS
local ESPObjects = {}

--// ESP GENERATOR
local function ESP(plr)
    if plr == player then return end

    local black = Color3.fromRGB(0, 0, 0)
    local library = {
        blacktracer = NewLine(Settings.Tracer_Thickness*2, black),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        black = NewQuad(Settings.Box_Thickness*2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black),
        username = NewText(16, Color3.fromRGB(255, 255, 255)),
        distance = NewText(16, Color3.fromRGB(255, 255, 255))
    }

    ESPObjects[plr] = library

    local function Colorize(color)
        for u, x in pairs(library) do
            if x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black then
                x.Color = color
            end
        end
    end

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not plr or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 or not plr.Character:FindFirstChild("Head") then
            Visibility(false, library)
            if not game.Players:FindFirstChild(plr.Name) then
                connection:Disconnect()
                ESPObjects[plr] = nil
            end
            return
        end

        local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
        if not OnScreen then
            Visibility(false, library)
            return
        end

        local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
        local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

        -- BOX
        local function Size(item)
            item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
            item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
            item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
            item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
        end
        Size(library.box)
        Size(library.black)

        -- TRACERS
        if Settings.Tracers then
            local origin = Settings.Tracer_Origin
            if Settings.Tracer_FollowMouse then
                library.tracer.From = Vector2.new(mouse.X, mouse.Y + 36)
                library.blacktracer.From = Vector2.new(mouse.X, mouse.Y + 36)
            elseif origin == "Middle" then
                local center = camera.ViewportSize * 0.5
                library.tracer.From = center
                library.blacktracer.From = center
            else
                local bottom = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y)
                library.tracer.From = bottom
                library.blacktracer.From = bottom
            end
            library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY * 2)
            library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY * 2)
        else
            library.tracer.From = Vector2.new(0, 0)
            library.tracer.To = Vector2.new(0, 0)
            library.blacktracer.From = Vector2.new(0, 0)
            library.blacktracer.To = Vector2.new(0, 0)
        end

        -- HEALTHBAR
        local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude 
        local hp_ratio = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
        local healthoffset = hp_ratio * d

        library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
        library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)
        library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
        library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)

        local green = Color3.fromRGB(0, 255, 0)
        local red = Color3.fromRGB(255, 0, 0)
        library.greenhealth.Color = red:lerp(green, hp_ratio)

        -- NAME & DISTANCE
        library.username.Text = plr.DisplayName
        library.username.Position = Vector2.new(HumPos.X, HumPos.Y - DistanceY - 20)
        library.username.Size = math.clamp(DistanceY * 0.5, 13, 25)

        local dist = math.floor((camera.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
        library.distance.Text = tostring(dist) .. " studs"
        library.distance.Position = Vector2.new(HumPos.X, HumPos.Y + DistanceY + 10)
        library.distance.Size = math.clamp(DistanceY * 0.5, 13, 25)

        -- TEAM COLOR
        if Team_Check.TeamCheck then
            Colorize(plr.TeamColor == player.TeamColor and Team_Check.Green or Team_Check.Red)
        elseif TeamColor then
            Colorize(plr.TeamColor.Color)
        else
            library.tracer.Color = Settings.Tracer_Color
            library.box.Color = Settings.Box_Color
        end

        -- Visibility Controlled by Toggles
        if _G.ESPEnabled then
            SafeSetVisibility({library.box, library.black}, _G.ESP_ShowBox)
            SafeSetVisibility({library.tracer, library.blacktracer}, _G.ESP_ShowTracer)
            SafeSetVisibility({library.greenhealth, library.healthbar}, _G.ESP_ShowHealth)
            SafeSetVisibility({library.username, library.distance}, _G.ESP_ShowName)
        else
            Visibility(false, library)
        end
    end)
end

--// Update visibility for all ESPs
local function UpdateESPVisibility()
    for _, lib in pairs(ESPObjects) do
        if _G.ESPEnabled then
            SafeSetVisibility({lib.box, lib.black}, _G.ESP_ShowBox)
            SafeSetVisibility({lib.tracer, lib.blacktracer}, _G.ESP_ShowTracer)
            SafeSetVisibility({lib.greenhealth, lib.healthbar}, _G.ESP_ShowHealth)
            SafeSetVisibility({lib.username, lib.distance}, _G.ESP_ShowName)
        else
            Visibility(false, lib)
        end
    end
end

--// HOOK
for _, plr in ipairs(game.Players:GetPlayers()) do
    ESP(plr)
end

game.Players.PlayerAdded:Connect(ESP)

MenuSection:AddBind({text = "UI Toggle", flag = "UIToggle", nomouse = true, key = "End", callback = function()
    library:Close()
end})

MenuSection:AddColor({text = "Accent Color", flag = "Menu Accent Color", color = Color3.fromRGB(153, 114, 248), callback = function(color)
    if library.currentTab then
        library.currentTab.button.TextColor3 = color
    end
    for i,v in pairs(library.theme) do
        v[(v.ClassName == "TextLabel" and "TextColor3") or (v.ClassName == "ImageLabel" and "ImageColor3") or "BackgroundColor3"] = color
    end
end})

local backgroundlist = {
    Floral = "rbxassetid://5553946656",
    Flowers = "rbxassetid://6071575925",
    Circles = "rbxassetid://6071579801",
    Hearts = "rbxassetid://6073763717",
    KitKat = "rbxassetid://6553026078",
    Lime = "rbxassetid://18888404587",
    whathaveyoudone = "rbxassetid://13981255390"
}

local back = MenuSection:AddList({text = "Background", max = 4, flag = "background", values = {"Floral", "Flowers", "Circles", "Hearts", "KitKat", "Lime", "whathaveyoudone"}, value = "Floral", callback = function(v)
    if library.main then
        library.main.Image = backgroundlist[v]
    end
end})

back:AddColor({flag = "backgroundcolor", color = Color3.new(), callback = function(color)
    if library.main then
        library.main.ImageColor3 = color
    end
end, trans = 1, calltrans = function(trans)
    if library.main then
        library.main.ImageTransparency = 1 - trans
    end
end})

MenuSection:AddSlider({text = "Tile Size", min = 50, max = 500, value = 50, callback = function(size)
    if library.main then
        library.main.TileSize = UDim2.new(0, size, 0, size)
    end
end})

MenuSection:AddButton({text = "Discord", callback = function() end})

ConfigSection:AddBox({text = "Config Name", skipflag = true})
ConfigSection:AddList({text = "Configs", skipflag = true, value = "", flag = "Config List", values = library:GetConfigs()})

ConfigSection:AddButton({text = "Create", callback = function()
    library:GetConfigs()
    writefile(library.foldername .. "/" .. library.flags["Config Name"] .. library.fileext, "{}")
    library.options["Config List"]:AddValue(library.flags["Config Name"])
end})

ConfigSection:AddButton({text = "Save", callback = function()
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Are you sure you want to save the current settings to config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
    if Warning:Show() then
        library:SaveConfig(library.flags["Config List"])
    end
end})

ConfigSection:AddButton({text = "Load", callback = function()
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Are you sure you want to load config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
    if Warning:Show() then
        library:LoadConfig(library.flags["Config List"])
    end
end})

ConfigSection:AddButton({text = "Delete", callback = function()
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Are you sure you want to delete config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?"
    if Warning:Show() then
        local config = library.flags["Config List"]
        if table.find(library:GetConfigs(), config) and isfile(library.foldername .. "/" .. config .. library.fileext) then
            library.options["Config List"]:RemoveValue(config)
            delfile(library.foldername .. "/" .. config .. library.fileext)
        end
    end
end})

library:Init()
library:selectTab(library.tabs[1])

print("Debug Mode Is Active, Expect Alot In The Console Output...")
