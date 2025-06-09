--[[
    Script: Fighting Sword UI
    Creator: Nexus-Lua for Master
    Description: A clean and foundational UI for a sword fighting game,
                 created with the Rayfield library.
    Version: 1.4 (Teleport Feature)
]]

-- Services and Player Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- A table to store the teleport locations for easy management.
-- Each location has a name and its corresponding CFrame data.
local TeleportLocations = {
    ["Castle"] = CFrame.new(-355.024994, 108.439995, -361.704987, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Mushroom Forest"] = CFrame.new(-416.749054, 189.613907, -2692.51074, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Desert Pyramid"] = CFrame.new(-390.09903, 14.413908, -5540.87012, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Snow Land"] = CFrame.new(-399.999023, 219.813904, -7700.34033, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Alien Desert"] = CFrame.new(-279.721466, 45.7929802, -10495.709, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Candy"] = CFrame.new(-369.141479, 106.532974, -12073.459, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Energy Factory"] = CFrame.new(-364.411469, 107.392982, -13334.5283, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Altar"] = CFrame.new(-410.60144, -20.6570206, -15130.6377, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Demon King"] = CFrame.new(-519.031433, -239.126999, -17261.8574, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Heavenly Gates"] = CFrame.new(-519.031433, -239.126999, -19761.8574, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Halls of Valhalla"] = CFrame.new(-763.321106, -239.126999, -21523.373, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Voidfallen Kingdom"] = CFrame.new(-763.321106, -239.126999, -24417.9688, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Realm of the Monkey King"] = CFrame.new(-763.321106, -239.126999, -27791.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["The Fractal Fortress"] = CFrame.new(-763.321106, -239.126999, -29846.2305, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["The Timeless Cavern"] = CFrame.new(-763.321106, -239.126999, -32819.2891, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

-- Helper function to get the names of the locations for the dropdown
local function getLocationNames()
    local names = {}
    for name, _ in pairs(TeleportLocations) do
        table.insert(names, name)
    end
    table.sort(names) -- Sort names alphabetically for user convenience
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
local MapTab = Window:CreateTab("Map", "map") -- New Map Tab
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
   CurrentOption = {getLocationNames()[1]}, -- Default to the first option
   Flag = "TeleportDestination",
   Callback = function(Option)
       -- Callback is not needed for the button press, but is here for structure
   end,
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
       local targetCFrame = TeleportLocations[selectedLocationName]

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
