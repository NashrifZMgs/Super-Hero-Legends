--[[
    Nexus-Lua Script
    Update: Enhanced Auto Rebirth and Auto Hatch to use native game functions
    discovered with the Interrogator. This is more efficient and reliable.
]]

-- Load the Rayfield User Interface Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local success, gameName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
local windowTitle = success and gameName or "Game Hub"

local Window = Rayfield:CreateWindow({
   Name = windowTitle,
   LoadingTitle = "Nexus-Lua Interface",
   LoadingSubtitle = "Hooking into game services...",
   ConfigurationSaving = { Enabled = true, FileName = windowTitle .. " Hub" },
})

-- ================== Tabs ==================
local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click")
local PetTab = Window:CreateTab("Pet", "paw-print")
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle")
local MapTab = Window:CreateTab("Map", "map")
local MiscTab = Window:CreateTab("Misc", "package")
local ProfileTab = Window:CreateTab("Profile", "user-circle")
local SettingsTab = Window:CreateTab("Settings", "settings-2")

-- ================== Modules & Variables ==================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local ClickService, RebirthService, EggService = Knit.GetService('ClickService'), Knit.GetService('RebirthService'), Knit.GetService('EggService')
local DataController = Knit.GetController('DataController'); DataController:waitForData()
local RebirthsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Rebirths"))
local EggsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Pets"):WaitForChild("Eggs"))

local function formatSuffix(number)
    local s = {"", "K", "M", "B", "T", "Q", "Qi", "S", "O"}; local i=1
    while number >= 1e3 and i < #s do number, i = number / 1e3, i + 1 end
    return ("%.1f"):format(number)..s[i]
end

-- ================== Clicks Tab ==================
ClicksTab:CreateSection("Automation")
ClicksTab:CreateToggle({
   Name = "Auto Click (Native)", CurrentValue = false, Flag = "AutoClickToggle",
   Callback = function(Value)
      pcall(function() ClickService.setIsAutoClicking(Value) end)
      Rayfield:Notify({Title = "Native Auto Click", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "mouse-pointer-click"})
   end,
})

-- ================== Pet Tab (ENHANCED) ==================
PetTab:CreateSection("Egg Hatching")
local eggOptions = {}
for name, data in pairs(EggsModule) do
    if not data.requiredMap or (DataController.data and DataController.data.maps[data.requiredMap]) then
        table.insert(eggOptions, string.format("%s Egg | %s Gems", name, formatSuffix(data.cost)))
    end
end
local EggDropdown = PetTab:CreateDropdown({Name = "Select Egg", Options = eggOptions, CurrentOption = {eggOptions[1] or "None"}, Flag = "EggDropdown"})

-- This now uses the game's own auto-hatcher.
-- Note: This will likely hatch the egg selected in the GAME'S UI, not necessarily our dropdown.
-- Our dropdown is now mainly for the manual "Hatch Once" button below.
PetTab:CreateToggle({
   Name = "Auto Hatch (Native)", CurrentValue = false, Flag = "AutoHatchToggle",
   Callback = function(Value)
        pcall(function() EggService:setIsAutoHatching(Value) end)
        Rayfield:Notify({Title = "Native Auto Hatch", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "egg"})
   end,
})

-- Added a manual hatch button for precise control
PetTab:CreateButton({
    Name = "Hatch Selected Egg Once",
    Callback = function()
        local selectedOption = EggDropdown.CurrentOption[1]
        if selectedOption and selectedOption ~= "None" then
            local eggName = selectedOption:match("^(%S+)")
            pcall(function() EggService:openEgg(eggName, 1) end)
            Rayfield:Notify({Title = "Hatch", Content = "Attempted to hatch one " .. eggName .. " egg.", Duration = 3, Image = "egg"})
        end
    end,
})


-- ================== Upgrades Tab (ENHANCED) ==================
UpgradesTab:CreateSection("Rebirthing")

-- The dropdown is still useful for manual rebirths or if the auto-rebirth targets a specific amount.
local rebirthOptions, rebirthValueMap = {"Best Available"}, {["Best Available"] = "best"}
for i, amount in pairs(RebirthsModule) do
    local name = string.format("Buy %s Rebirths", formatSuffix(amount))
    table.insert(rebirthOptions, name)
    rebirthValueMap[name] = i
end
local RebirthDropdown = UpgradesTab:CreateDropdown({Name = "Rebirth Amount", Options = rebirthOptions, CurrentOption = {"Best Available"}, Flag = "RebirthDropdown"})

-- This now uses the game's own auto-rebirther.
UpgradesTab:CreateToggle({
   Name = "Auto Rebirth (Native)", CurrentValue = false, Flag = "AutoRebirthToggle",
   Callback = function(Value)
        pcall(function() RebirthService:setIsAutoRebirthing(Value) end)
        Rayfield:Notify({Title = "Native Auto Rebirth", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "refresh-cw"})
   end,
})

-- ================== Settings Tab ==================
SettingsTab:CreateSection("System Controls")
SettingsTab:CreateButton({Name = "Destroy GUI", Callback = function() Rayfield:Destroy() end})
SettingsTab:CreateButton({Name = "Restart Script", Callback = function() Rayfield:Destroy(); task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))() end})

Rayfield:LoadConfiguration()
