-- Demonology ESP Drawing Edition with utility functions

local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local infiniteyeild = loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))

-- Color definitions
local COLORS = {
    Ghost = Color3.fromRGB(255, 0, 0),
    GhostOrb = Color3.fromRGB(255, 255, 255),
    CursedRed = Color3.fromRGB(255, 0, 0),
    ItemGreen = Color3.fromRGB(0, 255, 0),
    ItemRed = Color3.fromRGB(255, 0, 0),
    Handprint = Color3.fromRGB(255, 165, 0),
    FuseBox = Color3.fromRGB(255, 255, 0),
    SaltLine = Color3.fromRGB(255, 255, 150),
    DisturbedSaltLine = Color3.fromRGB(200, 100, 100),
    HolyOil = Color3.fromRGB(170, 85, 0),
}

local GREEN_ITEMS = {
    ['Video Camera'] = true,
    ['Thermometer'] = true,
    ['Spirit Book'] = true,
    ['Blacklight'] = true,
    ['Spirit Box'] = true,
    ['EMF Reader'] = true,
    ['Flashlight'] = true,
    ['Laser Projector'] = true,
    ['Energy Drink'] = true,
    ['Energy Watch'] = true,
    ['Cross'] = true,
    ['Head Mounted Camera'] = true,
    ['Photo Camera'] = true,
    ['Salt Canister'] = true,
    ['Lighter'] = true,
    ['Lantern'] = true,
    ['LIDAR Scanner'] = true,
    ['Holy Oil'] = true,
    ['Flower Pot'] = true,
    ['Plushie'] = true,
}

local RED_ITEMS = {
    ['Music Box'] = true,
    ['Umdra Board'] = true,
    ['Haunted Mirror'] = true,
}

local espObjects = {}
local Utils = {}

-- Safe removal of Drawing objects
function Utils.SafeRemoveDrawing(drawing)
    if drawing and drawing.Visible ~= nil then
        drawing.Visible = false
        drawing:Remove()
    end
end

-- Remove all ESP drawings safely
function Utils.ClearAllESP()
    for inst, drawings in pairs(espObjects) do
        Utils.SafeRemoveDrawing(drawings.main)
        Utils.SafeRemoveDrawing(drawings.shadow)
        espObjects[inst] = nil
    end
end

-- Teleport player helper (not used here but handy)
function Utils.TeleportTo(position)
    local hrp = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

-- Notification helper (for exploit GUIs supporting SetCore)
function Utils.Notify(title, text, duration)
    duration = duration or 5
    local StarterGui = game:GetService('StarterGui')
    if StarterGui and StarterGui.SetCore then
        StarterGui:SetCore('SendNotification', {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end
end

--// Drawing API availability check //-- 
local drawingSupported = pcall(function()
    return Drawing and Drawing.new
end)

if not drawingSupported then
    Utils.Notify("Demonology ESP", "Drawing API not supported in this executor", 5)
    return           -- abort loading ESP
end

-- Create or update text ESP for an instance
local function createOrUpdateTextESP(instance, text, color)
    if not instance or not instance:IsA('BasePart') then
        return
    end

    local drawings = espObjects[instance]
    if not drawings then
        drawings = {
            main = Drawing.new('Text'),
            shadow = Drawing.new('Text'),
        }
        espObjects[instance] = drawings
        
        -- Setup shadow text (glow behind)
        drawings.shadow.Size = 15
        drawings.shadow.Center = true
        drawings.shadow.Outline = false
        drawings.shadow.Color = Color3.new(0, 0, 0)
        drawings.shadow.Visible = false
        drawings.shadow.Font = 2 -- Comic Sans MS

        -- Setup main text
        drawings.main.Size = 13
        drawings.main.Center = true
        drawings.main.Outline = true
        drawings.main.Visible = true
        drawings.main.Font = 2 -- Comic Sans MS
    end

    drawings.main.Text = text
    drawings.main.Color = color or COLORS.Ghost

    -- Fixed typo: "drawlings" -> "drawings"
    -- drawings.shadow.Visible = false (Removed due to bugs)
    drawings.main.Visible = true
end

-- Clean up ESP for instances no longer valid or removed from workspace
local function cleanupInvalidESP()
    local toRemove = {}
    local cleanedCount = 0

    for inst, drawings in pairs(espObjects) do
        local shouldRemove = false

        -- Instance validation (safe wrapped)
        local success, result = pcall(function()
            return inst and inst.Parent and inst:IsDescendantOf(game)
        end)

        if not success or not result then
            shouldRemove = true
        end

        -- Drawing object validation
        if not shouldRemove and drawings then
            local mainIsValid = typeof(drawings.main) == "table" or typeof(drawings.main) == "userdata"
            local shadowIsValid = typeof(drawings.shadow) == "table" or typeof(drawings.shadow) == "userdata"

            if not mainIsValid and not shadowIsValid then
                shouldRemove = true
            end
        end

        if shouldRemove then
            table.insert(toRemove, inst)
        end
    end

    -- Perform cleanup
    for _, inst in ipairs(toRemove) do
        local drawings = espObjects[inst]
        local removedMain, removedShadow = false, false

        if drawings then
            if drawings.main then
                local ok = pcall(Utils.SafeRemoveDrawing, drawings.main)
                if ok then removedMain = true end
            end
            if drawings.shadow then
                local ok = pcall(Utils.SafeRemoveDrawing, drawings.shadow)
                if ok then removedShadow = true end
            end
        end

        espObjects[inst] = nil

        -- Sanity check logging
        if removedMain or removedShadow then
            cleanedCount += 1
        else
            warn("[ESP Cleanup] Warning: No drawings removed for instance:", inst)
        end
    end
end

-- Optional: Add cleanup for destroyed instances
local function updateESPPositions()
    local cameraPosition = Camera.CFrame.Position
    local toRemove = {}
    
    for inst, drawings in pairs(espObjects) do
        if not (inst and inst.Parent and inst:IsDescendantOf(game)) then
            table.insert(toRemove, inst)
            drawings.main.Visible = false
            drawings.shadow.Visible = false
            continue
        end
        
        -- Check if instance has a Position property
        local instancePosition = inst.Position or inst.CFrame.Position
        if not instancePosition then
            table.insert(toRemove, inst)
            drawings.main.Visible = false
            drawings.shadow.Visible = false
            continue
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(instancePosition)
        
        if onScreen and screenPos.Z > 0 then
            local distance = (cameraPosition - instancePosition).Magnitude
            
            -- More controlled scaling with proper math.clamp usage
            local mainSize
            if distance <= 30 then
                -- Close range: 13-15
                mainSize = math.clamp(13 + (distance / 30) * 2, 13, 15)
            else
                -- Far range: 15-18
                mainSize = math.clamp(15 + ((distance - 30) / 70) * 3, 15, 18)
            end
            
            local x, y = math.floor(screenPos.X), math.floor(screenPos.Y)
            
            -- Update main text
            drawings.main.Size = mainSize
            drawings.main.Position = Vector2.new(x, y)
            drawings.main.Visible = true
            
            -- Update shadow text
            drawings.shadow.Size = mainSize + 2
            drawings.shadow.Position = Vector2.new(x + 1, y + 1)
            drawings.shadow.Visible = true
        else
            drawings.main.Visible = false
            drawings.shadow.Visible = false
        end
    end
    
    -- Cleanup removed instances
    for _, inst in ipairs(toRemove) do
        local drawings = espObjects[inst]
        if drawings then
            -- Properly dispose of Drawing objects
            if drawings.main then
                drawings.main:Remove()
            end
            if drawings.shadow then
                drawings.shadow:Remove()
            end
        end
        espObjects[inst] = nil
    end
end

local reportedAlerts = {}

local function AlertMissing(key, message, duration)
    if not reportedAlerts[key] then
        reportedAlerts[key] = true
        Utils.Notify("Demonology ESP", message, duration or 4)
        warn("[AlertMissing] " .. message)
    end
end


local function trackGhost()
    local ghost = workspace:FindFirstChild("Ghost")
    if ghost and ghost:IsA("Model") then
        local root = ghost:FindFirstChild("HumanoidRootPart")
            or ghost.PrimaryPart
            or ghost:FindFirstChildWhichIsA("BasePart")

        if root then
            local attributes = {
                "CameraKillOffset",
                "CurrentRoom",
                "EventActive",
                "GhostType",
                "Gender",
                "Hunting",
                "IsGhost",
                "laservisible",
                "PhotoRewardAvailable",
                "Transparency",
                "TransparencyLocked",
                "VisualModel"
            }

            local labelLines = {"Ghost"}
            local missing = {}

            for _, attr in ipairs(attributes) do
                local ok, value = pcall(function()
                    return ghost:GetAttribute(attr)
                end)

                if ok and value ~= nil then
                    table.insert(labelLines, attr .. ": " .. tostring(value))
                else
                    table.insert(missing, attr)
                end
            end

            local label = table.concat(labelLines, "\n")
            createOrUpdateTextESP(root, label, COLORS.Ghost)

            if #missing > 0 then
                AlertMissing("MissingGhostAttrs", "Missing Ghost Attributes:\n" .. table.concat(missing, ", "))
            end
        else
            AlertMissing("NoRootPart", "Ghost has no valid root part")
        end
    else
        AlertMissing("NoGhostModel", "Ghost model not found")
    end
end

local function trackFuseBox()
    local fuseBox = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("FuseBox")

    if not fuseBox or not fuseBox:IsA("Instance") then
        Utils.Notify('FuseBox Error', 'Map.FuseBox not found or invalid', 3)
        return
    end

    -- Find a BasePart to attach ESP
    local espTarget = nil
    if fuseBox:IsA("BasePart") then
        espTarget = fuseBox
    else
        -- Try to find a child BasePart (e.g., "Frame")
        espTarget = fuseBox:FindFirstChildWhichIsA("BasePart")
    end

    if not espTarget then
        Utils.Notify('FuseBox Error', 'No valid BasePart found for ESP', 3)
        return
    end

    local enabled = fuseBox:GetAttribute("Enabled")
    local uninteractible = fuseBox:GetAttribute("Uninteractible")

    local label = "Fuse Box"
    if enabled ~= nil then
        label = label .. "\nEnabled: " .. tostring(enabled)
    end
    if uninteractible ~= nil then
        label = label .. "\nUninteractible: " .. tostring(uninteractible)
    end

    createOrUpdateTextESP(espTarget, label, COLORS.FuseBox)
end



-- Track Ghost Orb if it exists
local function trackGhostOrb()
    local orb = Workspace:FindFirstChild('GhostOrb')
    if orb and orb:IsA('BasePart') then
        createOrUpdateTextESP(orb, 'Ghost Orb', COLORS.GhostOrb)
    end
end

-- Track Cursed Possessions
local function trackCursedPossessions()
    local cpHolder = workspace:FindFirstChild("CursedPossessionHolder")
    if not cpHolder then
        warn("[trackCursedPossessions] CursedPossessionHolder not found")
        return
    end

    for _, model in ipairs(cpHolder:GetChildren()) do
        if model and model:IsA("Model") then
            local success, err = pcall(function()
                local circlePart = model:FindFirstChild("Circle")
                -- No PhotoRewardAvailable check here
                if circlePart and circlePart:IsA("BasePart") then
                    local ok, result = pcall(createOrUpdateTextESP, circlePart, "Summoning Circle", COLORS.CursedRed)
                    if not ok then
                        warn("[trackCursedPossessions] Failed to create ESP for Circle: " .. tostring(result))
                    end
                end
            end)

            if not success then
                warn("[trackCursedPossessions] Error processing model '" .. model.Name .. "': " .. tostring(err))
            end
        end
    end
end

-- Track Handprints
local function trackHandprints()
    local handprints = Workspace:FindFirstChild('Handprints')
    if handprints then
        for _, obj in ipairs(handprints:GetChildren()) do
            if obj:IsA('BasePart') then
                createOrUpdateTextESP(obj, 'Handprint', COLORS.Handprint)
            end
        end
    end
end

-- Track Holy Oil and Salt Variants (with proper .Center pathing)
local function trackWorldObjects()
    -- Track all HolyOil models
    for _, holyOilModel in ipairs(Workspace:GetChildren()) do
        if holyOilModel.Name == "HolyOil" and holyOilModel:IsA("Model") then
            local innerModel = holyOilModel:FindFirstChild("HolyOil")
            if innerModel and innerModel:IsA("Model") then
                local center = innerModel:FindFirstChild("Center")
                if center and center:IsA("BasePart") then
                    local text = "Holy Oil"

                    if innerModel:HasAttribute("burning") and innerModel:GetAttribute("burning") == true then
                        text ..= " 🔥"
                    end

                    if innerModel:HasAttribute("disabled") and innerModel:GetAttribute("disabled") == true then
                        text ..= " (Disabled)"
                    end

                    if innerModel:HasAttribute("burnedtimes") then
                        local burned = innerModel:GetAttribute("burnedtimes")
                        if typeof(burned) == "number" then
                            text ..= " | Burned: " .. tostring(burned)
                        end
                    end

                    createOrUpdateTextESP(center, text, COLORS.HolyOil)
                end
            end
        end
    end

    -- Track all SaltPiles
    local saltPiles = Workspace:FindFirstChild("SaltPiles")
    if saltPiles then
        for _, obj in ipairs(saltPiles:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Center" then
                local parent = obj.Parent
                if parent then
                    if parent.Name == "SaltLine" then
                        createOrUpdateTextESP(obj, "Salt Line", COLORS.SaltLine)
                    elseif parent.Name == "DisturbedSaltLine" then
                        createOrUpdateTextESP(obj, "Disturbed Salt", COLORS.DisturbedSaltLine)
                    end
                end
            end
        end
    end
end

-- Track Items
local function trackItems()
    local items = Workspace:FindFirstChild('Items')
    if items then
        for _, obj in ipairs(items:GetChildren()) do
            if obj:IsA('Model') then
                local itemName = obj:GetAttribute('ItemName')
                if itemName then
                    local handle = obj:FindFirstChild('Handle')
                        or obj:FindFirstChild('Screen')
                    if handle and handle:IsA('BasePart') then
                        local color = COLORS.Ghost -- default
                        if GREEN_ITEMS[itemName] then
                            color = COLORS.ItemGreen
                        elseif RED_ITEMS[itemName] then
                            color = COLORS.ItemRed
                        end
                        createOrUpdateTextESP(handle, itemName, color)
                    end
                end
            end
        end
    end
end

local function notifyGhostFavoriteRoom()
    local ghost = workspace:FindFirstChild("Ghost")
    if not ghost then
        warn("[notifyGhostFavoriteRoom] Ghost not found in workspace")
        Utils.Notify('Favortite Room (Error)', 'You Are In The Lobby, Please Execute This Ingame!', 4.5)
        return
    end

    local success, favoriteRoom = pcall(function()
        return ghost:GetAttribute("FavoriteRoom")
    end)

    if success and favoriteRoom then
        Utils.Notify('Favorite Room:', ''.. tostring(favoriteRoom) , 5)
    else
        Utils.Notify('Favortite Room (Error)', 'Favorite Room attribute not found, Possible Bug', 3)
        warn("[notifyGhostFavoriteRoom] Failed to get FavoriteRoom attribute")
    end
end
-- Collect update functions
local trackingFunctions = {
    cleanupInvalidESP,
    trackFuseBox,
    trackGhost,
    trackGhostOrb,
    trackCursedPossessions,
    trackHandprints,
    trackItems,
    trackWorldObjects,
    updateESPPositions,
}

-- Main update loop
RunService.RenderStepped:Connect(function()
    for i, func in ipairs(trackingFunctions) do
        if typeof(func) == "function" then
            local success, result = pcall(func)
            if not success then
                warn(("[ESP] Error in function #%d (%s): %s"):format(i, tostring(func), result))
            end
        else
            warn(("[ESP] Invalid entry in trackingFunctions at index %d"):format(i))
        end
    end
end)


Utils.Notify('Demonology ESP Ver: 1.2.0', 'ESP Loaded Successfully!\n\(Made By @lime.bat On Discord)', 3)
notifyGhostFavoriteRoom()
task.wait(5)
infiniteyeild()
