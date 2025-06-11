--[[
    Nexus-Lua Script
    Master's Request: Fix dropdown error and add Destroy/Restart buttons.
    Update: Corrected element creation to be on Tab objects. Added System buttons.
    Functionality: UI Base, Auto Click, Auto Rebirth, Auto Hatch, UI Control
    Optimization: Mobile/Touchscreen
]]

-- Load the Rayfield User Interface Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Get the live name of the current game to use as the window title
local success, gameName = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- If fetching the name fails, use a default name
local windowTitle = success and gameName or "Game Hub"

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = windowTitle,
   LoadingTitle = "Nexus-Lua Interface",
   LoadingSubtitle = "Hooking into game services...",
   ConfigurationSaving = {
      Enabled = true,
      FileName = windowTitle .. " Hub"
   },
   KeySystem = false,
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

local ClickService = Knit.GetService('ClickService')
local RebirthService = Knit.GetService('RebirthService')
local EggService = Knit.GetService('EggService')
local DataController = Knit.GetController('DataController')
DataController:waitForData()

local RebirthsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Rebirths"))
local EggsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Pets"):WaitForChild("Eggs"))

local autoClicking, autoRebirthing, autoHatching = false, false, false

local function formatSuffix(number)
    local suffixes = {"", "K", "M", "B", "T", "Q", "Qi", "S", "O"}
    local index = 1
    while number >= 1000 and index < #suffixes do
        number = number / 1000
        index = index + 1
    end
    return string.format("%.1f%s", number, suffixes[index])
end

-- ================== Clicks Tab ==================
ClicksTab:CreateSection("Automation")
ClicksTab:CreateToggle({
   Name = "Auto Click",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
      autoClicking = Value
      Rayfield:Notify({Title = "Auto Click", Content = "Auto clicking has been " .. (Value and "enabled." or "disabled."), Duration = 3, Image = "mouse-pointer-click"})
      task.spawn(function()
         while autoClicking do
            pcall(function() ClickService.click:Fire() end)
            task.wait()
         end
      end)
   end,
})

-- ================== Pet Tab ==================
PetTab:CreateSection("Egg Hatching")
local eggOptions = {}
for name, data in pairs(EggsModule) do
    if not data.requiredMap or (DataController.data and DataController.data.maps[data.requiredMap]) then
        table.insert(eggOptions, string.format("%s Egg | %s Gems", name, formatSuffix(data.cost)))
    end
end

-- FIX: Dropdown must be created on the Tab, not the Section.
local EggDropdown = PetTab:CreateDropdown({
   Name = "Select Egg",
   Options = eggOptions,
   CurrentOption = {eggOptions[1] or "None"},
   MultipleOptions = false,
   Flag = "EggDropdown",
})

-- FIX: Toggle must be created on the Tab, not the Section.
PetTab:CreateToggle({
   Name = "Auto Hatch Selected Egg",
   CurrentValue = false,
   Flag = "AutoHatchToggle",
   Callback = function(Value)
        autoHatching = Value
        Rayfield:Notify({Title = "Auto Hatch", Content = "Auto hatching has been " .. (Value and "enabled." or "disabled."), Duration = 3, Image = "egg"})
        task.spawn(function()
            while autoHatching do
                local selectedOption = EggDropdown.CurrentOption[1]
                if selectedOption and selectedOption ~= "None" then
                    local eggName = selectedOption:match("^(%S+)")
                    pcall(function() EggService.openEgg:Fire(eggName, 1) end)
                end
                task.wait(1) 
            end
        end)
   end,
})

-- ================== Upgrades Tab ==================
UpgradesTab:CreateSection("Rebirthing")
local rebirthOptions = {}
local rebirthValueMap = {}
rebirthValueMap["Best Available"] = "best"
table.insert(rebirthOptions, "Best Available")
for i, amount in pairs(RebirthsModule) do
    local name = string.format("Buy %s Rebirths", formatSuffix(amount))
    table.insert(rebirthOptions, name)
    rebirthValueMap[name] = i
end

-- FIX: Dropdown must be created on the Tab, not the Section.
local RebirthDropdown = UpgradesTab:CreateDropdown({
   Name = "Rebirth Amount",
   Options = rebirthOptions,
   CurrentOption = {"Best Available"},
   MultipleOptions = false,
   Flag = "RebirthDropdown",
})

-- FIX: Toggle must be created on the Tab, not the Section.
UpgradesTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
        autoRebirthing = Value
        Rayfield:Notify({Title = "Auto Rebirth", Content = "Auto rebirthing has been " .. (Value and "enabled." or "disabled."), Duration = 3, Image = "refresh-cw"})
        task.spawn(function()
            while autoRebirthing do
                local selectedOption = RebirthDropdown.CurrentOption[1]
                if selectedOption then
                    local rebirthIndex = rebirthValueMap[selectedOption]
                    if rebirthIndex == "best" then
                        local bestOption = 1
                        for i, _ in pairs(RebirthsModule) do
                             if RebirthService:canAfford(i) then bestOption = math.max(bestOption, i) end
                        end
                        rebirthIndex = bestOption
                    end
                    pcall(function() RebirthService:rebirth(rebirthIndex) end)
                end
                task.wait(0.5)
            end
        end)
   end,
})

-- ================== Settings Tab ==================
SettingsTab:CreateSection("System Controls")

SettingsTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
        Rayfield:Notify({Title = "System", Content = "GUI Destroyed.", Duration = 3, Image = "trash-2"})
        task.wait(0.1)
        Rayfield:Destroy()
   end,
})

SettingsTab:CreateButton({
   Name = "Restart Script",
   Callback = function()
        Rayfield:Notify({Title = "System", Content = "Restarting in 3 seconds...", Duration = 3, Image = "power"})
        Rayfield:Destroy()
        task.wait(3)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))()
   end,
})

-- Load the saved settings after all elements have been created
Rayfield:LoadConfiguration()
