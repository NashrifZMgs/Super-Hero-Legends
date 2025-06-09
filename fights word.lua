--[[
    Script: Fighting Sword UI
    Creator: Nexus-Lua for Master
    Description: A clean and foundational UI for a sword fighting game,
                 created with the Rayfield library.
]]

-- Load the Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
-- This is the main container for all UI elements.
local Window = Rayfield:CreateWindow({
   Name = "Fighting Sword",
   LoadingTitle = "Fighting Sword Interface",
   LoadingSubtitle = "by Nexus-Lua",
   Theme = "Amethyst", -- A visually pleasing theme
   ToggleUIKeybind = "LeftControl", -- Keybind to toggle the UI on PC. Mobile users will use the executor's toggle button.
   
   -- Configuration saving is enabled to remember user settings across sessions
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FightingSwordConfig", -- A unique folder to prevent conflicts
      FileName = "FightingSword"
   }
})

-- Create the main tabs for different functions of the script
-- Icons are from Lucide Icons, which are lightweight and ideal for mobile.

-- Farm Tab: For features related to automatic farming
local FarmTab = Window:CreateTab("Farm", "swords") 

-- Pet Tab: For managing in-game pets
local PetTab = Window:CreateTab("Pet", "dog")

-- Shop Tab: For automatic purchasing or shop-related features
local ShopTab = Window:CreateTab("Shop", "shopping-cart")

-- Upgrade Tab: For automating character or item upgrades
local UpgradeTab = Window:CreateTab("Upgrade", "arrow-up-circle") 

-- Misc Tab: For miscellaneous features like ESP, WalkSpeed, etc.
local MiscTab = Window:CreateTab("Misc", "sliders-horizontal")

-- Profile Tab: For managing user settings, themes, and credits
local ProfileTab = Window:CreateTab("Profile", "user")

-- Settings Tab: Contains UI settings and actions
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Section for UI options within the Settings tab
local UISection = SettingsTab:CreateSection("UI Management")

-- Button to destroy the UI
-- This will completely remove the Rayfield interface from the game.
local DestroyButton = SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
       Rayfield:Destroy()
   end,
})

-- Load the saved configuration for all elements
-- This must be at the end of the script to properly load saved values.
Rayfield:LoadConfiguration()
