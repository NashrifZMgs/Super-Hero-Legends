--[[
    Nexus-Lua Script
    Master's Request: Add Auto Rebirth and Auto Hatching with dropdowns.
    Update: Implemented Rebirth and Hatching logic using Knit framework.
    Functionality: UI Base, Auto Click, Auto Rebirth, Auto Hatch
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
-- Wait for services to be available
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

-- Get all required services and controllers via Knit
local ClickService = Knit.GetService('ClickService')
local RebirthService = Knit.GetService('RebirthService')
local EggService = Knit.GetService('EggService')
local DataController = Knit.GetController('DataController')
DataController:waitForData() -- Ensure player data is loaded

-- Get game data modules
local RebirthsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Rebirths"))
local EggsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("List"):WaitForChild("Pets"):WaitForChild("Eggs"))

-- Loop control variables
local autoClicking = false
local autoRebirthing = false
local autoHatching = false

-- Helper function to format large numbers for display
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
local ClicksSection = ClicksTab:CreateSection("Automation")

ClicksTab:CreateToggle({
   Name = "Auto Click",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
      autoClicking = Value
      if autoClicking then
          Rayfield:Notify({Title = "Auto Click", Content = "Started auto clicking.", Duration = 3, Image = "mouse-pointer-click"})
      else
          Rayfield:Notify({Title = "Auto Click", Content = "Stopped auto clicking.", Duration = 3, Image = "mouse-pointer-click"})
      end

      task.spawn(function()
         while autoClicking do
            pcall(function()
                ClickService.click:Fire()
            end)
            task.wait()
         end
      end)
   end,
})

-- ================== Pet Tab ==================
local HatchingSection = PetTab:CreateSection("Egg Hatching")

-- Populate the egg dropdown
local eggOptions = {}
for name, data in pairs(EggsModule) do
    -- Only add eggs the player has unlocked the map for
    if not data.requiredMap or (DataController.data and DataController.data.maps[data.requiredMap]) then
        table.insert(eggOptions, string.format("%s Egg | %s Gems", name, formatSuffix(data.cost)))
    end
end

local EggDropdown = HatchingSection:CreateDropdown({
   Name = "Select Egg",
   Options = eggOptions,
   CurrentOption = {eggOptions[1]},
   MultipleOptions = false,
   Flag = "EggDropdown",
   Callback = function(Options)
      -- Callback is handled by the toggle reading this dropdown's value
   end,
})

HatchingSection:CreateToggle({
   Name = "Auto Hatch Selected Egg",
   CurrentValue = false,
   Flag = "AutoHatchToggle",
   Callback = function(Value)
        autoHatching = Value
        if autoHatching then
            Rayfield:Notify({Title = "Auto Hatch", Content = "Started hatching eggs.", Duration = 3, Image = "egg"})
        else
            Rayfield:Notify({Title = "Auto Hatch", Content = "Stopped hatching eggs.", Duration = 3, Image = "egg"})
        end

        task.spawn(function()
            while autoHatching do
                local selectedOption = EggDropdown.CurrentOption[1]
                if selectedOption then
                    -- Extract the internal egg name from the display text
                    local eggName = selectedOption:match("^(%S+)")
                    
                    pcall(function()
                        -- Fire the event to open 1 egg. Opening one by one is safer.
                        EggService.openEgg:Fire(eggName, 1)
                    end)
                end
                -- The reference script calculates wait time based on hatch speed.
                -- A static wait is safer to avoid issues.
                task.wait(1) 
            end
        end)
   end,
})

-- ================== Upgrades Tab ==================
local RebirthSection = UpgradesTab:CreateSection("Rebirthing")

-- Populate the rebirth dropdown
local rebirthOptions = {}
local rebirthValueMap = {} -- Map display name to rebirth index
rebirthValueMap["Best Available"] = "best"
table.insert(rebirthOptions, "Best Available")

for i, amount in pairs(RebirthsModule) do
    local name = string.format("Buy %s Rebirths", formatSuffix(amount))
    table.insert(rebirthOptions, name)
    rebirthValueMap[name] = i -- Store the index 'i'
end

local RebirthDropdown = RebirthSection:CreateDropdown({
   Name = "Rebirth Amount",
   Options = rebirthOptions,
   CurrentOption = {"Best Available"},
   MultipleOptions = false,
   Flag = "RebirthDropdown",
   Callback = function(Options)
      -- Callback handled by the toggle
   end,
})

RebirthSection:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
        autoRebirthing = Value
        if autoRebirthing then
            Rayfield:Notify({Title = "Auto Rebirth", Content = "Auto rebirthing enabled.", Duration = 3, Image = "refresh-cw"})
        else
            Rayfield:Notify({Title = "Auto Rebirth", Content = "Auto rebirthing disabled.", Duration = 3, Image = "refresh-cw"})
        end
        
        task.spawn(function()
            while autoRebirthing do
                local selectedOption = RebirthDropdown.CurrentOption[1]
                if selectedOption then
                    local rebirthIndex = rebirthValueMap[selectedOption]
                    
                    if rebirthIndex == "best" then
                        -- Find the best affordable option if 'Best Available' is selected
                        -- This is a simplified version of the reference script's logic
                        local bestOption = 1
                        for i, _ in pairs(RebirthsModule) do
                             if RebirthService:canAfford(i) then
                                bestOption = math.max(bestOption, i)
                             end
                        end
                        rebirthIndex = bestOption
                    end
                    
                    pcall(function()
                        RebirthService:rebirth(rebirthIndex)
                    end)
                end
                task.wait(0.5) -- Check every half second
            end
        end)
   end,
})

-- Load the saved settings after all elements have been created
Rayfield:LoadConfiguration()
