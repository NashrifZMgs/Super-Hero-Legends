--[[
    Nexus-Lua Script
    Master's Request: Create a Rayfield window with auto-clicking functionality.
    Update: Implemented correct module loading using the Knit framework.
    Functionality: UI Base, Auto Click (Functional)
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
   LoadingSubtitle = "Hooking into game services...",
   ConfigurationSaving = {
      Enabled = true,
      FileName = windowTitle .. " Hub"
   },
   KeySystem = false,
})

-- ================== Tabs ==================
local ClicksTab = Window:CreateTab("Clicks", "mouse-pointer-click")
local PetTab = Window:CreateTab("Pet", "paw-print")
local UpgradesTab = Window:CreateTab("Upgrades", "arrow-up-circle")
local MapTab = Window:CreateTab("Map", "map")
local MiscTab = Window:CreateTab("Misc", "package")
local ProfileTab = Window:CreateTab("Profile", "user-circle")
local SettingsTab = Window:CreateTab("Settings", "settings-2")

-- ================== Modules & Variables ==================
-- Based on the reference script, the game uses the Knit framework.
-- We must first get the Knit module to access all other game services.
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

-- Now, use Knit to get the ClickService module.
local ClickService = Knit.GetService('ClickService')

-- Variable to control the loop
local autoClicking = false

-- ================== Clicks Tab Functions ==================
local ClicksSection = ClicksTab:CreateSection("Automation")

ClicksTab:CreateToggle({
   Name = "Auto Click",
   CurrentValue = false,
   Flag = "AutoClickToggle", -- Unique flag for configuration saving
   Callback = function(Value)
      autoClicking = Value
      if autoClicking then
          Rayfield:Notify({Title = "Auto Click", Content = "Auto clicking has been enabled.", Duration = 3, Image = "mouse-pointer-click"})
      else
          Rayfield:Notify({Title = "Auto Click", Content = "Auto clicking has been disabled.", Duration = 3, Image = "mouse-pointer-click"})
      end

      -- Start a new thread for the clicking loop to prevent the UI from freezing
      task.spawn(function()
         while autoClicking do
            -- Use a protected call to prevent any script errors from crashing the game
            pcall(function()
                -- The reference script confirms the correct function is to :Fire() the 'click' event
                ClickService.click:Fire()
            end)
            task.wait() -- A small wait is crucial to prevent lag and crashes
         end
      end)
   end,
})

-- Load the saved settings after all elements have been created
Rayfield:LoadConfiguration()
