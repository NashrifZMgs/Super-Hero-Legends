--[[
    Nexus-Lua Script
    Master's Request: Create a Rayfield window with a live game name and seven specific tabs.
    Game ID Provided: 74260430392611
    Functionality: UI Base
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

-- Create the requested tabs with icons
-- Lucide icons are used as they are lightweight and ideal for mobile displays.

local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click") -- Icon for clicking
local PetTab = Window:CreateTab("Pet", "paw-print") -- Icon for pets
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle") -- Icon for upgrades
local MapTab = Window:CreateTab("Map", "map") -- Icon for map/teleporting
local MiscTab = Window:CreateTab("Misc", "package") -- Icon for miscellaneous items
local ProfileTab = Window:CreateTab("Profile", "user-circle") -- Icon for player profile
local SettingsTab = Window:CreateTab("Settings", "settings-2") -- Icon for settings

-- The base UI is now complete. Awaiting further commands to add functions to these tabs.
