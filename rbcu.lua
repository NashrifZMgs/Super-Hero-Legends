--[[
    Nexus-Lua Script (Version 37 - Hunter Fixed)
    Master's Request: Fix the "Modal is not a valid member" error.
    Functionality: All features stable, with a corrected and functional input-blocking overlay.
    Optimization: Autonomous remote finding, failsafe input blocking, correct UI implementation.
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
--                       AUTONOMOUS FINDER MODULE                    --
--===================================================================--
_G.FoundRemotes = {}

local Finder = {}
local Player = game:GetService("Players").LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")

-- This is the failsafe overlay that blocks all user input during a scan.
local InputBlocker = Instance.new("ScreenGui", game.CoreGui)
InputBlocker.Name = "InputBlocker_NexusLua"
InputBlocker.Enabled = false
InputBlocker.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- FIX: Changed from a Frame to a TextButton, which supports the Modal property.
local BlockerButton = Instance.new("TextButton", InputBlocker)
BlockerButton.Size = UDim2.new(1, 0, 1, 0)
BlockerButton.Position = UDim2.new(0, 0, 0, 0)
BlockerButton.BackgroundColor3 = Color3.new(0, 0, 0)
BlockerButton.BackgroundTransparency = 0.5
BlockerButton.Modal = true -- This now works correctly.
BlockerButton.Text = "" -- Ensure no text is visible on the button.
BlockerButton.ZIndex = 999

local StatusLabel = Instance.new("TextLabel", BlockerButton)
StatusLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
StatusLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextScaled = true
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 1000

function Finder:ShowMessage(message) StatusLabel.Text = message; InputBlocker.Enabled = true end
function Finder:Hide() InputBlocker.Enabled = false end

function Finder:ScanAndStore(profile)
    if _G.FoundRemotes[profile.CacheKey] then profile.Callback(_G.FoundRemotes[profile.CacheKey]); return end
    self:ShowMessage("SCANNING: Acquiring " .. profile.Name .. " Remote...\nPlease wait and do not interact.")
    task.wait()
    local success, Services = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10) end)
    if not success or not Services then self:ShowMessage("FAILURE: Could not find Services folder."); task.wait(3); self:Hide(); return end
    
    local statObject = leaderstats:WaitForChild(profile.StatName); local baseline = statObject.Value
    local foundRemote = nil

    for _, service in ipairs(Services:GetChildren()) do
        local remoteFolder = service:FindFirstChild(profile.RemoteType)
        if remoteFolder then for _, remote in ipairs(remoteFolder:GetChildren()) do
            if profile.KnownName and remote.Name ~= profile.KnownName then continue end
            pcall(remote[profile.FireMethod], remote, unpack(profile.TestArgs))
            task.wait(0.2)
            if statObject.Value > baseline then foundRemote = remote; break else baseline = statObject.Value end
        end end
        if foundRemote then break end
    end

    if foundRemote then
        _G.FoundRemotes[profile.CacheKey] = foundRemote
        self:ShowMessage("SUCCESS: " .. profile.Name .. " Remote Found! Resuming...")
        task.wait(1.5); self:Hide()
        profile.Callback(foundRemote)
    else
        self:ShowMessage("FAILURE: Could not identify " .. profile.Name .. " Remote."); task.wait(3); self:Hide()
        local flag = Rayfield.Flags[profile.Flag]; if flag then flag:Set(false) end
    end
end

--===================================================================--
--                          SCRIPT FEATURES                          --
--===================================================================--
local ClicksTab, PetTab, UpgradesTab, MapTab, MiscTab, ProfileTab, SettingsTab = Window:CreateTab("Clicks","mouse-pointer-click"), Window:CreateTab("Pet","paw-print"), Window:CreateTab("Upgrades","arrow-up-circle"), Window:CreateTab("Map","map"), Window:CreateTab("Misc","package"), Window:CreateTab("Profile","user-circle"), Window:CreateTab("Settings","settings-2")

--============ CLICKS TAB ============--
ClicksTab:CreateSection("Farming")
_G.isAutoClicking = false
ClicksTab:CreateToggle({ Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle", Callback = function(v)
    _G.isAutoClicking = v; if not v then return end
    Finder:ScanAndStore({ Name = "Auto Click", CacheKey = "ClickRemote", Flag = "AutoClickToggle", StatName = "\240\159\145\143 Clicks", RemoteType = "RE", FireMethod = "FireServer", TestArgs = {{}},
        Callback = function(remote) while _G.isAutoClicking do remote:FireServer({}); task.wait(0.05) end end
    })
end})

ClicksTab:CreateSection("Auto Rebirth")
local rebirthOpts={"1 Rebirth","5 Rebirths","10 Rebirths","25 Rebirths","50 Rebirths","100 Rebirths","200 Rebirths","500 Rebirths","1k Rebirths","2.5k Rebirths","Rebirth 11","Rebirth 12","Rebirth 13","Rebirth 14","Rebirth 15","Rebirth 16","Rebirth 17","Rebirth 18","Rebirth 19","Rebirth 20","Rebirth 21","Rebirth 22","Rebirth 23","Rebirth 24","Rebirth 25","Rebirth 26","Rebirth 27","Rebirth 28","Rebirth 29","Rebirth 30","Rebirth 31","Rebirth 32","Rebirth 33","Rebirth 34","Rebirth 35","Rebirth 36"}
local RebirthDropdown=ClicksTab:CreateDropdown({Name="Select Rebirth Tier",Options=rebirthOpts,CurrentOption={rebirthOpts[1]},MultipleOptions=false,Flag="RebirthTierDropdown"})
_G.isAutoRebirthing=false
ClicksTab:CreateToggle({Name="Auto Rebirth",CurrentValue=false,Flag="AutoRebirthToggle",Callback=function(v)
    _G.isAutoRebirthing=v; if not v then return end
    Finder:ScanAndStore({ Name = "Auto Rebirth", CacheKey = "RebirthRemote", Flag = "AutoRebirthToggle", StatName = "\226\153\187\239\184\143 Rebirths", RemoteType = "RF", FireMethod = "InvokeServer", KnownName = "jag känner en bot, hon heter anna, anna heter hon", TestArgs = {1},
        Callback = function(remote) while _G.isAutoRebirthing do local id=table.find(rebirthOpts,RebirthDropdown.CurrentOption[1]);if id then pcall(remote.InvokeServer,remote,id)task.wait(0.5)end end end
    })
end})

--============ PET TAB ============--
PetTab:CreateSection("Auto Hatch")
local function getEggNames()local n={};local m=workspace.Game.Maps;for _,i in pairs(m:GetChildren())do if i:IsA("Folder")and i:FindFirstChild("Eggs")then for _,e in pairs(i.Eggs:GetChildren())do if e:IsA("Model")then table.insert(n,e.Name)end end end end;table.sort(n);return n end
local allEggNames=getEggNames();if #allEggNames==0 then table.insert(allEggNames,"No Eggs Found")end
local EggDropdown=PetTab:CreateDropdown({Name="Select Egg",Options=allEggNames,CurrentOption={allEggNames[1]},MultipleOptions=false,Flag="EggNameDropdown"})
_G.isAutoHatching=false;local AutoHatchStatusButton=PetTab:CreateButton({Name="Status: Idle",Callback=function()end})
PetTab:CreateToggle({Name="Auto Hatch Selected Egg (x3)",CurrentValue=false,Flag="AutoHatchToggle",Callback=function(v)
    _G.isAutoHatching=v; if not v then AutoHatchStatusButton:Set("Status: Idle"); return end
    Finder:ScanAndStore({ Name = "Auto Hatch", CacheKey = "HatchRemote", Flag = "AutoHatchToggle", StatName = "\240\159\165\154 Eggs", RemoteType = "RE", FireMethod = "FireServer", TestArgs = {"Basic", 1},
        Callback = function(remote) while _G.isAutoHatching do local sel=EggDropdown.CurrentOption[1];if sel and sel~="No Eggs Found"then AutoHatchStatusButton:Set("Status: Hatching "..sel);pcall(remote.FireServer,remote,sel,2)task.wait(0.05)else AutoHatchStatusButton:Set("Status: No egg selected");_G.isAutoHatching=false;Rayfield.Flags.AutoHatchToggle:Set(false);break end end;AutoHatchStatusButton:Set("Status: Idle") end
    })
end})

--============ UPGRADES TAB, PROFILE & SETTINGS ============--
-- This section was left minimal as per the last request to focus on the Hunter module
UpgradesTab:CreateSection("Auto Purchase")
local function getUpgradeNames()local n={};local h=game:GetService("StarterGui"):WaitForChild("MainUI",5):WaitForChild("Menus",5):WaitForChild("UpgradesFrame",5):WaitForChild("Main",5):WaitForChild("List",5):WaitForChild("Holder",5):WaitForChild("Upgrades",5);if h then for _,i in pairs(h:GetChildren())do if i:IsA("Frame")then table.insert(n,i.Name)end end end;return n end
local allUpgradeNames=getUpgradeNames();if #allUpgradeNames==0 then table.insert(allUpgradeNames,"No Upgrades Found")end
UpgradesTab:CreateDropdown({Name="Select Upgrades",Options=allUpgradeNames,MultipleOptions=true,Flag="UpgradeSelectionDropdown"})

ProfileTab:CreateSection("Live Player Statistics")
local PlaytimeButton=ProfileTab:CreateButton({Name="Playtime: Loading...",Flag="PlaytimeStat",Callback=function()end})
local RebirthsButton=ProfileTab:CreateButton({Name="Rebirths: Loading...",Flag="RebirthsStat",Callback=function()end})
local ClicksButton=ProfileTab:CreateButton({Name="Clicks: Loading...",Flag="ClicksStat",Callback=function()end})
local EggsButton=ProfileTab:CreateButton({Name="Eggs: Loading...",Flag="EggsStat",Callback=function()end})
SettingsTab:CreateSection("Interface Control")
SettingsTab:CreateButton({Name="Destroy UI",Callback=function()Rayfield:Destroy()end})
SettingsTab:CreateButton({Name="Restart Script",Callback=function()Rayfield:Notify({Title="Restarting",Content="Script will restart in 3 seconds.",Duration=3,Image="loader"});Rayfield:Destroy();task.wait(3);pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))()end)end})

--============ LIVE DATA UPDATER ============--
spawn(function()
    local startTime=tick()
    while task.wait(1) do
        if not pcall(function() Rayfield:IsVisible() end) then break end
        local elap=tick()-startTime;PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d",math.floor(elap/3600),math.floor((elap%3600)/60),math.floor(elap%60)))
        local r=leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths");RebirthsButton:Set(r and"Rebirths: "..tostring(r.Value)or"Rebirths: N/A")
        local c=leaderstats:FindFirstChild("\240\159\145\143 Clicks");ClicksButton:Set(c and"Clicks: "..tostring(c.Value)or"Clicks: N/A")
        local e=leaderstats:FindFirstChild("\240\159\165\154 Eggs");EggsButton:Set(e and"Eggs: "..tostring(e.Value)or"Eggs: N/A")
    end
end)
