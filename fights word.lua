--[[
    Script: Fighting Sword UI
    Creator: Nexus-Lua for Master
    Description: A clean and foundational UI for a sword fighting game,
                 created with the Rayfield library.
    Version: 1.2 (Live Stats)
]]

-- Services and Player Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load the Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "Fighting Sword",
   LoadingTitle = "Fighting Sword Interface",
   LoadingSubtitle = "by Nexus-Lua",
   Theme = "Amethyst",
   ToggleUIKeybind = Enum.KeyCode.LeftControl,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FightingSwordConfig",
      FileName = "FightingSword"
   }
})

-- Create Tabs
local FarmTab = Window:CreateTab("Farm", "swords") 
local PetTab = Window:CreateTab("Pet", "dog")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local UpgradeTab = Window:CreateTab("Upgrade", "arrow-up-circle") 
local MiscTab = Window:CreateTab("Misc", "sliders-horizontal")
local ProfileTab = Window:CreateTab("Profile", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

--[[ Profile Tab Content ]]
local StatsSection = ProfileTab:CreateSection("Live Player Stats")

-- Create buttons to act as labels for displaying stats.
-- They are given a default "Loading..." text.
local KillsLabel = ProfileTab:CreateButton({ Name = "Kills: Loading..." })
local RebirthsLabel = ProfileTab:CreateButton({ Name = "Rebirths: Loading..." })
local WinsLabel = ProfileTab:CreateButton({ Name = "Wins: Loading..." })

-- Function to safely find and connect a stat to its label
local function trackStat(statName, labelElement, prefix)
    -- Wait for the leaderstats folder to ensure it has loaded
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
    
    if not leaderstats then
        labelElement:Set(prefix .. ": Not Found")
        return
    end

    local statObject = leaderstats:FindFirstChild(statName)

    if statObject then
        -- Set the initial text with the current stat value
        labelElement:Set(prefix .. ": " .. statObject.Value)
        
        -- Connect to the .Changed event to update the label in real-time
        statObject.Changed:Connect(function(newValue)
            labelElement:Set(prefix .. ": " .. newValue)
        end)
    else
        -- If the stat cannot be found, update the label to inform the user
        labelElement:Set(prefix .. ": Not Found")
    end
end

-- Call the function for each stat using the exact names you provided
trackStat("\240\159\146\128 Kill", KillsLabel, "Kills")
trackStat("\240\159\145\145Rebirth", RebirthsLabel, "Rebirths")
trackStat("\240\159\143\134Wins", WinsLabel, "Wins")


--[[ Settings Tab Content ]]
local UISection = SettingsTab:CreateSection("UI Management")

local DestroyButton = SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
       Rayfield:Destroy()
   end,
})

-- Load the saved configuration for all elements
Rayfield:LoadConfiguration()
