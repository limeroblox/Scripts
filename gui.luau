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
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Loading gui..",
    LoadingSubtitle = "only mobile compadiable ui :P",
    Theme = HackerTheme, 
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })
-- Tabs 
 local Tab = Window:CreateTab("Human", 12823489278)
