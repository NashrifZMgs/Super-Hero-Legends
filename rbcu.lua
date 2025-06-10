--[[
    Nexus-Lua Script (Version 17)
    Master's Request: Fix broken remotes for Auto Click and Auto Hatch.
    Functionality: UI Base, Live Stats, UI Control, Auto Click, Auto Hatch (Maintainable Paths)
    Optimization: Mobile/Touchscreen, Robust Loading, Easily-Updated Variables
]]

-- A more stable way to load the Rayfield library
local status, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not status or not Rayfield then
    warn("Nexus-Lua: CRITICAL ERROR - The Rayfield UI library failed to load.")
    return
end

-- Get the live name of the current game
local success, gameName = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)
local windowTitle = success and gameName or "Game Hub"

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = windowTitle,
   LoadingTitle = "Nexus-Lua Interface",
   LoadingSubtitle = "Loading Script...",
   ConfigurationSaving = { Enabled = true, FileName = windowTitle .. " Hub" },
   KeySystem = false,
})

--============ TABS ============--
local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click")
local PetTab = Window:CreateTab("Pet", "paw-print")
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle")
local MapTab = Window:CreateTab("Map", "map")
local MiscTab = Window:CreateTab("Misc", "package")
local ProfileTab = Window:CreateTab("Profile", "user-circle")
local SettingsTab = Window:CreateTab("Settings", "settings-2")


--============ CLICKS TAB ============--
local ClicksSection = ClicksTab:CreateSection("Farming")

--[[ MASTER, ATTENTION: Update these index numbers for Auto Click after a game update. ]]
local CLICK_SERVICE_INDEX = 19 -- [TODO: I NEED THE NEW INDEX FOR THE CLICKING SERVICE HERE]
local CLICK_EVENT_INDEX = 3   -- [TODO: I NEED THE NEW INDEX FOR THE CLICKING EVENT HERE]

_G.isAutoClicking = false
ClicksTab:CreateToggle({
   Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle",
   Callback = function(Value)
      _G.isAutoClicking = Value
      if Value then
         task.spawn(function()
            local s, r = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[CLICK_SERVICE_INDEX]:WaitForChild("RE"):GetChildren()[CLICK_EVENT_INDEX] end)
            if not s or not r then
                Rayfield:Notify({Title = "Error", Content = "Auto Click remote not found. Path needs updating.", Duration = 7, Image = "alert-triangle"})
                _G.isAutoClicking = false; Rayfield.Flags.AutoClickToggle:Set(false)
                return
            end
            while _G.isAutoClicking do r:FireServer({}); task.wait(0.05) end
         end)
      end
   end,
})


--============ PET TAB ============--
local PetSection = PetTab:CreateSection("Auto Hatch")

--[[ MASTER, ATTENTION: Update these index numbers for Auto Hatch after a game update. ]]
local HATCH_SERVICE_INDEX = 20 -- [TODO: I NEED THE NEW INDEX FOR THE HATCHING SERVICE HERE]
local HATCH_EVENT_INDEX = 3   -- [TODO: I NEED THE NEW INDEX FOR THE HATCHING EVENT HERE]

local function getEggNames()
    local eggNames = {}; local mapsFolder = workspace.Game.Maps
    for _, mapInstance in pairs(mapsFolder:GetChildren()) do
        if mapInstance:IsA("Folder") and mapInstance:FindFirstChild("Eggs") then
            for _, eggInstance in pairs(mapInstance.Eggs:GetChildren()) do
                if eggInstance:IsA("Model") then table.insert(eggNames, eggInstance.Name) end
            end
        end
    end
    table.sort(eggNames); return eggNames
end

local allEggNames = getEggNames()
if #allEggNames == 0 then table.insert(allEggNames, "No Eggs Found In Workspace") end

local EggDropdown = PetTab:CreateDropdown({ Name = "Select Egg", Options = allEggNames, CurrentOption = {allEggNames[1]}, MultipleOptions = false, Flag = "EggNameDropdown" })
_G.isAutoHatching = false
local AutoHatchStatusButton = PetTab:CreateButton({Name = "Status: Idle", Callback = function() end})

PetTab:CreateToggle({
   Name = "Auto Hatch Selected Egg", CurrentValue = false, Flag = "AutoHatchToggle",
   Callback = function(Value)
      _G.isAutoHatching = Value
      if Value then
         task.spawn(function()
            local s, hR = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[HATCH_SERVICE_INDEX]:WaitForChild("RE"):GetChildren()[HATCH_EVENT_INDEX] end)
            if not s or not hR then
                Rayfield:Notify({Title = "Error", Content = "Hatching remote not found. Path needs updating.", Duration = 7, Image = "alert-circle"})
                _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false)
                return
            end
            while _G.isAutoHatching do
                local selectedEggName = EggDropdown.CurrentOption[1]
                if selectedEggName and selectedEggName ~= "No Eggs Found In Workspace" then
                    AutoHatchStatusButton:Set("Status: Attempting: " .. selectedEggName)
                    local fireSuccess, fireError = pcall(function() hR:FireServer(selectedEggName, 1) end)
                    if not fireSuccess then
                        Rayfield:Notify({Title = "Hatch Error", Content = "Failed to fire remote: " .. tostring(fireError), Duration = 8, Image = "alert-octagon"})
                        _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false); break
                    end
                    task.wait(0.05)
                else
                    AutoHatchStatusButton:Set("Status: No valid egg selected")
                    _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false); break
                end
            end
            AutoHatchStatusButton:Set("Status: Idle")
         end)
      else AutoHatchStatusButton:Set("Status: Idle") end
   end,
})


--============ PROFILE TAB ============--
local ProfileSection = ProfileTab:CreateSection("Live Player Statistics")
local PlaytimeButton = ProfileTab:CreateButton({ Name = "Playtime: Loading...", Callback = function() end })
local RebirthsButton = ProfileTab:CreateButton({ Name = "Rebirths: Loading...", Callback = function() end })
local ClicksButton = ProfileTab:CreateButton({ Name = "Clicks: Loading...", Callback = function() end })
local EggsButton = ProfileTab:CreateButton({ Name = "Eggs: Loading...", Callback = function() end })


--============ SETTINGS TAB ============--
local SettingsSection = SettingsTab:CreateSection("Interface Control")
SettingsTab:CreateButton({ Name = "Destroy UI", Callback = function() Rayfield:Destroy() end })
SettingsTab:CreateButton({
    Name = "Restart Script",
    Callback = function()
        Rayfield:Notify({ Title = "Restarting", Content = "Script will restart in 3 seconds.", Duration = 3, Image = "loader" })
        Rayfield:Destroy(); task.wait(3)
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))() end)
    end
})

--============ LIVE DATA UPDATER ============--
spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local leaderstats = Player:WaitForChild("leaderstats")
    local startTime = tick()
    while task.wait(1) do
        if not pcall(function() Rayfield:IsVisible() end) then break end
        local elapsedTime = tick() - startTime
        PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d", math.floor(elapsedTime / 3600), math.floor((elapsedTime % 3600) / 60), math.floor(elapsedTime % 60)))
        local r = leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths"); RebirthsButton:Set(r and "Rebirths: "..tostring(r.Value) or "Rebirths: N/A")
        local c = leaderstats:FindFirstChild("\240\159\145\143 Clicks"); ClicksButton:Set(c and "Clicks: "..tostring(c.Value) or "Clicks: N/A")
        local e = leaderstats:FindFirstChild("\240\159\165\154 Eggs"); EggsButton:Set(e and "Eggs: "..tostring(e.Value) or "Eggs: N/A")
    end
end)
