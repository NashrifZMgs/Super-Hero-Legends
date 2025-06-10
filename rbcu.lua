--[[
    Nexus-Lua Script (Version 11)
    Master's Request: Rework logic to use egg names as IDs, ignoring price labels.
    Functionality: UI Base, Live Stats, UI Control, Auto Click, Auto Hatch (Name-based ID)
    Optimization: Mobile/Touchscreen, Robust Loading, Unloaded Map Compatibility
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
_G.isAutoClicking = false
ClicksTab:CreateToggle({
   Name = "Auto Click", CurrentValue = false, Flag = "AutoClickToggle",
   Callback = function(Value)
      _G.isAutoClicking = Value
      if Value then
         task.spawn(function()
            local s, r = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[19]:WaitForChild("RE"):GetChildren()[3] end)
            if not s or not r then
                Rayfield:Notify({Title = "Error", Content = "Auto Click remote not found.", Duration = 5, Image = "alert-triangle"})
                _G.isAutoClicking = false; Rayfield.Flags.AutoClickToggle:Set(false)
                return
            end
            while _G.isAutoClicking do r:FireServer({}); task.wait(0.05) end
         end)
      end
   end,
})


--============ PET TAB (NEW LOGIC) ============--
local PetSection = PetTab:CreateSection("Auto Hatch")

-- New function to get egg names directly, ignoring price labels.
local function getEggNames()
    local eggNames = {}
    local mapsFolder = workspace.Game.Maps
    for _, mapInstance in pairs(mapsFolder:GetChildren()) do
        if mapInstance:IsA("Folder") and mapInstance:FindFirstChild("Eggs") then
            for _, eggInstance in pairs(mapInstance.Eggs:GetChildren()) do
                if eggInstance:IsA("Model") then
                    table.insert(eggNames, eggInstance.Name)
                end
            end
        end
    end
    table.sort(eggNames)
    return eggNames
end

local allEggNames = getEggNames()
if #allEggNames == 0 then table.insert(allEggNames, "No Eggs Found In Workspace") end

local EggDropdown = PetTab:CreateDropdown({
    Name = "Select Egg",
    Options = allEggNames,
    CurrentOption = {allEggNames[1]},
    MultipleOptions = false,
    Flag = "EggNameDropdown",
})

_G.isAutoHatching = false
local AutoHatchStatusButton = PetTab:CreateButton({Name = "Status: Idle", Callback = function() end})

PetTab:CreateToggle({
   Name = "Auto Hatch Selected Egg",
   CurrentValue = false,
   Flag = "AutoHatchToggle",
   Callback = function(Value)
      _G.isAutoHatching = Value
      if Value then
         task.spawn(function()
            local success, hatchRemote = pcall(function()
                return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("jag k\195\164nner en bot, hon heter anna, anna heter hon"):WaitForChild("RE"):WaitForChild("jag k\195\164nner en bot, hon heter anna, anna heter hon")
            end)
            if not success or not hatchRemote then
                Rayfield:Notify({Title = "Error", Content = "Hatching remote not found. Path may need updating.", Duration = 7, Image = "alert-circle"})
                _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false)
                return
            end

            while _G.isAutoHatching do
                local selectedEggName = EggDropdown.CurrentOption[1]
                
                -- Check if a valid egg is selected before firing
                if selectedEggName and selectedEggName ~= "No Eggs Found In Workspace" then
                    AutoHatchStatusButton:Set("Status: Hatching " .. selectedEggName)
                    -- Fire remote with the egg name and map ID 1, as per your instruction.
                    hatchRemote:FireServer(selectedEggName, 1)
                    task.wait(0.05) -- Note: Affordability cannot be checked with this logic.
                else
                    AutoHatchStatusButton:Set("Status: No valid egg selected")
                    _G.isAutoHatching = false; Rayfield.Flags.AutoHatchToggle:Set(false) -- Stop if no valid egg is selected
                    break
                end
            end
            AutoHatchStatusButton:Set("Status: Idle")
         end)
      else
        AutoHatchStatusButton:Set("Status: Idle")
      end
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


--============ LIVE DATA UPDATER ============--
spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local leaderstats = Player:WaitForChild("leaderstats")
    local startTime = tick()
    while task.wait(1) do
        if not pcall(function() Rayfield:IsVisible() end) then break end
        local elapsedTime = tick() - startTime
        PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d", math.floor(elapsedTime / 3600), math.floor((elapsedTime % 3600) / 60), math.floor(elapsedTime % 60)))
        local r = leaderstats and leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths"); RebirthsButton:Set(r and "Rebirths: "..tostring(r.Value) or "Rebirths: N/A")
        local c = leaderstats and leaderstats:FindFirstChild("\240\159\145\143 Clicks"); ClicksButton:Set(c and "Clicks: "..tostring(c.Value) or "Clicks: N/A")
        local e = leaderstats and leaderstats:FindFirstChild("\240\159\165\154 Eggs"); EggsButton:Set(e and "Eggs: "..tostring(e.Value) or "Eggs: N/A")
    end
end)
