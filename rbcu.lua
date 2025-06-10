--[[
    Nexus-Lua Script
    Master's Request: Add live stats to Profile tab and a Destroy UI button to Settings tab.
    Functionality: UI Base, Live Stats Display, UI Control
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
   LoadingSubtitle = "Loading Script...",
   ConfigurationSaving = {
      Enabled = true,
      FileName = windowTitle .. " Hub" -- Saves settings under a file named after the game
   },
   KeySystem = false,
})

--============ TABS ============--
local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click")
local PetTab = Window:CreateTab("Pet", "paw-print")
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle")
local MapTab = Window:CreateTab("Map", "map")
local MiscTab = Window:CreateTab("Misc", "package")
local ProfileTab = Window:CreateTab("Profile", "user-circle")
local SettingsTab = Window:Create-Tab("Settings", "settings-2")


--============ PROFILE TAB ============--
local ProfileSection = ProfileTab:CreateSection("Live Player Statistics")

-- Create buttons to display stats. The callback is empty as they are for visual feedback only.
local PlaytimeButton = ProfileTab:CreateButton({
   Name = "Playtime: Loading...",
   Callback = function() end,
})

local RebirthsButton = ProfileTab:CreateButton({
   Name = "Rebirths: Loading...",
   Callback = function() end,
})

local ClicksButton = ProfileTab:CreateButton({
   Name = "Clicks: Loading...",
   Callback = function() end,
})

local EggsButton = ProfileTab:CreateButton({
   Name = "Eggs: Loading...",
   Callback = function() end,
})


--============ SETTINGS TAB ============--
local SettingsSection = SettingsTab:CreateSection("Interface Control")

SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
      Rayfield:Destroy() -- This function destroys the entire user interface
   end,
})


--============ LIVE DATA UPDATER ============--
-- This function runs in the background to keep the stats updated.
spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local leaderstats = Player:WaitForChild("leaderstats") -- Wait for leaderstats to load to prevent errors
    local startTime = tick() -- Record the time the script started to calculate playtime

    -- This loop runs forever to provide live data
    while wait(1) do
        -- Update Playtime
        local elapsedTime = tick() - startTime
        local hours = math.floor(elapsedTime / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)
        PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d", hours, minutes, seconds))

        -- Update Rebirths Stat
        local rebirthsValue = leaderstats and leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths")
        if rebirthsValue then
            RebirthsButton:Set("Rebirths: " .. tostring(rebirthsValue.Value))
        else
            RebirthsButton:Set("Rebirths: Not Found")
        end
        
        -- Update Clicks Stat
        local clicksValue = leaderstats and leaderstats:FindFirstChild("\240\159\145\143 Clicks")
        if clicksValue then
            ClicksButton:Set("Clicks: " .. tostring(clicksValue.Value))
        else
            ClicksButton:Set("Clicks: Not Found")
        end

        -- Update Eggs Stat
        local eggsValue = leaderstats and leaderstats:FindFirstChild("\240\159\165\154 Eggs")
        if eggsValue then
            EggsButton:Set("Eggs: " .. tostring(eggsValue.Value))
        else
            EggsButton:Set("Eggs: Not Found")
        end
    end
end)
