--[[
    Nexus-Lua Script (Version 3 - True Integration Core)
    Master's Request: Construct the final, intelligent script using a Knit Hunter and DataController integration.
    Functionality: All features are now fully autonomous, stable, and integrated with the game's core logic.
    Optimization: Dynamic Framework Finding, Data-Aware Logic, Crash Prevention.
]]

-- A more stable way to load the Rayfield library
local status, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not status or not Rayfield then warn("Nexus-Lua: CRITICAL ERROR - The Rayfield UI library failed to load.") return end

local success, gameName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
local windowTitle = success and gameName or "Game Hub"

local Window = Rayfield:CreateWindow({ Name = windowTitle, LoadingTitle = "Nexus-Lua Interface", LoadingSubtitle = "Loading Script...", ConfigurationSaving = { Enabled = true, FileName = windowTitle .. " Hub" }, KeySystem = false })

--===================================================================--
--                    TRUE INTEGRATION CORE                        --
--===================================================================--
local Knit, DataController, GameModules, GameFunctions
local ClickService, RebirthService, EggService, UpgradeService, FarmService

-- The "Knit Hunter" searches for the game's core framework.
local function FindKnitFramework()
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj.Name == "Knit" and obj:IsA("ModuleScript") then
            local success, requiredModule = pcall(require, obj)
            -- Verify it's the real Knit by checking for essential functions.
            if success and typeof(requiredModule) == "table" and requiredModule.GetService and requiredModule.GetController then
                return requiredModule
            end
        end
    end
    return nil
end

local success, err = pcall(function()
    Knit = FindKnitFramework()
    if not Knit then error("Knit framework not found.") end

    DataController = Knit:GetController("DataController")
    DataController:waitForData()

    ClickService = Knit:GetService("ClickService")
    RebirthService = Knit:GetService("RebirthService")
    EggService = Knit:GetService("EggService")
    UpgradeService = Knit:GetService("UpgradeService")
    FarmService = Knit:GetService("FarmService")
    
    GameModules = {
        Eggs = require(Knit.Parent.Shared.List.Pets.Eggs),
        Upgrades = require(Knit.Parent.Shared.List.Upgrades),
        Farms = require(Knit.Parent.Shared.List.Farms)
    }
    GameFunctions = {
        CanAffordRebirth = require(Knit.Parent.Shared.Functions.Special).CanAffordRebirth
    }
end)

if not success or not Knit or not DataController then
    Rayfield:Notify({Title="CRITICAL FAILURE", Content="Could not integrate with the game's core systems. The game has likely received a major structural update.", Duration=15})
    warn("Nexus-Lua Integration Failure:", err)
    return -- Stop the script
end

--===================================================================--
--                          SCRIPT FEATURES                          --
--===================================================================--
local ClicksTab, PetTab, UpgradesTab, MapTab, MiscTab, ProfileTab, SettingsTab = Window:CreateTab("Clicks","mouse-pointer-click"), Window:CreateTab("Pet","paw-print"), Window:CreateTab("Upgrades","arrow-up-circle"), Window:CreateTab("Map","map"), Window:CreateTab("Misc","package"), Window:CreateTab("Profile","user-circle"), Window:CreateTab("Settings","settings-2")

--============ CLICKS TAB ============--
ClicksTab:CreateSection("Farming")
_G.isAutoClicking = false
ClicksTab:CreateToggle({ Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle", Callback = function(v) _G.isAutoClicking = v; if not v then return end; task.spawn(function() while _G.isAutoClicking do ClickService.click:Fire(); task.wait(0.05) end end) end})

ClicksTab:CreateSection("Auto Rebirth")
local rebirthOpts={"1 Rebirth","5 Rebirths","10 Rebirths","25 Rebirths","50 Rebirths","100 Rebirths","200 Rebirths","500 Rebirths","1k Rebirths","2.5k Rebirths","Rebirth 11","Rebirth 12","Rebirth 13","Rebirth 14","Rebirth 15","Rebirth 16","Rebirth 17","Rebirth 18","Rebirth 19","Rebirth 20","Rebirth 21","Rebirth 22","Rebirth 23","Rebirth 24","Rebirth 25","Rebirth 26","Rebirth 27","Rebirth 28","Rebirth 29","Rebirth 30","Rebirth 31","Rebirth 32","Rebirth 33","Rebirth 34","Rebirth 35","Rebirth 36"}
local RebirthDropdown=ClicksTab:CreateDropdown({Name="Select Rebirth Tier",Options=rebirthOpts,CurrentOption={rebirthOpts[1]},MultipleOptions=false,Flag="RebirthTierDropdown"})
_G.isAutoRebirthing=false
ClicksTab:CreateToggle({Name="Auto Rebirth",CurrentValue=false,Flag="AutoRebirthToggle",Callback=function(v) _G.isAutoRebirthing=v; if not v then return end; task.spawn(function()
    while _G.isAutoRebirthing do local id=table.find(rebirthOpts,RebirthDropdown.CurrentOption[1]); if id and GameFunctions.CanAffordRebirth(id) then pcall(RebirthService.rebirth, RebirthService, id) end; task.wait(0.5) end
end) end})

--============ PET TAB ============--
PetTab:CreateSection("Auto Hatch")
local function getEggNames()local n={};local m=workspace.Game.Maps;for _,i in pairs(m:GetChildren())do if i:IsA("Folder")and i:FindFirstChild("Eggs")then for _,e in pairs(i.Eggs:GetChildren())do if e:IsA("Model")then table.insert(n,e.Name)end end end end;table.sort(n);return n end
local allEggNames=getEggNames();if #allEggNames==0 then table.insert(allEggNames,"No Eggs Found")end
local EggDropdown=PetTab:CreateDropdown({Name="Select Egg",Options=allEggNames,CurrentOption={allEggNames[1]},MultipleOptions=false,Flag="EggNameDropdown"})
_G.isAutoHatching=false;local AutoHatchStatusButton=PetTab:CreateButton({Name="Status: Idle",Callback=function()end})
PetTab:CreateToggle({Name="Auto Hatch Selected Egg (x3)",CurrentValue=false,Flag="AutoHatchToggle",Callback=function(v) _G.isAutoHatching=v; if not v then AutoHatchStatusButton:Set("Status: Idle"); return end; task.spawn(function()
    while _G.isAutoHatching do local sel=EggDropdown.CurrentOption[1];if sel and sel~="No Eggs Found" then local eggData=GameModules.Eggs[sel];if eggData and DataController.data.clicks >= (eggData.cost*3)then AutoHatchStatusButton:Set("Status: Hatching "..sel);pcall(EggService.openEgg.Fire,EggService.openEgg,sel,3)else AutoHatchStatusButton:Set("Status: Waiting for clicks...")end;task.wait(0.2)else break end end;AutoHatchStatusButton:Set("Status: Idle")
end) end})

--============ UPGRADES TAB ============--
UpgradesTab:CreateSection("Auto Purchase")
local function getUpgradeNames()local n={};local h=game:GetService("StarterGui"):WaitForChild("MainUI",5):WaitForChild("Menus",5):WaitForChild("UpgradesFrame",5):WaitForChild("Main",5):WaitForChild("List",5):WaitForChild("Holder",5):WaitForChild("Upgrades",5);if h then for _,i in pairs(h:GetChildren())do if i:IsA("Frame")then table.insert(n,i.Name)end end end;return n end
local allUpgradeNames=getUpgradeNames();if #allUpgradeNames==0 then table.insert(allUpgradeNames,"No Upgrades Found")end
local UpgradeDropdown=UpgradesTab:CreateDropdown({Name="Select Upgrades",Options=allUpgradeNames,MultipleOptions=true,Flag="UpgradeSelectionDropdown"})
_G.isAutoUpgrading=false;UpgradesTab:CreateToggle({Name="Auto Upgrade",Flag="AutoUpgradeToggle",Callback=function(v)_G.isAutoUpgrading=v;if v then task.spawn(function()while _G.isAutoUpgrading do for _,n in ipairs(Rayfield.Flags.UpgradeSelectionDropdown.CurrentOption)do local fmtName=string.lower(n:sub(1,1))..n:sub(2);local upData=GameModules.Upgrades[fmtName];local nextLvl=upData and upData.upgrades[(DataController.data.upgrades[fmtName]or 0)+1];if nextLvl and DataController.data.gems>=nextLvl.cost then pcall(UpgradeService.upgrade,UpgradeService,fmtName)end;task.wait(0.2);if not _G.isAutoUpgrading then break end end;task.wait(0.5)end end)end end})

UpgradesTab:CreateSection("Upgrade Farm")
local function getFarmNames()local n={"farmer"};local h=game:GetService("StarterGui"):WaitForChild("MainUI",5):WaitForChild("Menus",5):WaitForChild("FarmingMachineFrame",5):WaitForChild("Displays",5):WaitForChild("Main",5):WaitForChild("List",5):WaitForChild("Holder",5);if h then for _,i in pairs(h:GetChildren())do if i.Name~="UIListLayout"and i.Name~="YourFarmText"then table.insert(n,i.Name)end end end;table.sort(n);return n end
local allFarmNames=getFarmNames();UpgradesTab:CreateDropdown({Name="Select Farm Item(s)",Options=allFarmNames,MultipleOptions=true,Flag="FarmItemDropdown"})
_G.isAutoFarming=false;UpgradesTab:CreateToggle({Name="Auto Farm",Flag="AutoFarmToggle",Callback=function(v)_G.isAutoFarming=v;if v then task.spawn(function()while _G.isAutoFarming do for _,n in ipairs(Rayfield.Flags.FarmItemDropdown.CurrentOption)do local fmtName=string.lower(n:sub(1,1))..n:sub(2);local farmData=GameModules.Farms[fmtName];if farmData then local stageData=farmData.upgrades and farmData.upgrades[(DataController.data.farms[fmtName]and DataController.data.farms[fmtName].stage or 0)+1];if stageData and DataController.data.gems>=stageData.price then pcall(FarmService.upgrade,FarmService,fmtName)end end;task.wait(0.5);if not _G.isAutoFarming then break end end;task.wait(0.5)end end)end end})

--============ PROFILE, SETTINGS & LIVE DATA ============--
ProfileTab:CreateSection("Live Player Statistics")
local PlaytimeButton=ProfileTab:CreateButton({Name="Playtime: Loading...",Flag="PlaytimeStat",Callback=function()end})
local RebirthsButton=ProfileTab:CreateButton({Name="Rebirths: Loading...",Flag="RebirthsStat",Callback=function()end})
local ClicksButton=ProfileTab:CreateButton({Name="Clicks: Loading...",Flag="ClicksStat",Callback=function()end})
local EggsButton=ProfileTab:CreateButton({Name="Eggs: Loading...",Flag="EggsStat",Callback=function()end})
SettingsTab:CreateSection("Interface Control")
SettingsTab:CreateButton({Name="Destroy UI",Callback=function()Rayfield:Destroy()end})
SettingsTab:CreateButton({Name="Restart Script",Callback=function()Rayfield:Notify({Title="Restarting",Content="Script will restart in 3 seconds.",Duration=3,Image="loader"});Rayfield:Destroy();task.wait(3);pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))()end)end})

spawn(function()
    local leaderstats=Player:WaitForChild("leaderstats");local startTime=tick()
    while task.wait(1) do if not pcall(function()Rayfield:IsVisible()end)then break end;local elap=tick()-startTime;PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d",math.floor(elap/3600),math.floor((elap%3600)/60),math.floor(elap%60)));local r=leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths");RebirthsButton:Set(r and"Rebirths: "..tostring(r.Value)or"Rebirths: N/A");local c=leaderstats:FindFirstChild("\240\159\145\143 Clicks");ClicksButton:Set(c and"Clicks: "..tostring(c.Value)or"Clicks: N/A");local e=leaderstats:FindFirstChild("\240\159\165\154 Eggs");EggsButton:Set(e and"Eggs: "..tostring(e.Value)or"Eggs: N/A")end
end)
