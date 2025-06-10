--[[
    Nexus-Lua Script (Version 5)
    Master's Request: Fix script loading error.
    Functionality: UI Base, Live Stats, UI Control, Auto Click Farm (Corrected)
    Optimization: Mobile/Touchscreen, Robust Loading
]]

-- A more stable way to load the Rayfield library, with corrected variable assignment
local status, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

-- Check if the library loaded correctly. If not, stop the script and inform the user.
if not status or not Rayfield then
    warn("Nexus-Lua: CRITICAL ERROR - The Rayfield UI library failed to load.")
    warn("This can be an issue with your executor or internet connection. Please try again.")
    return -- Stops the script from running further to prevent more errors
end

-- Get the live name of the current game to use as the window title
local success, gameName = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- If fetching the name fails, use a default name
local windowTitle = success and gameName or "Game Hub"

-- Create the main window.
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
local SettingsTab = Window:CreateTab("Settings", "settings-2")


--============ CLICKS TAB ============--
local ClicksSection = ClicksTab:CreateSection("Farming")

_G.isAutoClicking = false

ClicksTab:CreateToggle({
   Name = "Auto Click",
   CurrentValue = false,
   Flag = "AutoClickToggle",
   Callback = function(Value)
      _G.isAutoClicking = Value
      
      if Value then
         task.spawn(function()
            -- Find the remote event for clicking
            local success, clickRemote = pcall(function()
                return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):GetChildren()[19]:WaitForChild("RE"):GetChildren()[3]
            end)
            
            if not success or not clickRemote then
                Rayfield:Notify({Title = "Error", Content = "Auto Click remote not found.", Duration = 5, Image = "alert-triangle"})
                _G.isAutoClicking = false -- Turn the master switch off
                -- This is a failsafe and should not be needed, but good practice
                local toggle = Rayfield.Flags.AutoClickToggle
                if toggle then
                    toggle:Set(false)
                end
                return
            end
            
            local args = {}
            while _G.isAutoClicking do
                clickRemote:FireServer(unpack(args))
                task.wait(0.05)
            end
         end)
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

SettingsTab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
      Rayfield:Destroy()
   end,
})


--============ LIVE DATA UPDATER ============--
spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    local leaderstats = Player:WaitForChild("leaderstats")
    local startTime = tick()

    while task.wait(1) do
        if not pcall(function() Rayfield:IsVisible() end) then break end

        local elapsedTime = tick() - startTime
        local hours = math.floor(elapsedTime / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)
        PlaytimeButton:Set(string.format("Playtime: %02d:%02d:%02d", hours, minutes, seconds))

        local rebirthsValue = leaderstats and leaderstats:FindFirstChild("\226\153\187\239\184\143 Rebirths")
        if rebirthsValue then
            RebirthsButton:Set("Rebirths: " .. tostring(rebirthsValue.Value))
        else
            RebirthsButton:Set("Rebirths: Not Found")
        end
        
        local clicksValue = leaderstats and leaderstats:FindFirstChild("\240\159\145\143 Clicks")
        if clicksValue then
            ClicksButton:Set("Clicks: " .. tostring(clicksValue.Value))
        else
            ClicksButton:Set("Clicks: Not Found")
        end

        local eggsValue = leaderstats and leaderstats:FindFirstChild("\240\159\165\154 Eggs")
        if eggsValue then
            EggsButton:Set("Eggs: " .. tostring(eggsValue.Value))
        else
            EggsButton:Set("Eggs: Not Found")
        end
    end
end)
