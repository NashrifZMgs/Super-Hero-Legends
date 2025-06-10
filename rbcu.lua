--[[
    Nexus-Lua Script (Version 19)
    Master's Request: Fix script-breaking "Line 1" error.
    Functionality: UI Base, Live Stats (Fixed), UI Control, Auto Click, Auto Hatch, Auto Rebirth
    Optimization: Mobile/Touchscreen, Robust Loading, Stable Logic
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

-- Restored last known working values.
local CLICK_SERVICE_INDEX = 19
local CLICK_EVENT_INDEX = 3

_G.isAutoClicking = false
ClicksTab:CreateToggle({
   Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle",
   Callback = function(Value)
      _G.isAutoClicking = Value
      if Value then
         task.spawn(function()
            local s, r = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[CLICK_SERVICE_INDEX]:WaitForChild("RE"):GetChildren()[CLICK_EVENT_INDEX] end)
            if not s or not r then
                Rayfield:Notify({Title = "Error", Content = "Auto Click remote needs updating.", Duration = 7, Image = "alert-triangle"})
                _G.isAutoClicking = false; Rayfield.Flags.AutoClickToggle:Set(false)
                return
            end
            while _G.isAutoClicking do r:FireServer({}); task.wait(0.05) end
         end)
      end
   end,
})

local RebirthSection = ClicksTab:CreateSection("Auto Rebirth")

local REBIRTH_SERVICE_INDEX = 6 -- Path provided by Master

local rebirthOptions = {
    "1 Rebirth", "5 Rebirths", "10 Rebirths", "25 Rebirths", "50 Rebirths",
    "100 Rebirths", "200 Rebirths", "500 Rebirths", "1k Rebirths", "2.5k Rebirths",
    "Rebirth 11", "Rebirth 12", "Rebirth 13", "Rebirth 14", "Rebirth 15",
    "Rebirth 16", "Rebirth 17", "Rebirth 18", "Rebirth 19", "Rebirth 20",
    "Rebirth 21", "Rebirth 22", "Rebirth 23", "Rebirth 24", "Rebirth 25",
    "Rebirth 26", "Rebirth 27", "Rebirth 28", "Rebirth 29", "Rebirth 30",
    "Rebirth 31", "Rebirth 32", "Rebirth 33", "Rebirth 34", "Rebirth 35", "Rebirth 36"
}
local RebirthDropdown = RebirthSection:CreateDropdown({ Name = "Select Rebirth Tier", Options = rebirthOptions, CurrentOption = {rebirthOptions[1]}, MultipleOptions = false, Flag = "RebirthTierDropdown" })

_G.isAutoRebirthing = false
RebirthSection:CreateToggle({
    Name = "Auto Rebirth", CurrentValue = false, Flag = "AutoRebirthToggle",
    Callback = function(Value)
        _G.isAutoRebirthing = Value
        if Value then
            task.spawn(function()
                local s, rF = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[REBIRTH_SERVICE_INDEX]:WaitForChild("RF"):WaitForChild("jag känner en bot, hon heter anna, anna heter hon") end)
                if not s or not rF then
                    Rayfield:Notify({Title = "Error", Content = "Rebirth remote needs updating.", Duration = 7, Image = "alert-triangle"})
                    _G.isAutoRebirthing = false; Rayfield.Flags.AutoRebirthToggle:Set(false); return
                end
                while _G.isAutoRebirthing do
                    local tierId = table.find(rebirthOptions, RebirthDropdown.CurrentOption[1])
                    if tierId then pcall(rF.InvokeServer, rF, tierId); task.wait(0.5) end
                end
            end)
        end
    end
})


--============ PET TAB ============--
local PetSection = PetTab:CreateSection("Auto Hatch")

-- Restored last known working values.
local HATCH_SERVICE_INDEX = 20
local HATCH_EVENT_INDEX = 3

local function getEggNames()
    local eggNames = {}; local maps = workspace.Game.Maps
    for _, map in pairs(maps:GetChildren()) do
        if map:IsA("Folder") and map:FindFirstChild("Eggs") then
            for _, egg in pairs(map.Eggs:GetChildren()) do if egg:IsA("Model") then table.insert(eggNames, egg.Name) end end
        end
    end
    table.sort(eggNames); return eggNames
end

local allEggNames = getEggNames()
if #allEggNames == 0 then table.insert(allEggNames, "No Eggs Found") end

local EggDropdown = PetTab:CreateDropdown({ Name = "Select Egg", Options = allEggNames, CurrentOption = {allEggNames[1]}, MultipleOptions = false, Flag = "EggNameDropdown" })
_G.isAutoHatching = false
local AutoHatchStatusButton = PetTab:CreateButton({Name = "Status: Idle", Callback = function() end})

PetTab:CreateToggle({
   Name = "Auto Hatch Selected Egg (x3)", CurrentValue = false, Flag = "AutoHatchToggle",
   Callback = function(Value)
      _G.isAutoHatching = Value
      if Value then
         task.spawn(function()
            local s, hR = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[HATCH_SERVICE_INDEX]:WaitForChild("RE"):GetChildren()[HATCH_EVENT_INDEX] end)
            if not s or not hR then
                Rayfield:Notify({Title = "Error", Content = "Hatching remote needs updating.", Duration = 7, Image = "alert-circle"})
                _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false); return
            end
            while _G.isAutoHatching do
                local selected = EggDropdown.CurrentOption[1]
                if selected and selected ~= "No Eggs Found" then
                    AutoHatchStatusButton:Set("Status: Hatching " .. selected)
                    pcall(hR.FireServer, hR, selected, 2) ; task.wait(0.05)
                else
                    AutoHatchStatusButton:Set("Status: No egg selected"); _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false); break
                end
            end; AutoHatchStatusButton:Set("Status: Idle")
         end)
      else AutoHatchStatusButton:Set("Status: Idle") end
   end,
})


--============ PROFILE TAB / SETTINGS TAB / LIVE DATA ============--
-- FIX: Reverted to stable logic for stat buttons
local ProfileSection = ProfileTab:CreateSection("Live Player Statistics")
local PlaytimeButton = ProfileTab:CreateButton({ Name = "Playtime: Loading...", Callback = function() end })
local RebirthsButton = ProfileTab:CreateButton({ Name = "Rebirths: Loading...", Callback = function() end })
local ClicksButton = ProfileTab:CreateButton({ Name = "Clicks: Loading...", Callback = function() end })
local EggsButton = ProfileTab:CreateButton({ Name = "Eggs: Loading...", Callback = function() end })

local SettingsSection = SettingsTab:CreateSection("Interface Control")
SettingsTab:CreateButton({ Name = "Destroy UI", Callback = function() Rayfield:Destroy() end })
SettingsTab:CreateButton({ Name = "Restart Script", Callback = function() Rayfield:Notify({ Title = "Restarting", Content = "Script will restart in 3 seconds.", Duration = 3, Image = "loader" }); Rayfield:Destroy(); task.wait(3); pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NashrifZMgs/Super-Hero-Legends/refs/heads/main/rbcu.lua"))() end) end})

-- FIX: Reverted to stable logic for live data updater
spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local leaderstats = Player:WaitForChild("leaderstats")
    local startTime = tick()
    while task.wait(1) do
        if not pcall(function() Rayfield:IsVisible() end) then break end
        local elapsedTime = tick() - startTime; PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d", math.floor(elapsedTime / 3600), math.floor((elapsedTime % 3600) / 60), math.floor(elapsedTime % 60)))
        local r = leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths"); RebirthsButton:Set(r and "Rebirths: "..tostring(r.Value) or "Rebirths: N/A")
        local c = leaderstats:FindFirstChild("\240\159\145\143 Clicks"); ClicksButton:Set(c and "Clicks: "..tostring(c.Value) or "Clicks: N/A")
        local e = leaderstats:FindFirstChild("\240\159\165\154 Eggs"); EggsButton:Set(e and "Eggs: "..tostring(e.Value) or "Eggs: N/A")
    end
end)
