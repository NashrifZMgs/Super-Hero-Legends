--[[
    Script: Paper Plane Simulator
    Creator: Nexus-Lua for Master
    Version: 2.9 (Script Renamed)
]]

-- =================================================================================================
-- Services & Player Variables
-- =================================================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local leaderstats = Player:WaitForChild("leaderstats")
local Power = leaderstats:WaitForChild("Power")
local Wins = leaderstats:WaitForChild("Wins")

local RewardActionEvent = ReplicatedStorage.Events.RewardAction
local RewardActionFunc = ReplicatedStorage.Events.RewardActionFunction
local GetRandomPetEvent = ReplicatedStorage.Events.GetRandomPet

-- =================================================================================================
-- Helper Functions
-- =================================================================================================
local function FormatNumber(n)
    if not n then return "0" end
    local suffixes = {"", "K", "M", "B", "T", "Q", "Qa", "Qi", "Sx", "Sp", "Oc"}
    local i = 1
    while n >= 1000 and i < #suffixes do n = n / 1000; i = i + 1 end
    return string.format("%.2f%s", n, suffixes[i])
end

-- =================================================================================================
-- UI Library & Window Creation
-- =================================================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Paper Plane Simulator",
   Icon = "send", -- Paper plane icon
   LoadingTitle = "Paper Plane Simulator",
   LoadingSubtitle = "by Nexus-Lua",
   Theme = "Ocean",
   ToggleUIKeybind = Enum.KeyCode.K,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PaperPlaneSimulator", -- Updated folder name for saves
      FileName = "MobileConfig"
   }
})

-- =================================================================================================
-- Data Tables
-- =================================================================================================
local eggTypes = {"Basic", "Earth", "Snowman", "Cactus", "Beach", "Candy", "Farm", "Underwater", "Magma", "Magic", "Spooky", "Toxic", "Mine", "City", "Icy"}
local upgradeTypes = {"PlaneSize", "PlaneSpeed", "BalloonAmount", "BonusMultiplier"}
local zones = {
    Zone1 = {Name = "Zone1", Areas = {{Req = 3000, ID = 3}, {Req = 350, ID = 2}, {Req = 0, ID = 1}}}, Zone2 = {Name = "Zone2", Areas = {{Req = 55000, ID = 3}, {Req = 28000, ID = 2}, {Req = 0, ID = 1}}},
    Zone3 = {Name = "Zone3", Areas = {{Req = 850000, ID = 3}, {Req = 400000, ID = 2}, {Req = 0, ID = 1}}}, Zone4 = {Name = "Zone4", Areas = {{Req = 6.7e6, ID = 3}, {Req = 3.7e6, ID = 2}, {Req = 0, ID = 1}}},
    Zone5 = {Name = "Zone5", Areas = {{Req = 60e6, ID = 3}, {Req = 25e6, ID = 2}, {Req = 0, ID = 1}}}, Zone6 = {Name = "Zone6", Areas = {{Req = 1.5e9, ID = 3}, {Req = 300e6, ID = 2}, {Req = 0, ID = 1}}},
    Zone7 = {Name = "Zone7", Areas = {{Req = 9.2e9, ID = 3}, {Req = 2.5e9, ID = 2}, {Req = 0, ID = 1}}}, Zone8 = {Name = "Zone8", Areas = {{Req = 80e9, ID = 3}, {Req = 30e9, ID = 2}, {Req = 0, ID = 1}}},
    Zone9 = {Name = "Zone9", Areas = {{Req = 840e9, ID = 3}, {Req = 330e9, ID = 2}, {Req = 0, ID = 1}}}, Zone10 = {Name = "Zone10", Areas = {{Req = 25e12, ID = 3}, {Req = 7.5e12, ID = 2}, {Req = 0, ID = 1}}},
    Zone11 = {Name = "Zone11", Areas = {{Req = 165e12, ID = 3}, {Req = 45e12, ID = 2}, {Req = 0, ID = 1}}}, Zone12 = {Name = "Zone12", Areas = {{Req = 980e12, ID = 3}, {Req = 320e12, ID = 2}, {Req = 0, ID = 1}}},
    Zone13 = {Name = "Zone13", Areas = {{Req = 7.8e15, ID = 3}, {Req = 2.6e15, ID = 2}, {Req = 0, ID = 1}}}, Zone14 = {Name = "Zone14", Areas = {{Req = 21e15, ID = 3}, {Req = 21e15, ID = 2}, {Req = 0, ID = 1}}},
}
local zoneNames = table.create(#zones); for name, _ in pairs(zones) do table.insert(zoneNames, name) end; table.sort(zoneNames, function(a, b) return tonumber(a:sub(5)) < tonumber(b:sub(5)) end)

local teleportLocations = {
    ["Zone 1"] = CFrame.new(-74.0784912, 1.39115095, 367.908234, 0, 0, 1, 0, 1, -0, -1, 0, 0), ["Zone 2"] = CFrame.new(-71.5041199, 0.836532474, 200.685364, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 3"] = CFrame.new(-71.5419464, 0.837000012, 55.5375023, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 4"] = CFrame.new(-71.5874557, 0.837000012, -89.653717, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 5"] = CFrame.new(-71.6177216, 0.837000012, -234.8685, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 6"] = CFrame.new(-71.6211243, 0.837000012, -380.025146, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 7"] = CFrame.new(-71.6047745, 37.120739, -618.470764, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 8"] = CFrame.new(-71.6367264, 37.120739, -763.664917, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 9"] = CFrame.new(-71.6367264, 37.120739, -908.802612, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 10"] = CFrame.new(-71.6367264, 37.120739, -1053.98511, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 11"] = CFrame.new(-71.6367264, 37.120739, -1199.13086, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 12"] = CFrame.new(-71.6367264, 73.81707, -1438.76587, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469),
    ["Zone 13"] = CFrame.new(-71.6367264, 73.81707, -1583.94275, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469), ["Zone 14"] = CFrame.new(-71.6455765, 73.8165283, -1728.71899, 0.499959469, -0, -0.866048813, 0, 1, -0, 0.866048813, 0, 0.499959469)
}
local teleportLocationNames = {}; for name, _ in pairs(teleportLocations) do table.insert(teleportLocationNames, name) end; table.sort(teleportLocationNames, function(a,b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)

-- =================================================================================================
-- Tab: FARM
-- =================================================================================================
local FarmTab = Window:CreateTab("FARM", "tractor"); do
    FarmTab:CreateSection("Auto Train"); local isAutoTraining = false; local TrainZoneDropdown = FarmTab:CreateDropdown({Name = "Select Zone", Options = zoneNames, CurrentOption = {zoneNames[1]}, Flag = "AutoTrainZone", Callback = function(option) end}); FarmTab:CreateToggle({Name = "Enable Auto Train", CurrentValue = false, Flag = "AutoTrainToggle", Callback = function(Value) isAutoTraining = Value; if not Value then return end; task.spawn(function() while isAutoTraining do local selectedZoneName = TrainZoneDropdown.CurrentOption[1]; local zoneInfo = zones[selectedZoneName]; local currentPower = Power.Value; local targetAreaID = 1; for _, areaData in ipairs(zoneInfo.Areas) do if currentPower >= areaData.Req then targetAreaID = areaData.ID; break end end; RewardActionEvent:FireServer("Train", {[1] = targetAreaID, [2] = selectedZoneName}); task.wait(0.1) end end) end}); FarmTab:CreateDivider(); FarmTab:CreateSection("Auto Win"); local isAutoWinning = false; local WinZoneDropdown = FarmTab:CreateDropdown({Name = "Select Zone", Options = zoneNames, CurrentOption = {zoneNames[1]}, Flag = "AutoWinZone", Callback = function(option) end}); FarmTab:CreateToggle({Name = "Enable Auto Win", CurrentValue = false, Flag = "AutoWinToggle", Callback = function(Value) isAutoWinning = Value; if not Value then return end; task.spawn(function() while isAutoWinning do RewardActionEvent:FireServer("Win", {[1] = WinZoneDropdown.CurrentOption[1], [2] = {}, [3] = {1, 2, 3}, [4] = 0}); task.wait(0.1) end end) end})
end

-- =================================================================================================
-- Tab: PET
-- =================================================================================================
local PetTab = Window:CreateTab("PET", "paw-print"); do
    PetTab:CreateSection("Auto Hatch"); local isAutoHatching = false; local EggDropdown = PetTab:CreateDropdown({Name = "Select Egg", Options = eggTypes, CurrentOption = {"Basic"}, Flag = "AutoHatchEgg", Callback = function(option) end}); PetTab:CreateToggle({Name = "Enable Auto Hatch", CurrentValue = false, Flag = "AutoHatchToggle", Callback = function(Value) isAutoHatching = Value; if not Value then return end; task.spawn(function() while isAutoHatching do GetRandomPetEvent:InvokeServer(EggDropdown.CurrentOption[1], 1); task.wait(0.1) end end) end})
end

-- =================================================================================================
-- Tab: MAP
-- =================================================================================================
local MapTab = Window:CreateTab("MAP", "map-pin"); do
    MapTab:CreateSection("Teleport"); local TeleportDropdown = MapTab:CreateDropdown({Name = "Select Destination", Options = teleportLocationNames, CurrentOption = {teleportLocationNames[1]}, Flag = "TeleportLocation", Callback = function() end}); MapTab:CreateButton({Name = "Teleport", Callback = function() local destinationName = TeleportDropdown.CurrentOption[1]; local destinationCFrame = teleportLocations[destinationName]; local char = Player.Character; if char and char:FindFirstChild("HumanoidRootPart") and destinationCFrame then char.HumanoidRootPart.CFrame = destinationCFrame; Rayfield:Notify({Title = "Teleport", Content = "Teleported to " .. destinationName, Duration = 3, Image = "map-pin"}) else Rayfield:Notify({Title = "Teleport Error", Content = "Could not find character to teleport.", Duration = 4, Image = "alert-triangle"}) end end})
end

-- =================================================================================================
-- Tab: MISC
-- =================================================================================================
local MiscTab = Window:CreateTab("MISC", "settings-2"); do
    MiscTab:CreateSection("Auto Spin"); local isAutoSpinning = false; local SpinAmountInput = MiscTab:CreateInput({Name = "Number of Spins (0 for infinite)", CurrentValue = "0", PlaceholderText = "Enter number...", RemoveTextAfterFocusLost = false, Flag = "AutoSpinAmount"}); MiscTab:CreateToggle({Name = "Enable Auto Spin", CurrentValue = false, Flag = "AutoSpinToggle", Callback = function(Value) isAutoSpinning = Value; if not Value then return end; task.spawn(function() local maxSpins = tonumber(SpinAmountInput.CurrentValue) or 0; local spinCount = 0; while isAutoSpinning do if maxSpins > 0 and spinCount >= maxSpins then isAutoSpinning = false; SpinToggle:Set(false); break end; spinCount = spinCount + 1; RewardActionFunc:InvokeServer("Spin"); task.wait(3) end end) end}); MiscTab:CreateDivider(); MiscTab:CreateSection("Auto Rebirth"); local isAutoRebirthing = false; MiscTab:CreateToggle({Name = "Enable Auto Rebirth", CurrentValue = false, Flag = "AutoRebirthToggle", Callback = function(Value) isAutoRebirthing = Value; if not Value then return end; task.spawn(function() while isAutoRebirthing do RewardActionEvent:FireServer("Rebirth"); task.wait(3) end end) end}); MiscTab:CreateDivider(); MiscTab:CreateSection("Auto Upgrade"); local isAutoUpgrading = false; local UpgradeDropdown = MiscTab:CreateDropdown({Name = "Select Upgrades", Options = upgradeTypes, CurrentOption = {}, MultipleOptions = true, Flag = "AutoUpgradeSelection", Callback = function(options) end}); MiscTab:CreateToggle({Name = "Enable Auto Upgrade", CurrentValue = false, Flag = "AutoUpgradeToggle", Callback = function(Value) isAutoUpgrading = Value; if not Value then return end; task.spawn(function() while isAutoUpgrading do local selectedUpgrades = UpgradeDropdown.CurrentOption; if #selectedUpgrades > 0 then for _, upgradeName in ipairs(selectedUpgrades) do RewardActionEvent:FireServer("Upgrade", upgradeName); task.wait(0.1) end end; task.wait(1) end end) end})
end

-- =================================================================================================
-- Tab: PROFILE
-- =================================================================================================
local ProfileTab = Window:CreateTab("PROFILE", "user"); do
    ProfileTab:CreateSection("Player Stats"); local WinsLabel = ProfileTab:CreateButton({ Name = "Wins: " .. FormatNumber(Wins.Value), Callback = function() end }); local PowerLabel = ProfileTab:CreateButton({ Name = "Power: " .. FormatNumber(Power.Value), Callback = function() end }); task.spawn(function() while task.wait(0.5) do if Wins and Wins:IsA("IntValue") then WinsLabel:Set("Wins: " .. FormatNumber(Wins.Value)) end; if Power and Power:IsA("NumberValue") then PowerLabel:Set("Power: " .. FormatNumber(Power.Value)) end end end)
end

-- =================================================================================================
-- Finalization
-- =================================================================================================
Rayfield:LoadConfiguration()
Rayfield:Notify({
   Title = "Paper Plane Simulator",
   Content = "Script loaded successfully, Master.",
   Duration = 3,
   Image = "webhook"
})
