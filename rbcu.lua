--[[
    Nexus-Lua Script
    Update: Reverted automation to use direct commands (:Fire(), :rebirth())
    within our own loops for maximum reliability, as per Master's diagnosis.
    The native switches (:setIsAuto...) were found to be unreliable.
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

-- Loop control variables
local autoClicking, autoRebirthing, autoHatching = false, false, false

local function formatSuffix(number)
    local s = {"", "K", "M", "B", "T", "Q", "Qi", "S", "O"}; local i=1
    while number >= 1e3 and i < #s do number, i = number / 1e3, i + 1 end
    return ("%.1f"):format(number)..s[i]
end

-- ================== Clicks Tab (Reverted to Reliable Loop) ==================
ClicksTab:CreateSection("Automation")
ClicksTab:CreateToggle({
   Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle",
   Callback = function(Value)
      autoClicking = Value
      Rayfield:Notify({Title = "Auto Click", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "mouse-pointer-click"})
      
      -- We now control the loop ourselves for reliability.
      task.spawn(function()
          while autoClicking do
              pcall(function()
                  -- As confirmed by the reference script, this is the direct command.
                  ClickService.click:Fire()
              end)
              task.wait() -- A small wait to prevent crashing.
          end
      end)
   end,
})

-- ================== Pet Tab (Reverted to Reliable Loop) ==================
PetTab:CreateSection("Egg Hatching")
local eggOptions = {}
for name, data in pairs(EggsModule) do
    if not data.requiredMap or (DataController.data and DataController.data.maps[data.requiredMap]) then
        table.insert(eggOptions, string.format("%s Egg | %s Gems", name, formatSuffix(data.cost)))
    end
end
local EggDropdown = PetTab:CreateDropdown({Name = "Select Egg", Options = eggOptions, CurrentOption = {eggOptions[1] or "None"}, Flag = "EggDropdown"})

PetTab:CreateToggle({
   Name = "Auto Hatch Selected Egg", CurrentValue = false, Flag = "AutoHatchToggle",
   Callback = function(Value)
        autoHatching = Value
        Rayfield:Notify({Title = "Auto Hatch", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "egg"})
        
        -- Our own reliable loop for hatching.
        task.spawn(function()
            while autoHatching do
                local selectedOption = EggDropdown.CurrentOption[1]
                if selectedOption and selectedOption ~= "None" then
                    local eggName = selectedOption:match("^(%S+)")
                    pcall(function()
                        -- Firing the openEgg event directly.
                        EggService.openEgg:Fire(eggName, 2)
                    end)
                end
                task.wait(1) -- Wait between hatches.
            end
        end)
   end,
})

-- ================== Upgrades Tab (Reverted to Reliable Loop) ==================
UpgradesTab:CreateSection("Rebirthing")
local rebirthOptions, rebirthValueMap = {"Best Available"}, {["Best Available"] = "best"}
for i, amount in pairs(RebirthsModule) do
    local name = string.format("Buy %s Rebirths", formatSuffix(amount))
    table.insert(rebirthOptions, name)
    rebirthValueMap[name] = i
end
local RebirthDropdown = UpgradesTab:CreateDropdown({Name = "Rebirth Amount", Options = rebirthOptions, CurrentOption = {"Best Available"}, Flag = "RebirthDropdown"})

UpgradesTab:CreateToggle({
   Name = "Auto Rebirth", CurrentValue = false, Flag = "AutoRebirthToggle",
   Callback = function(Value)
        autoRebirthing = Value
        Rayfield:Notify({Title = "Auto Rebirth", Content = "Set to: " .. tostring(Value), Duration = 3, Image = "refresh-cw"})

        -- Our own reliable loop for rebirthing.
        task.spawn(function()
            while autoRebirthing do
                local selectedOption = RebirthDropdown.CurrentOption[1]
                if selectedOption then
                    local rebirthIndex = rebirthValueMap[selectedOption]
                    if rebirthIndex == "best" then
                        local bestOption = 1
                        for i, _ in pairs(RebirthsModule) do if RebirthService:canAfford(i) then bestOption = math.max(bestOption, i) end end
                        rebirthIndex = bestOption
                    end
                    -- Calling the :rebirth() function directly.
                    pcall(function() RebirthService:rebirth(rebirthIndex) end)
                end
                task.wait(0.5) -- Check every half-second.
            end
        end)
   end,
})

-- ================== Settings Tab ==================
SettingsTab:CreateSection("System Controls")
SettingsTab:CreateButton({Name = "Destroy GUI", Callback = function() Rayfield:Destroy() end})
SettingsTab:CreateButton({Name = "Restart Script", Callback = function() Rayfield:Destroy(); task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))() end})

Rayfield:LoadConfiguration()
