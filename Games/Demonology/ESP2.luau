-- Demonology ESP Drawing Edition v1.3.0 (with QoL + perf revamps)

--// Services ---------------------------------------------------------------
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local Players     = game:GetService("Players")
local StarterGui  = game:GetService("StarterGui")
local UIS         = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local infiniteyeild = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
))

--// Palette ---------------------------------------------------------------
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

local GREEN_ITEMS = {
    ["Video Camera"]      = true, ["Thermometer"]      = true,
    ["Spirit Book"]       = true, ["Blacklight"]       = true,
    ["Spirit Box"]        = true, ["EMF Reader"]       = true,
    ["Flashlight"]        = true, ["Laser Projector"]  = true,
    ["Energy Drink"]      = true, ["Energy Watch"]     = true,
    ["Cross"]             = true, ["Head Mounted Camera"] = true,
    ["Photo Camera"]      = true, ["Salt Canister"]    = true,
    ["Lighter"]           = true, ["Lantern"]          = true,
    ["LIDAR Scanner"]     = true, ["Holy Oil"]         = true,
    ["Flower Pot"]        = true, ["Plushie"]          = true,
}
local RED_ITEMS   = { ["Music Box"]=true, ["Umdra Board"]=true, ["Haunted Mirror"]=true }

--// Utils ------------------------------------------------------------------
local Utils, espObjects = {}, {}

function Utils.Notify(title,text,dur)
    dur = dur or 5
    if StarterGui and StarterGui.SetCore then
        StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=dur})
    end
end

function Utils.SafeRemoveDrawing(d)
    if d and d.Visible~=nil then d.Visible = false; d:Remove() end
end

function Utils.GetRootPart(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
           or model:FindFirstChildWhichIsA("BasePart")
end

function Utils.GetScaledTextSize(dist)
    return dist <= 30
        and math.clamp(13 + (dist/30)*2, 13, 15)
        or  math.clamp(15 + ((dist-30)/70)*3, 15, 18)
end

-- Drawing API guard-clause
local drawingSupported = pcall(function() return Drawing and Drawing.new end)
if not drawingSupported then
    Utils.Notify("Demonology ESP","Drawing API not supported in this executor",5)
    return
end

--// Core ESP helpers -------------------------------------------------------
local function createOrUpdateTextESP(inst,label,color)
    if not inst or not inst:IsA("BasePart") then return end

    local drawings = espObjects[inst]
    if not drawings then
        drawings = { main = Drawing.new("Text"),
                     shadow = Drawing.new("Text") }
        espObjects[inst] = drawings

        drawings.shadow.Size, drawings.shadow.Center = 15, true
        drawings.shadow.Outline, drawings.shadow.Color, drawings.shadow.Font = false, Color3.new(), 2

        drawings.main.Size, drawings.main.Center, drawings.main.Outline, drawings.main.Font =
            13, true, true, 2
    end

    drawings.main.Text, drawings.main.Color = label, color or COLORS.Ghost
    drawings.main.Visible = true
end

-- purge any dead instances / drawings
function Utils.PurgeDeadDrawings()
    for inst,draws in pairs(espObjects) do
        local valid = inst and inst.Parent and inst:IsDescendantOf(game) and inst:IsA("BasePart")
        if not valid then
            Utils.SafeRemoveDrawing(draws.main)
            Utils.SafeRemoveDrawing(draws.shadow)
            espObjects[inst] = nil
        end
    end
end

-- update on-screen positions / sizes
local function updateESPPositions()
    local camPos = Camera.CFrame.Position
    for inst,draws in pairs(espObjects) do
        local p = inst.Position or (inst.CFrame and inst.CFrame.Position)
        if not p then draws.main.Visible,draws.shadow.Visible = false,false; continue end

        local v2,onScreen = Camera:WorldToViewportPoint(p)
        if onScreen and v2.Z>0 then
            local size = Utils.GetScaledTextSize((camPos-p).Magnitude)
            local x,y  = math.floor(v2.X), math.floor(v2.Y)

            draws.main.Size,   draws.main.Position,   draws.main.Visible   = size,     Vector2.new(x,y),     true
            draws.shadow.Size, draws.shadow.Position, draws.shadow.Visible = size+2,   Vector2.new(x+1,y+1), true
        else
            draws.main.Visible, draws.shadow.Visible = false,false
        end
    end
end

--// Trackers ---------------------------------------------------------------
local alertOnce = {}
local function AlertMissing(key,msg,dur)
    if alertOnce[key] then return end
    alertOnce[key]=true;  Utils.Notify("Demonology ESP",msg,dur or 4);  warn(msg)
end

local function trackGhost()
    local ghost = Workspace:FindFirstChild("Ghost")
    if not (ghost and ghost:IsA("Model")) then return end

    local root = Utils.GetRootPart(ghost)
    if not root then AlertMissing("NoRoot","Ghost has no root part") return end

    local attrs,missing = {
        "CameraKillOffset","CurrentRoom","EventActive","GhostType","Gender",
        "Hunting","IsGhost","laservisible","PhotoRewardAvailable",
        "Transparency","TransparencyLocked","VisualModel"
    },{}

    local lines={"Ghost"}
    for _,a in ipairs(attrs) do
        local ok,v = pcall(function() return ghost:GetAttribute(a) end)
        if ok and v~=nil then table.insert(lines,a..": "..tostring(v))
        else table.insert(missing,a) end
    end
    if #missing>0 then AlertMissing("MissAttrs","Missing Ghost Attrs:\n"..table.concat(missing,", ")) end

    createOrUpdateTextESP(root,table.concat(lines,"\n"),COLORS.Ghost)
end

local function trackFuseBox()
    local fb = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("FuseBox")
    if not fb then return end
    local part = fb:IsA("BasePart") and fb or fb:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local enabled = fb:GetAttribute("Enabled")
    local ui      = fb:GetAttribute("Uninteractible")
    local label   = ("Fuse Box\nEnabled: %s\nUninteractible: %s")
                    :format(tostring(enabled),tostring(ui))
    createOrUpdateTextESP(part,label,COLORS.FuseBox)
end

local function trackGhostOrb()
    local orb = Workspace:FindFirstChild("GhostOrb")
    if orb and orb:IsA("BasePart") then
        createOrUpdateTextESP(orb,"Ghost Orb",COLORS.GhostOrb)
    end
end

local function trackCursedPossessions()
    local holder = Workspace:FindFirstChild("CursedPossessionHolder"); if not holder then return end
    for _,m in ipairs(holder:GetChildren()) do
        local circle = m:IsA("Model") and m:FindFirstChild("Circle")
        if circle and circle:IsA("BasePart") then
            createOrUpdateTextESP(circle,"Summoning Circle",COLORS.CursedRed)
        end
    end
end

local function trackHandprints()
    local hp = Workspace:FindFirstChild("Handprints"); if not hp then return end
    for _,p in ipairs(hp:GetChildren()) do
        if p:IsA("BasePart") then createOrUpdateTextESP(p,"Handprint",COLORS.Handprint) end
    end
end

local function trackWorldObjects()
    -- Holy Oil
    for _,model in ipairs(Workspace:GetChildren()) do
        if model.Name=="HolyOil" and model:IsA("Model") then
            local inn = model:FindFirstChild("HolyOil")
            local center = inn and inn:FindFirstChild("Center")
            if center and center:IsA("BasePart") then
                local txt="Holy Oil"
                if inn:GetAttribute("burning") then txt..=" 🔥" end
                if inn:GetAttribute("disabled") then txt..=" (Disabled)" end
                local burned=inn:GetAttribute("burnedtimes")
                if typeof(burned)=="number" then txt..=" | Burned: "..burned end
                createOrUpdateTextESP(center,txt,COLORS.HolyOil)
            end
        end
    end
    -- Salt
    local salt=Workspace:FindFirstChild("SaltPiles")
    if salt then
        for _,obj in ipairs(salt:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name=="Center" then
                local parent=obj.Parent
                if parent.Name=="SaltLine" then
                    createOrUpdateTextESP(obj,"Salt Line",COLORS.SaltLine)
                elseif parent.Name=="DisturbedSaltLine" then
                    createOrUpdateTextESP(obj,"Disturbed Salt",COLORS.DisturbedSaltLine)
                end
            end
        end
    end
end

local function trackItems()
    local items=Workspace:FindFirstChild("Items"); if not items then return end
    for _,mdl in ipairs(items:GetChildren()) do
        local item=mdl:GetAttribute("ItemName"); if not item then continue end
        local handle = mdl:FindFirstChild("Handle") or mdl:FindFirstChild("Screen")
        if handle and handle:IsA("BasePart") then
            local col = GREEN_ITEMS[item] and COLORS.ItemGreen
                     or RED_ITEMS[item]   and COLORS.ItemRed
                     or COLORS.Ghost
            createOrUpdateTextESP(handle,item,col)
        end
    end
end

--// Misc helpers -----------------------------------------------------------
local function notifyGhostFavoriteRoom()
    local ghost = Workspace:FindFirstChild("Ghost"); if not ghost then return end
    local ok,room = pcall(function() return ghost:GetAttribute("FavoriteRoom") end)
    if ok and room then Utils.Notify("Favorite Room",tostring(room),5) end
end

--// Tracker pipeline -------------------------------------------------------
local trackers = {
    Utils.PurgeDeadDrawings, trackFuseBox, trackGhost, trackGhostOrb,
    trackCursedPossessions, trackHandprints, trackItems, trackWorldObjects,
    updateESPPositions,
}

-- run one tracker per N seconds (throttled)
local throttle,accum,idx = 0.05,0,1
RunService.RenderStepped:Connect(function(dt)
    accum += dt; if accum < throttle then return end; accum = 0
    local f = trackers[idx]; idx = (idx % #trackers)+1
    local ok,err = pcall(f); if not ok then warn("[ESP] "..tostring(err)) end
end)

--// Quality-of-life keybinds ----------------------------------------------
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.Semicolon then
        infiniteyeild()   -- press ; to inject InfiniteYield
    end
end)

--// Startup ----------------------------------------------------------------
Utils.Notify("Demonology ESP","ESP Loaded Successfully!\n(Made by @lime.bat)",3)
notifyGhostFavoriteRoom()
