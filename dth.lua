--[[
    Script: Dragon Training Hub UI
    Created by: Nexus-Lua for Master
    Function: Full-featured hub with complete data for all 5 worlds.
    Version: 7.6 (Complete World Data)
]]

-- Load the Rayfield User Interface Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Remote Events
local TreadmillRemote = ReplicatedStorage.Remotes.Server.Treadmill
local RebirthRemote = ReplicatedStorage.Remotes.Server.Rebirth
local HatchRemote = ReplicatedStorage.Remotes.Server.Hatch
local TeleportRemote = ReplicatedStorage.Remotes.Server.Teleport
local UpgradeRemote = ReplicatedStorage.Remotes.Server.Upgrade
local GiftRemote = ReplicatedStorage.Remotes.Server.Gift
local SpinRemote = ReplicatedStorage.Remotes.Server.Spin
local PotionRemote = ReplicatedStorage.Remotes.Server.Potion
local ToolRemote = ReplicatedStorage.Remotes.Server.Tool
local TrailRemote = ReplicatedStorage.Remotes.Server.Trail
local TimedPetRemote = ReplicatedStorage.Remotes.Server.TimedPet
local HatchEnchantRemote = ReplicatedStorage.Remotes.Server.HatchEnchant

-- ==============================================================================
--                            CONFIGURATION & DATA
-- ==============================================================================

local autoTrainEnabled, autoRebirthEnabled, autoHatchEnabled, autoUpgradeEnabled, autoGiftEnabled, autoSpinEnabled, autoPotionEnabled, autoBuyDragonEnabled, autoBuyTrailEnabled, autoHatchChestEnabled = false, false, false, false, false, false, false, false, false, false
local notificationsEnabled = true
local removeTreadmillsEnabled = false

local playerRebirths = 0
local selectedWorld = "Spawn World"
local selectedEgg = "Desert Egg (10)"
local selectedChest = "Chest I (12m)"
local selectedRebirthAmount = 1
local selectedRebirthTime = 10
local selectedUpgrades = {}
local selectedPotions = {}
local selectedTeleportLocation = "Spawn World"

-- Helper Functions
local function Notify(data) if notificationsEnabled then Rayfield:Notify(data) end end
local function ParseAbbreviatedNumber(str) if type(str) == "number" then return str end; if type(str) ~= "string" then return 0 end; local m, l, n = { k = 1e3, m = 1e6, b = 1e9, t = 1e12, qd = 1e15, qn = 1e18, se = 1e21, sp = 1e24, oc = 1e27, no = 1e30 }, string.sub(str, -2), tonumber(string.sub(str, 1, -3)); local m2, l2, n2 = { k = 1e3, m = 1e6, b = 1e9, t = 1e12 }, string.sub(str, -1), tonumber(string.sub(str, 1, -2)); if m[l] and n then return n*m[l] elseif m2[l2] and n2 then return n2*m2[l2] end; return tonumber(str) or 0 end
local function GetPriceFromString(str) local p = string.match(str, "%(([%d%.%a]+)%)"); if p then return ParseAbbreviatedNumber(p) end; return math.huge end

-- Data Tables
local Worlds = { ["Spawn World"] = 1, ["Ocean World"] = 2, ["Sakura World"] = 3, ["Lava World"] = 4, ["Glacier World"] = 5 }
local TeleportLocations = {
    ["Spawn World"] = CFrame.new(87.5667572, 97.2578049, -213.189499, 0.819155693, 0, 0.573571265, 0, 1, 0, -0.573571265, 0, 0.819155693),
    ["Ocean World"] = CFrame.new(921.766724, 97.2578049, -231.189514, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247),
    ["Lava World"] = CFrame.new(2890.36401, 97.2578049, -173.194839, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247),
    ["Sakura World"] = CFrame.new(1927.76001, 97.2578049, -236.700256, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247),
    ["Glacier World"] = CFrame.new(3892.66406, 97.2578049, -173.194839, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247)
}
local World1_Treadmills = {{ID=12,StrengthRequirement=35.5e9,RebirthRequirement=400e3},{ID=11,StrengthRequirement=8.1e9,RebirthRequirement=75e3},{ID=10,StrengthRequirement=1.35e9,RebirthRequirement=20e3},{ID=9,StrengthRequirement=355e6,RebirthRequirement=8e3},{ID=8,StrengthRequirement=45.5e6,RebirthRequirement=2.5e3},{ID=7,StrengthRequirement=6.6e6,RebirthRequirement=500},{ID=6,StrengthRequirement=910e3,RebirthRequirement=250},{ID=5,StrengthRequirement=86e3,RebirthRequirement=75},{ID=4,StrengthRequirement=11.2e3,RebirthRequirement=25},{ID=3,StrengthRequirement=2.1e3,RebirthRequirement=10},{ID=2,StrengthRequirement=350,RebirthRequirement=5},{ID=1,StrengthRequirement=0,RebirthRequirement=0}}
local World2_Treadmills = {{ID=24,StrengthRequirement=75e18,RebirthRequirement=10e9},{ID=23,StrengthRequirement=20e18,RebirthRequirement=45e9},{ID=22,StrengthRequirement=5e18,RebirthRequirement=10e9},{ID=21,StrengthRequirement=1e18,RebirthRequirement=4e9},{ID=20,StrengthRequirement=550e15,RebirthRequirement=1.2e9},{ID=19,StrengthRequirement=45e15,RebirthRequirement=500e6},{ID=18,StrengthRequirement=8e15,RebirthRequirement=250e6},{ID=17,StrengthRequirement=800e12,RebirthRequirement=100e6},{ID=16,StrengthRequirement=100e12,RebirthRequirement=35e6},{ID=15,StrengthRequirement=25e12,RebirthRequirement=15e6},{ID=14,StrengthRequirement=4e12,RebirthRequirement=3e6},{ID=13,StrengthRequirement=500e9,RebirthRequirement=800e3}}
local World3_Treadmills = {{ID=36,StrengthRequirement=180e24,RebirthRequirement=4e15},{ID=35,StrengthRequirement=60e24,RebirthRequirement=1e15},{ID=34,StrengthRequirement=15e24,RebirthRequirement=700e12},{ID=33,StrengthRequirement=4e24,RebirthRequirement=600e12},{ID=32,StrengthRequirement=1.2e24,RebirthRequirement=400e12},{ID=31,StrengthRequirement=600e21,RebirthRequirement=250e12},{ID=30,StrengthRequirement=200e21,RebirthRequirement=100e12},{ID=29,StrengthRequirement=80e21,RebirthRequirement=40e12},{ID=28,StrengthRequirement=15e21,RebirthRequirement=10e12},{ID=27,StrengthRequirement=7e21,RebirthRequirement=2.5e12},{ID=26,StrengthRequirement=2e21,RebirthRequirement=1e12},{ID=25,StrengthRequirement=600e18,RebirthRequirement=400e9}}
local World4_Treadmills = {{ID=42,StrengthRequirement=400e27,RebirthRequirement=250e15},{ID=41,StrengthRequirement=80e27,RebirthRequirement=100e15},{ID=40,StrengthRequirement=40e27,RebirthRequirement=40e15},{ID=39,StrengthRequirement=7e27,RebirthRequirement=20e15},{ID=38,StrengthRequirement=2e27,RebirthRequirement=12e15},{ID=37,StrengthRequirement=800e24,RebirthRequirement=8e15}}
local World5_Treadmills = {{ID=48,StrengthRequirement=500e30,RebirthRequirement=2e18},{ID=47,StrengthRequirement=100e30,RebirthRequirement=1.5e18},{ID=46,StrengthRequirement=25e30,RebirthRequirement=1.2e18},{ID=45,StrengthRequirement=7e30,RebirthRequirement=700e15},{ID=44,StrengthRequirement=2e30,RebirthRequirement=500e15},{ID=43,StrengthRequirement=800e27,RebirthRequirement=350e15}}
local Eggs = {["Desert Egg (10)"]=1,["Enchanted Egg (500)"]=2,["Wizard Egg (30k)"]=3,["Beach Egg (400k)"]=4,["Frozen Egg (2m)"]=5,["Heaven Egg (8m)"]=6,["Jungle Egg (15m)"]=7,["Alien Egg (25m)"]=8,["Saturn Egg (75m)"]=9,["Venus Egg (850m)"]=10,["Meme Egg (2b)"]=11,["Snack Egg (4.5b)"]=12,["Lava Egg (15b)"]=13,["Mecha Egg (150b)"]=14,["Snow Egg (500b)"]=15,["Glacier Egg (2.5t)"]=16}
local Chests = {["Chest I (12m)"]=1}
local TrailNames = {"Red","Yellow","Green","Blue","Purple","Midnight","Cash Money","Heaven","Crystal","Electro","Pink Flame","Multi","Enchanted","Glitched","Elemental","Frozen","Flaming","Holiday","Cartoony","Lazer","Time","Bee","Ethereal","Plasma","Red Giant","Earth","Firework","Hacker","Ocean","Toxic"}

local TreadmillModels = {["Spawn World"]={},["Ocean World"]={}}; local GlobalTreadmillModels, hiddenTreadmills, worldsScanned = {}, {}, {}
local function FindModelsForSpecificWorld(worldName) if worldsScanned[worldName] then return end; pcall(function() if worldName=="Spawn World" then local s=Workspace:FindFirstChild("PersistentWorld"); if s then for _,c in ipairs(s:GetChildren()) do if c:IsA("Model") then table.insert(TreadmillModels["Spawn World"],c) end end end elseif worldName=="Ocean World" then local o=Workspace:FindFirstChild("WorldMap"); if o then for _,c in ipairs(o:GetChildren()) do if c:IsA("Model") then table.insert(TreadmillModels["Ocean World"],c) end end end end end); worldsScanned[worldName]=true; Notify({Title="Scanner",Content="Treadmills for "..worldName.." have been indexed.",Duration=3,Image="search"}) end
local function FindInitialModels() pcall(function() local g={"TreadmillBase","TreadmillPrompts","VIPTreadmills"}; for _,n in ipairs(g) do local m=Workspace:FindFirstChild(n); if m then table.insert(GlobalTreadmillModels,m) end end; FindModelsForSpecificWorld("Spawn World") end) end
local function RestoreAllTreadmills() for _,d in ipairs(hiddenTreadmills) do if d.model and d.originalParent then pcall(function() d.model.Parent=d.originalParent end) end end; hiddenTreadmills={} end
local function HideTreadmillsForWorld(worldName) FindModelsForSpecificWorld(worldName); local t=TreadmillModels[worldName]; if t then for _,m in ipairs(t) do table.insert(hiddenTreadmills,{model=m,originalParent=m.Parent});m.Parent=nil end end; for _,m in ipairs(GlobalTreadmillModels) do table.insert(hiddenTreadmills,{model=m,originalParent=m.Parent});m.Parent=nil end end

-- ==============================================================================
--                                  UI CREATION
-- ==============================================================================
local Window = Rayfield:CreateWindow({ Name = "Dragon Training", Icon = "flame", LoadingTitle = "Dragon Training Hub", LoadingSubtitle = "Loading interface...", Theme = "AmberGlow", ConfigurationSaving = { Enabled = true, FolderName = "DragonTraining", FileName = "DragonTrainingConfig" }, ToggleUIKeybind = Enum.KeyCode.RightControl })
local FarmTab, PetTab, MapTab, ShopTab, MiscTab, ProfileTab, SettingTab = Window:CreateTab("Farm", "sword"), Window:CreateTab("Pet", "paw-print"), Window:CreateTab("Map", "map"), Window:CreateTab("Shop", "shopping-cart"), Window:CreateTab("Misc", "sliders-horizontal"), Window:CreateTab("Profile", "user"), Window:CreateTab("Setting", "settings")

-- ==============================================================================
--                                 FARM TAB
-- ==============================================================================
local autoTrainThread
FarmTab:CreateSection("Auto Train Dragon")
FarmTab:CreateDropdown({ Name = "Select World", Options = {"Spawn World", "Ocean World", "Sakura World", "Lava World", "Glacier World"}, CurrentOption = {"Spawn World"}, Flag = "SelectedWorld", Callback = function(Option) selectedWorld=Option[1]; if removeTreadmillsEnabled then RestoreAllTreadmills(); HideTreadmillsForWorld(selectedWorld) end end })
FarmTab:CreateToggle({Name = "Enable Auto Train", CurrentValue = false, Flag = "AutoTrainToggle", Callback = function(Value)
    autoTrainEnabled = Value
    if autoTrainEnabled then
        if autoTrainThread then task.cancel(autoTrainThread) end
        autoTrainThread = task.spawn(function()
            local currentTreadmillID = -1
            Notify({Title="Auto Train",Content="Teleporting to "..selectedWorld,Duration=3,Image="map"})
            if Worlds[selectedWorld] then TeleportRemote:InvokeServer(Worlds[selectedWorld]) end; task.wait(2)
            while autoTrainEnabled do
                local strengthStat = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Strength
                if strengthStat then
                    local playerStrength, bestTreadmill = ParseAbbreviatedNumber(strengthStat.Value), 1
                    local treadmillList; if selectedWorld=="Ocean World" then treadmillList=World2_Treadmills elseif selectedWorld=="Sakura World" then treadmillList=World3_Treadmills elseif selectedWorld=="Lava World" then treadmillList=World4_Treadmills elseif selectedWorld=="Glacier World" then treadmillList=World5_Treadmills else treadmillList=World1_Treadmills end
                    for _,td in ipairs(treadmillList) do if playerRebirths>=td.RebirthRequirement or playerStrength>=td.StrengthRequirement then bestTreadmill=td.ID; break end end
                    if bestTreadmill~=currentTreadmillID then Notify({Title="Auto Train",Content="Switching to Treadmill #"..bestTreadmill,Duration=3,Image="trending-up"}); TreadmillRemote:FireServer(0); local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then task.wait(0.2);h.Jump=true;task.wait(0.5);h.Jump=true;task.wait(0.2) else task.wait(0.9) end end
                    TreadmillRemote:FireServer(bestTreadmill); currentTreadmillID=bestTreadmill
                end
                task.wait(2.5)
            end
        end)
    else
        if autoTrainThread then task.cancel(autoTrainThread) end; TreadmillRemote:FireServer(0)
    end
end})
FarmTab:CreateToggle({Name = "Remove Treadmill", CurrentValue = false, Flag = "RemoveTreadmillToggle", Callback = function(Value) removeTreadmillsEnabled=Value; RestoreAllTreadmills(); if removeTreadmillsEnabled then HideTreadmillsForWorld(selectedWorld) end end})
-- ==============================================================================
--                                  PET TAB
-- ==============================================================================
PetTab:CreateSection("Auto Hatch Eggs")
PetTab:CreateDropdown({Name="Select Egg",Options={"Desert Egg (10)","Enchanted Egg (500)","Wizard Egg (30k)","Beach Egg (400k)","Frozen Egg (2m)","Heaven Egg (8m)","Jungle Egg (15m)","Alien Egg (25m)","Saturn Egg (75m)","Venus Egg (850m)","Meme Egg (2b)","Snack Egg (4.5b)","Lava Egg (15b)","Mecha Egg (150b)","Snow Egg (500b)","Glacier Egg (2.5t)"},CurrentOption={"Desert Egg (10)"},Flag="SelectedEgg",Callback=function(O) selectedEgg=O[1] end})
PetTab:CreateToggle({Name = "Enable Auto Hatch", CurrentValue = false, Flag = "AutoHatchToggle", Callback = function(Value) autoHatchEnabled = Value; if not autoHatchEnabled then return end; spawn(function() while autoHatchEnabled do local p, c, i = ParseAbbreviatedNumber(LocalPlayer.leaderstats.Wins.Value), GetPriceFromString(selectedEgg), Eggs[selectedEgg]; if i and p >= c then HatchRemote:InvokeServer(i, 1) end; task.wait(0.2) end end) end})
-- ==============================================================================
--                                   MAP TAB
-- ==============================================================================
MapTab:CreateSection("Teleport")
MapTab:CreateDropdown({Name = "Select Location", Options = {"Spawn World", "Ocean World", "Sakura World", "Lava World", "Glacier World"}, CurrentOption = {"Spawn World"}, Flag = "TeleportLocation", Callback = function(Option) selectedTeleportLocation = Option[1] end})
MapTab:CreateButton({Name = "Teleport", Callback = function() local t=TeleportLocations[selectedTeleportLocation]; if t and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame=t; Notify({Title="Teleport",Content="Teleported to "..selectedTeleportLocation,Duration=4,Image="map-pin"}) end end})
-- ==============================================================================
--                                  SHOP TAB
-- ==============================================================================
ShopTab:CreateSection("Auto Upgrade")
ShopTab:CreateDropdown({Name = "Select Upgrades", Options = {"SpeedUpgrade","StrengthUpgrade","WinsUpgrade","RebirthUpgrade","LuckUpgrade"}, MultipleOptions = true, Flag = "SelectedUpgrades", Callback = function(Options) selectedUpgrades = Options end})
ShopTab:CreateToggle({Name = "Enable Auto Upgrade", CurrentValue = false, Flag = "AutoUpgradeToggle", Callback = function(Value) autoUpgradeEnabled = Value; if not autoUpgradeEnabled then return end; spawn(function() while autoUpgradeEnabled do for _, upg in ipairs(selectedUpgrades) do if not autoUpgradeEnabled then break end; UpgradeRemote:FireServer(upg); task.wait(0.2) end; task.wait(5) end end) end})
ShopTab:CreateSection("Auto Buy")
ShopTab:CreateToggle({Name = "Auto Buy Dragons", CurrentValue = false, Flag = "AutoBuyDragonToggle", Callback = function(Value) autoBuyDragonEnabled = Value; if not autoBuyDragonEnabled then return end; spawn(function() while autoBuyDragonEnabled do for i = 1, 12 do if not autoBuyDragonEnabled then break end; ToolRemote:FireServer(i); task.wait(0.2) end; task.wait(10) end end) end})
ShopTab:CreateToggle({Name = "Auto Buy Trails", CurrentValue = false, Flag = "AutoBuyTrailToggle", Callback = function(Value) autoBuyTrailEnabled = Value; if not autoBuyTrailEnabled then return end; spawn(function() while autoBuyTrailEnabled do for _, name in ipairs(TrailNames) do if not autoBuyTrailEnabled then break end; TrailRemote:FireServer(name); task.wait(0.2) end; task.wait(10) end end) end})
ShopTab:CreateSection("Auto Hatch Chest")
ShopTab:CreateDropdown({Name = "Select Chest", Options = {"Chest I (12m)"}, CurrentOption = {"Chest I (12m)"}, Flag = "SelectedChest", Callback = function(Option) selectedChest = Option[1] end})
ShopTab:CreateToggle({Name = "Enable Auto Hatch Chest", CurrentValue = false, Flag = "AutoHatchChestToggle", Callback = function(Value) autoHatchChestEnabled = Value; if not autoHatchChestEnabled then return end; spawn(function() while autoHatchChestEnabled do local p,c,i = ParseAbbreviatedNumber(LocalPlayer.leaderstats.Wins.Value), GetPriceFromString(selectedChest), Chests[selectedChest]; if i and p >= c then HatchEnchantRemote:InvokeServer(i, 1) end; task.wait(0.2) end end) end})
-- ==============================================================================
--                                  MISC TAB
-- ==============================================================================
MiscTab:CreateSection("Auto Rebirth")
MiscTab:CreateDropdown({Name = "Rebirth Amount", Options = {1, 5, 15, 100, 250, 1000, 2500, 5000}, CurrentOption = {1}, Flag = "SelectedRebirthAmount", Callback = function(Option) selectedRebirthAmount = Option[1] end})
MiscTab:CreateDropdown({Name = "Rebirth Timer (Seconds)", Options = {1, 5, 10, 20}, CurrentOption = {10}, Flag = "SelectedRebirthTime", Callback = function(Option) selectedRebirthTime = Option[1] end})
MiscTab:CreateToggle({Name = "Enable Auto Rebirth", CurrentValue = false, Flag = "AutoRebirthToggle", Callback = function(Value) autoRebirthEnabled = Value; if not autoRebirthEnabled then return end; spawn(function() while autoRebirthEnabled do RebirthRemote:FireServer(selectedRebirthAmount); task.wait(selectedRebirthTime) end end) end})
MiscTab:CreateSection("Automation")
MiscTab:CreateToggle({Name = "Auto Claim Gifts", CurrentValue = false, Flag = "AutoGiftToggle", Callback = function(Value) autoGiftEnabled = Value; if not autoGiftEnabled then return end; spawn(function() while autoGiftEnabled do for i=1,12 do if not autoGiftEnabled then break end; GiftRemote:FireServer(i); task.wait(0.5) end; Notify({Title="Gifts",Content="Waiting 15 minutes.", Duration=5, Image="gift"}); task.wait(900) end end) end})
MiscTab:CreateToggle({Name = "Auto Spin Wheel", CurrentValue = false, Flag = "AutoSpinToggle", Callback = function(Value) autoSpinEnabled = Value; if not autoSpinEnabled then return end; spawn(function() while autoSpinEnabled do SpinRemote:InvokeServer(false); task.wait(5) end end) end})
MiscTab:CreateSection("Auto Use Potions")
MiscTab:CreateDropdown({Name = "Select Potions", Options = {"Lucky","Win","Speed","Train"}, MultipleOptions = true, Flag = "SelectedPotions", Callback = function(Options) selectedPotions = Options end})
MiscTab:CreateToggle({Name = "Enable Auto Use Potions", CurrentValue = false, Flag = "AutoPotionToggle", Callback = function(Value) autoPotionEnabled = Value; if not autoPotionEnabled then return end; spawn(function() while autoPotionEnabled do for _, name in ipairs(selectedPotions) do PotionRemote:FireServer(name) end; task.wait(30) end end) end})
-- ==============================================================================
--                                 PROFILE TAB
-- ==============================================================================
ProfileTab:CreateSection("Live Player Stats")
local StrengthLabel, WinsLabel, RebirthsLabel = ProfileTab:CreateButton({Name="Strength: Loading..",Callback=function()end}), ProfileTab:CreateButton({Name="Wins: Loading..",Callback=function()end}), ProfileTab:CreateButton({Name="Rebirths: Loading..",Callback=function()end})
local function setupLeaderstatWatcher(statName, label) local l=LocalPlayer:WaitForChild("leaderstats",15);if not l then label:Set(statName..": Not Found");return end;local s=l:WaitForChild(statName,10);if s then label:Set(statName..": "..s.Value);s.Changed:Connect(function(v)label:Set(statName..": "..v)end)else label:Set(statName..": Not Found")end end
local function setupRebirthWatcher() local p=ReplicatedStorage:WaitForChild("PlayerData",15);if not p then RebirthsLabel:Set("Rebirths: Not Found");return end;local f=p:WaitForChild(LocalPlayer.Name,10);if not f then RebirthsLabel:Set("Rebirths: Not Found");return end;local r=f:WaitForChild("Rebirths",10);if r then playerRebirths=r.Value;RebirthsLabel:Set("Rebirths: "..r.Value);r.Changed:Connect(function(v)playerRebirths=v;RebirthsLabel:Set("Rebirths: "..v)end)else RebirthsLabel:Set("Rebirths: Not Found")end end
spawn(function()setupLeaderstatWatcher("Strength",StrengthLabel)end)
spawn(function()setupLeaderstatWatcher("Wins",WinsLabel)end)
spawn(function()setupRebirthWatcher()end)
-- ==============================================================================
--                                 SETTING TAB
-- ==============================================================================
SettingTab:CreateSection("General")
SettingTab:CreateToggle({Name="Enable Notifications",CurrentValue=true,Flag="EnableNotifications",Callback=function(v)notificationsEnabled=v end})
SettingTab:CreateSection("Danger Zone")
local destroyConfirmationState = false
local destroyButton = SettingTab:CreateButton({Name = "Destroy UI", Callback = function() if not destroyConfirmationState then destroyConfirmationState = true; destroyButton:Set("Are you sure? Click to confirm."); task.delay(5, function() if destroyConfirmationState then destroyConfirmationState = false; destroyButton:Set("Destroy UI") end end) else Rayfield:Destroy() end end})
-- ==============================================================================
--                                 FINALIZATION
-- ==============================================================================
spawn(function()pcall(function() local function SafeDestroy(i) if i then pcall(function() i:Destroy() end) end; pcall(function() SafeDestroy(game:GetService("CoreGui"):WaitForChild("RobloxGui",5):WaitForChild("Modules",5):WaitForChild("Ad",5)) end); local b=ReplicatedStorage:WaitForChild("BloxbizRemotes",5); if b then b:Destroy() end; Notify({Title="Ad Blocker",Content="Advertising components neutralized.",Duration=5,Image="shield-off"}) end)end)
FindInitialModels()
spawn(function()Notify({Title="Timed Pet",Content="The timed pet will be claimed in 19 minutes.",Duration=8,Image="clock"});task.wait(1140);TimedPetRemote:FireServer();Notify({Title="Timed Pet",Content="Claiming timed pet now!",Duration=5,Image="gift"})end)
Rayfield:LoadConfiguration()
