--[[
    Nexus-Lua Script (Version 24)
    Master's Request: Implement an "Upgrade Farm" feature.
    Functionality: UI Base, Live Stats, UI Control, Auto Click, Auto Hatch, Auto Rebirth, Auto Upgrade, Upgrade Farm
    Optimization: Mobile/Touchscreen, Robust Loading, Dynamic Filtering
]]

-- A more stable way to load the Rayfield library
local status, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not status or not Rayfield then warn("Nexus-Lua: CRITICAL ERROR - The Rayfield UI library failed to load.") return end

-- Get the live name of the current game
local success, gameName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
local windowTitle = success and gameName or "Game Hub"

-- Create the main window
local Window = Rayfield:CreateWindow({ Name = windowTitle, LoadingTitle = "Nexus-Lua Interface", LoadingSubtitle = "Loading Script...", ConfigurationSaving = { Enabled = true, FileName = windowTitle .. " Hub" }, KeySystem = false, })

--============ TABS ============--
local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click")
local PetTab = Window:CreateTab("Pet", "paw-print")
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle")
local MapTab = Window:CreateTab("Map", "map")
local MiscTab = Window:CreateTab("Misc", "package")
local ProfileTab = Window:CreateTab("Profile", "user-circle")
local SettingsTab = Window:CreateTab("Settings", "settings-2")

--============ CLICKS TAB ============--
local ClicksSection = ClicksTab:CreateSection("Farming"); local CLICK_SERVICE_INDEX, CLICK_EVENT_INDEX = 19, 3
_G.isAutoClicking = false
ClicksTab:CreateToggle({ Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle", Callback = function(v) _G.isAutoClicking = v; if v then task.spawn(function() local s, r = pcall(function() return game:GetService("ReplicatedStorage").Packages.Knit.Services:GetChildren()[CLICK_SERVICE_INDEX].RE:GetChildren()[CLICK_EVENT_INDEX] end); if not s then Rayfield:Notify({Title="Error",Content="Auto Click remote needs updating.",Duration=7,Image="alert-triangle"}); _G.isAutoClicking=false;Rayfield.Flags.AutoClickToggle:Set(false) return end; while _G.isAutoClicking do r:FireServer({}); task.wait(0.05) end end) end end})
local RebirthSection = ClicksTab:CreateSection("Auto Rebirth"); local REBIRTH_SERVICE_INDEX = 6
local rebirthOpts = {"1 Rebirth","5 Rebirths","10 Rebirths","25 Rebirths","50 Rebirths","100 Rebirths","200 Rebirths","500 Rebirths","1k Rebirths","2.5k Rebirths","Rebirth 11","Rebirth 12","Rebirth 13","Rebirth 14","Rebirth 15","Rebirth 16","Rebirth 17","Rebirth 18","Rebirth 19","Rebirth 20","Rebirth 21","Rebirth 22","Rebirth 23","Rebirth 24","Rebirth 25","Rebirth 26","Rebirth 27","Rebirth 28","Rebirth 29","Rebirth 30","Rebirth 31","Rebirth 32","Rebirth 33","Rebirth 34","Rebirth 35","Rebirth 36"}
local RebirthDropdown = ClicksTab:CreateDropdown({Name="Select Rebirth Tier",Options=rebirthOpts,CurrentOption={rebirthOpts[1]},MultipleOptions=false,Flag="RebirthTierDropdown"})
_G.isAutoRebirthing = false
ClicksTab:CreateToggle({Name="Auto Rebirth",CurrentValue=false,Flag="AutoRebirthToggle",Callback=function(v) _G.isAutoRebirthing=v;if v then task.spawn(function() local s,rF=pcall(function()return game:GetService("ReplicatedStorage").Packages.Knit.Services:GetChildren()[REBIRTH_SERVICE_INDEX].RF["jag känner en bot, hon heter anna, anna heter hon"]end); if not s then Rayfield:Notify({Title="Error",Content="Rebirth remote needs updating.",Duration=7,Image="alert-triangle"});_G.isAutoRebirthing=false;Rayfield.Flags.AutoRebirthToggle:Set(false);return end; while _G.isAutoRebirthing do local id=table.find(rebirthOpts,RebirthDropdown.CurrentOption[1]);if id then pcall(rF.InvokeServer,rF,id);task.wait(0.5)end end end)end end})

--============ PET TAB ============--
local PetSection = PetTab:CreateSection("Auto Hatch"); local HATCH_SERVICE_INDEX, HATCH_EVENT_INDEX = 20, 3
local function getEggNames() local names={};local maps=workspace.Game.Maps;for _,map in pairs(maps:GetChildren())do if map:IsA("Folder")and map:FindFirstChild("Eggs")then for _,egg in pairs(map.Eggs:GetChildren())do if egg:IsA("Model")then table.insert(names,egg.Name)end end end end;table.sort(names);return names end
local allEggNames=getEggNames();if #allEggNames==0 then table.insert(allEggNames,"No Eggs Found")end
local EggDropdown=PetTab:CreateDropdown({Name="Select Egg",Options=allEggNames,CurrentOption={allEggNames[1]},MultipleOptions=false,Flag="EggNameDropdown"})
_G.isAutoHatching=false; local AutoHatchStatusButton=PetTab:CreateButton({Name="Status: Idle",Callback=function()end})
PetTab:CreateToggle({Name="Auto Hatch Selected Egg (x3)",CurrentValue=false,Flag="AutoHatchToggle",Callback=function(v) _G.isAutoHatching=v;if v then task.spawn(function()local s,hR=pcall(function()return game:GetService("ReplicatedStorage").Packages.Knit.Services:GetChildren()[HATCH_SERVICE_INDEX].RE:GetChildren()[HATCH_EVENT_INDEX]end);if not s then Rayfield:Notify({Title="Error",Content="Hatching remote needs updating.",Duration=7,Image="alert-circle"});_G.isAutoHatching=false;Rayfield.Flags.AutoHatchToggle:Set(false);return end;while _G.isAutoHatching do local sel=EggDropdown.CurrentOption[1];if sel and sel~="No Eggs Found"then AutoHatchStatusButton:Set("Status: Hatching "..sel);pcall(hR.FireServer,hR,sel,2);task.wait(0.05)else AutoHatchStatusButton:Set("Status: No egg selected");_G.isAutoHatching=false;Rayfield.Flags.AutoHatchToggle:Set(false);break end end;AutoHatchStatusButton:Set("Status: Idle")end)else AutoHatchStatusButton:Set("Status: Idle")end end})

--============ UPGRADES TAB ============--
local UpgradeSection=UpgradesTab:CreateSection("Auto Purchase"); local UPGRADE_SERVICE_INDEX = 15
local function getUpgradeNames()local names={};local holder=game:GetService("StarterGui"):WaitForChild("MainUI",5):WaitForChild("Menus",5):WaitForChild("UpgradesFrame",5):WaitForChild("Main",5):WaitForChild("List",5):WaitForChild("Holder",5):WaitForChild("Upgrades",5);if holder then for _,item in pairs(holder:GetChildren())do if item:IsA("Frame")then table.insert(names,item.Name)end end end;return names end
local allUpgradeNames=getUpgradeNames();if #allUpgradeNames==0 then table.insert(allUpgradeNames,"No Upgrades Found")end
local UpgradeDropdown=UpgradesTab:CreateDropdown({Name="Select Upgrades",Options=allUpgradeNames,MultipleOptions=true,Flag="UpgradeSelectionDropdown"})
_G.isAutoUpgrading=false
UpgradesTab:CreateToggle({Name="Auto Upgrade Selected",CurrentValue=false,Flag="AutoUpgradeToggle",Callback=function(v) _G.isAutoUpgrading=v;if v then task.spawn(function() local s,uRF=pcall(function()return game:GetService("ReplicatedStorage").Packages.Knit.Services:GetChildren()[UPGRADE_SERVICE_INDEX].RF["jag känner en bot, hon heter anna, anna heter hon"]end);if not s then Rayfield:Notify({Title="Error",Content="Upgrade remote needs updating.",Duration=7,Image="alert-triangle"});_G.isAutoUpgrading=false;Rayfield.Flags.AutoUpgradeToggle:Set(false);return end;while _G.isAutoUpgrading do if #UpgradeDropdown.CurrentOption>0 then for _,name in ipairs(UpgradeDropdown.CurrentOption)do local fmtName=string.lower(string.sub(name,1,1))..string.sub(name,2);pcall(uRF.InvokeServer,uRF,fmtName);task.wait(0.2);if not _G.isAutoUpgrading then break end end end;task.wait(0.5)end end)end end})

-- NEW: Upgrade Farm Section
local UpgradeFarmSection = UpgradesTab:CreateSection("Upgrade Farm"); local FARM_SERVICE_INDEX = 24; local FARM_RF_INDEX = 1
local function getFarmNames()
    local farmNames = {"farmer"} -- Manually add "farmer" as requested
    local holder = game:GetService("StarterGui"):WaitForChild("MainUI",5):WaitForChild("Menus",5):WaitForChild("FarmingMachineFrame",5):WaitForChild("Displays",5):WaitForChild("Main",5):WaitForChild("List",5):WaitForChild("Holder",5)
    if holder then
        for _, item in pairs(holder:GetChildren()) do
            if item.Name ~= "UIListLayout" and item.Name ~= "YourFarmText" then
                table.insert(farmNames, item.Name)
            end
        end
    end
    table.sort(farmNames); return farmNames
end
local allFarmNames = getFarmNames()
local FarmDropdown = UpgradesTab:CreateDropdown({ Name = "Select Farm Item", Options = allFarmNames, MultipleOptions = false, Flag = "FarmItemDropdown" })
_G.isAutoFarming = false
UpgradesTab:CreateToggle({ Name = "Auto Farm Selected", CurrentValue = false, Flag = "AutoFarmToggle", Callback = function(v)
    _G.isAutoFarming = v
    if v then task.spawn(function()
        local s, fRF = pcall(function() return game:GetService("ReplicatedStorage").Packages.Knit.Services:GetChildren()[FARM_SERVICE_INDEX].RF:GetChildren()[FARM_RF_INDEX] end)
        if not s or not fRF then Rayfield:Notify({Title="Error",Content="Farming remote needs updating.",Duration=7,Image="alert-triangle"});_G.isAutoFarming=false;Rayfield.Flags.AutoFarmToggle:Set(false);return end
        while _G.isAutoFarming do
            local farmName = FarmDropdown.CurrentOption[1]
            if farmName then
                local fmtFarmName = string.lower(string.sub(farmName,1,1))..string.sub(farmName,2)
                pcall(fRF.InvokeServer, fRF, fmtFarmName)
                task.wait(0.5) -- Safe delay
            end
        end
    end) end
end})

--============ PROFILE TAB & SETTINGS ============--
local ProfileSection = ProfileTab:CreateSection("Live Player Statistics")
local PlaytimeButton=ProfileTab:CreateButton({Name="Playtime: Loading...",Flag="PlaytimeStat",Callback=function()end})
local RebirthsButton=ProfileTab:CreateButton({Name="Rebirths: Loading...",Flag="RebirthsStat",Callback=function()end})
local ClicksButton=ProfileTab:CreateButton({Name="Clicks: Loading...",Flag="ClicksStat",Callback=function()end})
local EggsButton=ProfileTab:CreateButton({Name="Eggs: Loading...",Flag="EggsStat",Callback=function()end})
local SettingsSection = SettingsTab:CreateSection("Interface Control")
SettingsTab:CreateButton({Name="Destroy UI",Callback=function()Rayfield:Destroy()end})
SettingsTab:CreateButton({Name="Restart Script",Callback=function()Rayfield:Notify({Title="Restarting",Content="Script will restart in 3 seconds.",Duration=3,Image="loader"});Rayfield:Destroy();task.wait(3);pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))()end)end})

--============ LIVE DATA UPDATER ============--
spawn(function() local Player=game:GetService("Players").LocalPlayer;local leaderstats=Player:WaitForChild("leaderstats");local startTime=tick();while task.wait(1)do if not pcall(function()Rayfield:IsVisible()end)then break end;local elap=tick()-startTime;PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d",math.floor(elap/3600),math.floor((elap%3600)/60),math.floor(elap%60)));local r=leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths");RebirthsButton:Set(r and"Rebirths: "..tostring(r.Value)or"Rebirths: N/A");local c=leaderstats:FindFirstChild("\240\159\145\143 Clicks");ClicksButton:Set(c and"Clicks: "..tostring(c.Value)or"Clicks: N/A");local e=leaderstats:FindFirstChild("\240\159\165\154 Eggs");EggsButton:Set(e and"Eggs: "..tostring(e.Value)or"Eggs: N/A")end end)
