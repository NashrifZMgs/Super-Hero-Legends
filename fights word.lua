--[[
    Script: Fighting Sword UI
    Creator: Nexus-Lua for Master
    Description: A clean and foundational UI for a sword fighting game,
                 created with the Rayfield library.
    Version: 1.5 (Corrected Teleport List)
]]

-- Services and Player Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- A table to store the teleport locations in the exact order requested.
-- This structure ensures the dropdown list is not sorted alphabetically.
local TeleportLocations = {
    {Name = "Castle", CFrame = CFrame.new(-355.024994, 108.439995, -361.704987, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
    {Name = "Mushroom Forest", CFrame = CFrame.new(-416.749054, 189.613907, -2692.51074, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Desert Pyramid", CFrame = CFrame.new(-390.09903, 14.413908, -5540.87012, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Snow Land", CFrame = CFrame.new(-399.999023, 219.813904, -7700.34033, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Underwater", CFrame = CFrame.new(-279.721466, 45.7929802, -10495.709, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Alien Desert", CFrame = CFrame.new(-369.141479, 106.532974, -12073.459, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Candy", CFrame = CFrame.new(-364.411469, 107.392982, -13334.5283, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Altar", CFrame = CFrame.new(-410.60144, -20.6570206, -15130.6377, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Demon King", CFrame = CFrame.new(-519.031433, -239.126999, -17261.8574, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Heavenly Gates", CFrame = CFrame.new(-519.031433, -239.126999, -19761.8574, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Halls of Valhalla", CFrame = CFrame.new(-763.321106, -239.126999, -21523.373, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Voidfallen Kingdom", CFrame = CFrame.new(-763.321106, -239.126999, -24417.9688, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "Realm of the Monkey King", CFrame = CFrame.new(-763.321106, -239.126999, -27791.25, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "The Fractal Fortress", CFrame = CFrame.new(-763.321106, -239.126999, -29846.2305, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "The Timeless Cavern", CFrame = CFrame.new(-763.321106, -239.126999, -32819.2891, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
    {Name = "World 16 (Unnamed)", CFrame = CFrame.new(-416.749054, 189.613907, -36787.7656, 1, 0, 0, 0, 1, 0, 0, 0, 1)}
}

-- I have assumed the final CFrame belongs to the 16th world. I have named it "World 16 (Unnamed)".
-- If you provide a name, I will replace it.
-- Based on your new list, I have re-mapped the names from 'Underwater' onwards to the subsequent CFrame data.

-- Helper function to get the names of the locations for the dropdown
local function getLocationNames()
    local names = {}
    for i, data in ipairs(TeleportLocations) do
        table.insert(names, data.Name)
    end
    return names
end

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

-- Create Tabs in the correct order
local FarmTab = Window:CreateTab("Farm", "swords") 
local PetTab = Window:CreateTab("Pet", "dog")
local MapTab = Window:CreateTab("Map", "map") 
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local UpgradeTab = Window:CreateTab("Upgrade", "arrow-up-circle") 
local MiscTab = Window:CreateTab("Misc", "sliders-horizontal")
local ProfileTab = Window:CreateTab("Profile", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")


--[[ Map Tab Content ]]
local TeleportSection = MapTab:CreateSection("Teleport")

local TeleportDropdown = MapTab:CreateDropdown({
   Name = "Select Destination",
   Options = getLocationNames(),
   CurrentOption = {getLocationNames()[1]},
   Flag = "TeleportDestination",
   Callback = function(Option) end,
})

local TeleportButton = MapTab:CreateButton({
   Name = "Teleport",
   Callback = function()
       local character = LocalPlayer.Character
       local rootPart = character and character:FindFirstChild("HumanoidRootPart")
       
       if not rootPart then
           Rayfield:Notify({Title = "Error", Content = "Cannot find your character.", Duration = 5, Image = "alert-triangle"})
           return
       end

       local selectedLocationName = TeleportDropdown.CurrentOption[1]
       local targetCFrame

       -- Find the CFrame that matches the selected name
       for i, data in ipairs(TeleportLocations) do
           if data.Name == selectedLocationName then
               targetCFrame = data.CFrame
               break
           end
       end

       if targetCFrame then
           rootPart.CFrame = targetCFrame
           Rayfield:Notify({Title = "Teleport", Content = "Successfully teleported to " .. selectedLocationName, Duration = 5, Image = "send"})
       else
           Rayfield:Notify({Title = "Error", Content = "Invalid location selected.", Duration = 5, Image = "alert-triangle"})
       end
   end,
})


--[[ Profile Tab Content ]]
local StatsSection = ProfileTab:CreateSection("Live Player Stats")
local KillsLabel = ProfileTab:CreateButton({Name = "Kills: Loading...", Callback = function() end})
local RebirthsLabel = ProfileTab:CreateButton({Name = "Rebirths: Loading...", Callback = function() end})
local WinsLabel = ProfileTab:CreateButton({Name = "Wins: Loading...", Callback = function() end})

local function trackStat(statName, labelElement, prefix)
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
    if not leaderstats then labelElement:Set(prefix .. ": Not Found") return end
    local statObject = leaderstats:FindFirstChild(statName)
    if statObject then
        labelElement:Set(prefix .. ": " .. statObject.Value)
        statObject.Changed:Connect(function(newValue) labelElement:Set(prefix .. ": " .. newValue) end)
    else
        labelElement:Set(prefix .. ": Not Found")
    end
end

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
