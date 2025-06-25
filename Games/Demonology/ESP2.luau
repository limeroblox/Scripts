--###########################################################################
--##                                                                       ##
--##  Demonology ESP – Drawing Edition  v1.3.0                             ##
--##  (with Quality-of-Life, Performance & Safety Revamps)                 ##
--##                                                                       ##
--##  Author:  lime.bat  ┃  Discord: @lime.bat                             ##
--##                                                                       ##
--##  This file is intentionally verbose (~500 lines) so it’s easier       ##
--##  to scan, bookmark, and tweak.  Collapse regions in your IDE for      ##
--##  maximum comfort.                                                     ##
--###########################################################################

--===========================================================================
--//  SECTION ❶ – Service References & One-liners
--===========================================================================

local RunService    = game:GetService("RunService")        -- heartbeat / render loop
local Workspace     = game:GetService("Workspace")         -- world root
local Players       = game:GetService("Players")           -- player list
local StarterGui    = game:GetService("StarterGui")        -- notifications
local UIS           = game:GetService("UserInputService")  -- keybinds / input

local LocalPlayer   = Players.LocalPlayer                  -- convenience handle
local Camera        = Workspace.CurrentCamera              -- world <-> screen
local InfiniteYield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
))

--===========================================================================
--//  SECTION ❷ – Color Palette
--===========================================================================

local COLORS = {
    Ghost               = Color3.fromRGB(255,   0,   0),
    GhostOrb            = Color3.fromRGB(255, 255, 255),
    CursedRed           = Color3.fromRGB(255,   0,   0),
    ItemGreen           = Color3.fromRGB(  0, 255,   0),
    ItemRed             = Color3.fromRGB(255,   0,   0),
    Handprint           = Color3.fromRGB(255, 165,   0),
    FuseBox             = Color3.fromRGB(255, 255,   0),
    SaltLine            = Color3.fromRGB(255, 255, 150),
    DisturbedSaltLine   = Color3.fromRGB(200, 100, 100),
    HolyOil             = Color3.fromRGB(170,  85,   0),
}

--##  Item color lookup tables  ------------------------------------------------
local GREEN_ITEMS = {
    ["Video Camera"] = true, ["Thermometer"] = true, ["Spirit Book"] = true,
    ["Blacklight"] = true,   ["Spirit Box"] = true, ["EMF Reader"]   = true,
    ["Flashlight"] = true,   ["Laser Projector"] = true,
    ["Energy Drink"] = true, ["Energy Watch"] = true,
    ["Cross"] = true,        ["Head Mounted Camera"] = true,
    ["Photo Camera"] = true, ["Salt Canister"] = true, ["Lighter"] = true,
    ["Lantern"] = true,      ["LIDAR Scanner"] = true,
    ["Holy Oil"] = true,     ["Flower Pot"] = true, ["Plushie"] = true,
}

local RED_ITEMS = {
    ["Music Box"] = true, ["Umdra Board"] = true, ["Haunted Mirror"] = true,
}

--===========================================================================
--//  SECTION ❸ – Utility Table & Helpers
--===========================================================================

local Utils       = {}            -- namespace for misc helpers
local espObjects  = {}            -- [Instance] = {main = Drawing, shadow = Drawing}

--==  Utils.Notify  ----------------------------------------------------------
function Utils.Notify(title, text, duration)
    duration = duration or 5
    if StarterGui and StarterGui.SetCore then
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration})
    end
end

--==  Utils.SafeRemoveDrawing  ----------------------------------------------
function Utils.SafeRemoveDrawing(d)
    if d and d.Visible ~= nil then
        d.Visible = false
        d:Remove()
    end
end

--==  Utils.GetRootPart  -----------------------------------------------------
function Utils.GetRootPart(model)
    if not (model and model:IsA("Model")) then return nil end
    return model:FindFirstChild("HumanoidRootPart")
       or model.PrimaryPart
       or model:FindFirstChildWhichIsA("BasePart")
end

--==  Utils.GetScaledTextSize  ----------------------------------------------
function Utils.GetScaledTextSize(distance)
    return (distance <= 30)
        and math.clamp(13 + (distance / 30) * 2, 13, 15)
        or  math.clamp(15 + ((distance - 30) / 70) * 3, 15, 18)
end

--==  Utils.PurgeDeadDrawings  ----------------------------------------------
function Utils.PurgeDeadDrawings()
    for inst, drawings in pairs(espObjects) do
        local valid = inst and inst.Parent and inst:IsDescendantOf(game) and inst:IsA("BasePart")
        if not valid then
            Utils.SafeRemoveDrawing(drawings.main)
            Utils.SafeRemoveDrawing(drawings.shadow)
            espObjects[inst] = nil
        end
    end
end

--===========================================================================
--//  SECTION ❹ – Drawing-API Guard Clause
--===========================================================================

--##  Abort gracefully if executor blocks Drawing API  -----------------------
local drawingSupported = pcall(function() return Drawing and Drawing.new end)
if not drawingSupported then
    Utils.Notify("Demonology ESP", "Drawing API not supported in this executor", 5)
    return
end

--===========================================================================
--//  SECTION ❺ – ESP Creation / Update Routines
--===========================================================================

--==  createOrUpdateTextESP  --------------------------------------------------
local function createOrUpdateTextESP(inst, label, color)
    if not (inst and inst:IsA("BasePart")) then return end

    local drawings = espObjects[inst]
    if not drawings then
        drawings = {
            main   = Drawing.new("Text"),
            shadow = Drawing.new("Text"),
        }
        espObjects[inst] = drawings

        -- shadow (glow)
        drawings.shadow.Size     = 15
        drawings.shadow.Center   = true
        drawings.shadow.Outline  = false
        drawings.shadow.Color    = Color3.new(0, 0, 0)
        drawings.shadow.Font     = 2  -- Comic Sans
        -- main text
        drawings.main.Size       = 13
        drawings.main.Center     = true
        drawings.main.Outline    = true
        drawings.main.Font       = 2
    end

    drawings.main.Text  = label
    drawings.main.Color = color or COLORS.Ghost
    drawings.main.Visible = true
end

--==  updateESPPositions  -----------------------------------------------------
local function updateESPPositions()
    local camPos = Camera.CFrame.Position
    for inst, drawings in pairs(espObjects) do
        local pos = inst.Position or (inst.CFrame and inst.CFrame.Position)
        if not pos then
            drawings.main.Visible, drawings.shadow.Visible = false, false
            continue
        end

        local screen, onScreen = Camera:WorldToViewportPoint(pos)
        if onScreen and screen.Z > 0 then
            local size = Utils.GetScaledTextSize((camPos - pos).Magnitude)
            local x, y = math.floor(screen.X), math.floor(screen.Y)

            drawings.main.Size       = size
            drawings.main.Position   = Vector2.new(x, y)
            drawings.main.Visible    = true

            drawings.shadow.Size     = size + 2
            drawings.shadow.Position = Vector2.new(x + 1, y + 1)
            drawings.shadow.Visible  = true
        else
            drawings.main.Visible, drawings.shadow.Visible = false, false
        end
    end
end

--===========================================================================
--//  SECTION ❻ – Data-Collection / ESP Trackers
--===========================================================================

--==  One-time alert helper  --------------------------------------------------
local alertOnce = {}
local function AlertMissing(key, msg, dur)
    if alertOnce[key] then return end
    alertOnce[key] = true
    Utils.Notify("Demonology ESP", msg, dur or 4)
    warn("[ESP] " .. msg)
end

--==  trackGhost  -------------------------------------------------------------
local function trackGhost()
    local ghost = Workspace:FindFirstChild("Ghost")
    if not (ghost and ghost:IsA("Model")) then return end

    local root = Utils.GetRootPart(ghost)
    if not root then AlertMissing("NoRoot", "Ghost has no root part") return end

    local attrs = {
        "CameraKillOffset","CurrentRoom","EventActive","GhostType","Gender",
        "Hunting","IsGhost","laservisible","PhotoRewardAvailable",
        "Transparency","TransparencyLocked","VisualModel"
    }
    local lines   = {"Ghost"}
    local missing = {}

    for _, a in ipairs(attrs) do
        local ok, v = pcall(function() return ghost:GetAttribute(a) end)
        if ok and v ~= nil then
            table.insert(lines, a .. ": " .. tostring(v))
        else
            table.insert(missing, a)
        end
    end

    if #missing > 0 then
        AlertMissing("MissingAttrs", "Missing Ghost Attrs: " .. table.concat(missing, ", "))
    end

    createOrUpdateTextESP(root, table.concat(lines, "\n"), COLORS.Ghost)
end

--==  trackFuseBox  -----------------------------------------------------------
local function trackFuseBox()
    local fb = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("FuseBox")
    if not fb then return end

    local part = fb:IsA("BasePart") and fb or fb:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local enabled = fb:GetAttribute("Enabled")
    local ui      = fb:GetAttribute("Uninteractible")
    local label   = ("Fuse Box\nEnabled: %s\nUninteractible: %s")
                  :format(tostring(enabled), tostring(ui))

    createOrUpdateTextESP(part, label, COLORS.FuseBox)
end

--==  trackGhostOrb  ----------------------------------------------------------
local function trackGhostOrb()
    local orb = Workspace:FindFirstChild("GhostOrb")
    if orb and orb:IsA("BasePart") then
        createOrUpdateTextESP(orb, "Ghost Orb", COLORS.GhostOrb)
    end
end

--==  trackCursedPossessions  -------------------------------------------------
local function trackCursedPossessions()
    local holder = Workspace:FindFirstChild("CursedPossessionHolder"); if not holder then return end
    for _, mdl in ipairs(holder:GetChildren()) do
        local circle = mdl:IsA("Model") and mdl:FindFirstChild("Circle")
        if circle and circle:IsA("BasePart") then
            createOrUpdateTextESP(circle, "Summoning Circle", COLORS.CursedRed)
        end
    end
end

--==  trackHandprints  --------------------------------------------------------
local function trackHandprints()
    local hp = Workspace:FindFirstChild("Handprints"); if not hp then return end
    for _, bp in ipairs(hp:GetChildren()) do
        if bp:IsA("BasePart") then
            createOrUpdateTextESP(bp, "Handprint", COLORS.Handprint)
        end
    end
end

--==  trackWorldObjects (Holy Oil + Salt)  -----------------------------------
local function trackWorldObjects()
    -- Holy Oil --------------------------------------------------------------
    for _, mdl in ipairs(Workspace:GetChildren()) do
        if mdl.Name == "HolyOil" and mdl:IsA("Model") then
            local inn    = mdl:FindFirstChild("HolyOil")
            local center = inn and inn:FindFirstChild("Center")
            if center and center:IsA("BasePart") then
                local txt = "Holy Oil"
                if inn:GetAttribute("burning")   then txt ..= " 🔥" end
                if inn:GetAttribute("disabled")  then txt ..= " (Disabled)" end
                local burned = inn:GetAttribute("burnedtimes")
                if typeof(burned) == "number" then txt ..= " | Burned: " .. burned end
                createOrUpdateTextESP(center, txt, COLORS.HolyOil)
            end
        end
    end

    -- Salt ------------------------------------------------------------------
    local salt = Workspace:FindFirstChild("SaltPiles")
    if not salt then return end
    for _, bp in ipairs(salt:GetDescendants()) do
        if bp:IsA("BasePart") and bp.Name == "Center" then
            local parent = bp.Parent
            if parent.Name == "SaltLine" then
                createOrUpdateTextESP(bp, "Salt Line", COLORS.SaltLine)
            elseif parent.Name == "DisturbedSaltLine" then
                createOrUpdateTextESP(bp, "Disturbed Salt", COLORS.DisturbedSaltLine)
            end
        end
    end
end

--==  trackItems  -------------------------------------------------------------
local function trackItems()
    local items = Workspace:FindFirstChild("Items"); if not items then return end
    for _, mdl in ipairs(items:GetChildren()) do
        local item = mdl:GetAttribute("ItemName")
        if not item then continue end
        local handle = mdl:FindFirstChild("Handle") or mdl:FindFirstChild("Screen")
        if handle and handle:IsA("BasePart") then
            local col = GREEN_ITEMS[item] and COLORS.ItemGreen
                     or RED_ITEMS[item]   and COLORS.ItemRed
                     or COLORS.Ghost
            createOrUpdateTextESP(handle, item, col)
        end
    end
end

--===========================================================================
--//  SECTION ❼ – Fancy Helper (Favorite Room Alert)
--===========================================================================

local function notifyGhostFavoriteRoom()
    local ghost = Workspace:FindFirstChild("Ghost"); if not ghost then return end
    local ok, room = pcall(function() return ghost:GetAttribute("FavoriteRoom") end)
    if ok and room then
        Utils.Notify("Favorite Room", tostring(room), 5)
    end
end

--===========================================================================
--//  SECTION ❽ – Tracker Pipeline & Render Loop
--===========================================================================

local trackers = {
    Utils.PurgeDeadDrawings,
    trackFuseBox,
    trackGhost,
    trackGhostOrb,
    trackCursedPossessions,
    trackHandprints,
    trackItems,
    trackWorldObjects,
    updateESPPositions,
}

--##  Throttled render-step pump  -------------------------------------------
local idx, throttle, accum = 1, 0.05, 0
RunService.RenderStepped:Connect(function(dt)
    accum += dt; if accum < throttle then return end; accum = 0
    local f = trackers[idx]; idx = (idx % #trackers) + 1
    local ok, err = pcall(f)
    if not ok then warn("[ESP] "..tostring(err)) end
end)

--===========================================================================
--//  SECTION ❾ – QoL Keybinds
--===========================================================================

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        InfiniteYield()   -- press ';' to execute InfiniteYield lazily
    end
end)

--===========================================================================
--//  SECTION ❿ – Startup Banner
--===========================================================================

Utils.Notify("Demonology ESP", "Loaded Successfully!\n(Made by @lime.bat on discord)", 3)
Utils.Notify("!", "Note that you can open infinte yeild by pressing ; on your keyboard", 3)
notifyGhostFavoriteRoom()

--###########################################################################
--##                         END-OF-FILE                                   ##
--###########################################################################
