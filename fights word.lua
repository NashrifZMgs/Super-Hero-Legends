--[[
    Script: Fighting Sword UI
    Creator: Nexus-Lua for Master
    Description: A feature-rich UI with fully automated, progressive power training.
    Version: 3.0 (Auto Train Power)
]]

-- Services and Player Variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- IMPORTANT: Please verify this is the correct name for your Strength stat in leaderstats.
local STRENGTH_STAT_NAME = "💪 Strength" -- This is a common format, change if needed.

-- A variable to control the main training loop
local isAutoTraining = false

-- Helper function to parse abbreviated numbers (k, m, b, t, qa, qi, sx) into actual numbers.
local numberSuffixes = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12, qa = 1e15, qi = 1e18, sx = 1e21
}
local function parseNumber(str)
    str = tostring(str):lower()
    local suffix = str:sub(-2) -- Check for sx, qa, qi, etc.
    if not numberSuffixes[suffix] then
        suffix = str:sub(-1) -- Check for k, m, b, t
    end
    
    if numberSuffixes[suffix] then
        local numPart = str:sub(1, #str - #suffix)
        return tonumber(numPart) * numberSuffixes[suffix]
    end
    return tonumber(str) or 0
end

-- Data structure for all training areas and their requirements.
-- Requirements are written in scientific 'e' notation for efficiency.
local TrainingData = {
    ["World001"] = {
        {RemoteName = "TrainPower001", RequiredStrength = 1},
        {RemoteName = "TrainPower002", RequiredStrength = 200},
        {RemoteName = "TrainPower003", RequiredStrength = 3e3},
        {RemoteName = "TrainPower004", RequiredStrength = 7.5e3},
        {RemoteName = "TrainPower005", RequiredStrength = 28e3},
        {RemoteName = "TrainPower006", RequiredStrength = 76e3}
    },
    ["World002"] = {
        {RemoteName = "TrainPower008", RequiredStrength = 1},
        {RemoteName = "TrainPower009", RequiredStrength = 363e3},
        {RemoteName = "TrainPower010", RequiredStrength = 820e3},
        {RemoteName = "TrainPower011", RequiredStrength = 1.99e6},
        {RemoteName = "TrainPower012", RequiredStrength = 3.98e6},
        {RemoteName = "TrainPower013", RequiredStrength = 9.1e6}
    },
    ["World003"] = {
        {RemoteName = "TrainPower015", RequiredStrength = 1},
        {RemoteName = "TrainPower016", RequiredStrength = 18.6e6},
        {RemoteName = "TrainPower017", RequiredStrength = 39e6},
        {RemoteName = "TrainPower018", RequiredStrength = 84.3e6},
        {RemoteName = "TrainPower019", RequiredStrength = 178e6},
        {RemoteName = "TrainPower020", RequiredStrength = 564e6}
    },
    ["World004"] = {
        {RemoteName = "TrainPower022", RequiredStrength = 1},
        {RemoteName = "TrainPower023", RequiredStrength = 1.1e9},
        {RemoteName = "TrainPower024", RequiredStrength = 1.91e9},
        {RemoteName = "TrainPower025", RequiredStrength = 3.66e9},
        {RemoteName = "TrainPower026", RequiredStrength = 7.21e9},
        {RemoteName = "TrainPower027", RequiredStrength = 14.7e9}
    },
    ["World005"] = {
        {RemoteName = "TrainPower029", RequiredStrength = 1},
        {RemoteName = "TrainPower030", RequiredStrength = 58.5e9},
        {RemoteName = "TrainPower031", RequiredStrength = 99.7e9},
        {RemoteName = "TrainPower032", RequiredStrength = 136e9},
        {RemoteName = "TrainPower033", RequiredStrength = 255e9},
        {RemoteName = "TrainPower034", RequiredStrength = 616e9}
    },
    ["World006"] = {
        {RemoteName = "TrainPower036", RequiredStrength = 1},
        {RemoteName = "TrainPower037", RequiredStrength = 959.6e9},
        {RemoteName = "TrainPower038", RequiredStrength = 1.55e12},
        {RemoteName = "TrainPower039", RequiredStrength = 2.58e12},
        {RemoteName = "TrainPower040", RequiredStrength = 3.87e12},
        {RemoteName = "TrainPower041", RequiredStrength = 6.94e12}
    },
    ["World007"] = {
        {RemoteName = "TrainPower043", RequiredStrength = 1},
        {RemoteName = "TrainPower044", RequiredStrength = 14.61e12},
        {RemoteName = "TrainPower045", RequiredStrength = 25.41e12},
        {RemoteName = "TrainPower046", RequiredStrength = 41.94e12},
        {RemoteName = "TrainPower047", RequiredStrength = 65.22e12},
        {RemoteName = "TrainPower048", RequiredStrength = 121.47e12}
    },
    ["World008"] = {
        {RemoteName = "TrainPower050", RequiredStrength = 1},
        {RemoteName = "TrainPower051", RequiredStrength = 258.29e12},
        {RemoteName = "TrainPower052", RequiredStrength = 392.93e12},
        {RemoteName = "TrainPower053", RequiredStrength = 687.95e12},
        {RemoteName = "TrainPower054", RequiredStrength = 1.38e15},
        {RemoteName = "TrainPower055", RequiredStrength = 2.65e15}
    },
    ["World009"] = {
        {RemoteName = "TrainPower057", RequiredStrength = 1},
        {RemoteName = "TrainPower058", RequiredStrength = 6.11e15},
        {RemoteName = "TrainPower059", RequiredStrength = 9.32e15},
        {RemoteName = "TrainPower060", RequiredStrength = 20.88e15},
        {RemoteName = "TrainPower061", RequiredStrength = 41.92e15},
        {RemoteName = "TrainPower062", RequiredStrength = 73.73e15}
    },
    ["World010"] = {
        {RemoteName = "TrainPower064", RequiredStrength = 392.93e12},
        {RemoteName = "TrainPower065", RequiredStrength = 10e15},
        {RemoteName = "TrainPower066", RequiredStrength = 20e15},
        {RemoteName = "TrainPower067", RequiredStrength = 30e15},
        {RemoteName = "TrainPower068", RequiredStrength = 50e15},
        {RemoteName = "TrainPower069", RequiredStrength = 100e15}
    },
    ["World011"] = {
        {RemoteName = "TrainPower071", RequiredStrength = 100e15},
        {RemoteName = "TrainPower072", RequiredStrength = 500e15},
        {RemoteName = "TrainPower073", RequiredStrength = 1e18},
        {RemoteName = "TrainPower074", RequiredStrength = 10e18},
        {RemoteName = "TrainPower075", RequiredStrength = 25e18},
        {RemoteName = "TrainPower076", RequiredStrength = 500e18}
    },
    ["World012"] = {
        {RemoteName = "TrainPower078", RequiredStrength = 100e15},
        {RemoteName = "TrainPower079", RequiredStrength = 500e15},
        {RemoteName = "TrainPower080", RequiredStrength = 1e18},
        {RemoteName = "TrainPower081", RequiredStrength = 10e18},
        {RemoteName = "TrainPower082", RequiredStrength = 25e18},
        {RemoteName = "TrainPower083", RequiredStrength = 500e18}
    },
    ["World013"] = {
        {RemoteName = "TrainPower085", RequiredStrength = 500e18},
        {RemoteName = "TrainPower086", RequiredStrength = 1e21},
        {RemoteName = "TrainPower087", RequiredStrength = 2e21},
        {RemoteName = "TrainPower088", RequiredStrength = 3e21},
        {RemoteName = "TrainPower089", RequiredStrength = 4e21},
        {RemoteName = "TrainPower090", RequiredStrength = 5e21}
    },
    ["World014"] = {
        {RemoteName = "TrainPower092", RequiredStrength = 10e21},
        {RemoteName = "TrainPower093", RequiredStrength = 15e21},
        {RemoteName = "TrainPower094", RequiredStrength = 20e21},
        {RemoteName = "TrainPower095", RequiredStrength = 30e21},
        {RemoteName = "TrainPower096", RequiredStrength = 40e21},
        {RemoteName = "TrainPower097", RequiredStrength = 50e21}
    },
    ["World015"] = {
        {RemoteName = "TrainPower099", RequiredStrength = 70e21},
        {RemoteName = "TrainPower100", RequiredStrength = 80e21},
        {RemoteName = "TrainPower101", RequiredStrength = 90e21},
        {RemoteName = "TrainPower102", RequiredStrength = 100e21},
        {RemoteName = "TrainPower103", RequiredStrength = 150e21},
        {RemoteName = "TrainPower104", RequiredStrength = 200e21}
    },
    ["World016"] = {
        {RemoteName = "TrainPower106", RequiredStrength = 150e21},
        {RemoteName = "TrainPower107", RequiredStrength = 200e21},
        {RemoteName = "TrainPower108", RequiredStrength = 251e21},
        {RemoteName = "TrainPower109", RequiredStrength = 252e21},
        {RemoteName = "TrainPower110", RequiredStrength = 253e21}
    }
}

-- Mapping from user-friendly world names to their system IDs
local WorldNameToID = {
    ["Castle"] = "World001", ["Mushroom Forest"] = "World002", ["Desert Pyramid"] = "World003",
    ["Snow Land"] = "World004", ["Underwater"] = "World005", ["Alien Desert"] = "World006",
    ["Candy"] = "World007", ["Energy Factory"] = "World008", ["Altar"] = "World009",
    ["Demon King"] = "World010", ["Heavenly Gates"] = "World011", ["Halls of Valhalla"] = "World012",
    ["Voidfallen Kingdom"] = "World013", ["Realm of the Monkey King"] = "World014", ["The Fractal Fortress"] = "World015",
    ["The Timeless Cavern"] = "World016"
}
local WorldNames = {}
for name, _ in pairs(WorldNameToID) do table.insert(WorldNames, name) end
-- (Assuming the TeleportLocations table from the previous script is structured to maintain order)
local OrderedWorldNames = {"Castle", "Mushroom Forest", "Desert Pyramid", "Snow Land", "Underwater", "Alien Desert", "Candy", "Energy Factory", "Altar", "Demon King", "Heavenly Gates", "Halls of Valhalla", "Voidfallen Kingdom", "Realm of the Monkey King", "The Fractal Fortress", "The Timeless Cavern"}

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Fighting Sword",
   LoadingTitle = "Fighting Sword Interface",
   LoadingSubtitle = "by Nexus-Lua",
   Theme = "Amethyst",
   ToggleUIKeybind = Enum.KeyCode.LeftControl,
   ConfigurationSaving = { Enabled = true, FolderName = "FightingSwordConfig", FileName = "FightingSword"}
})

-- Create Tabs
local FarmTab = Window:CreateTab("Farm", "swords") 
-- ... (other tabs remain the same, adding them back for completeness)
local PetTab = Window:CreateTab("Pet", "dog")
local MapTab = Window:CreateTab("Map", "map") 
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local UpgradeTab = Window:CreateTab("Upgrade", "arrow-up-circle") 
local MiscTab = Window:CreateTab("Misc", "sliders-horizontal")
local ProfileTab = Window:CreateTab("Profile", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

--[[ Farm Tab Content ]]
local TrainSection = FarmTab:CreateSection("Auto Train Power")

local WorldSelectDropdown = FarmTab:CreateDropdown({
   Name = "Select World",
   Options = OrderedWorldNames,
   CurrentOption = {OrderedWorldNames[1]},
   Flag = "AutoTrainWorld",
   Callback = function() end
})

local AutoTrainToggle = FarmTab:CreateToggle({
   Name = "Auto Train Power",
   CurrentValue = false,
   Flag = "AutoTrainToggle",
   Callback = function(Value)
       isAutoTraining = Value
       if isAutoTraining then
           -- Teleport once when the toggle is enabled
           local selectedWorldName = WorldSelectDropdown.CurrentOption[1]
           local worldID = WorldNameToID[selectedWorldName]
           if worldID then
               ReplicatedStorage.Events.World.Rf_TeleportToWorld:InvokeServer(worldID)
               Rayfield:Notify({Title = "Auto-Train", Content = "Teleported to " .. selectedWorldName .. ". Starting...", Duration = 5, Image = "send"})
           else
               Rayfield:Notify({Title = "Error", Content = "Could not find World ID for " .. selectedWorldName, Duration = 5, Image = "alert-triangle"})
               isAutoTraining = false -- Stop if teleport fails
               AutoTrainToggle:Set(false)
           end
       else
           Rayfield:Notify({Title = "Auto-Train", Content = "Stopped.", Duration = 5, Image = "hand"})
       end
   end,
})

--[[ Main Auto-Training Loop ]]
task.spawn(function()
    while true do
        if isAutoTraining then
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local strengthStat = leaderstats and leaderstats:FindFirstChild(STRENGTH_STAT_NAME)

            if not strengthStat then
                -- Wait and try again if stats are not loaded yet
                task.wait(1)
            else
                local currentStrength = parseNumber(strengthStat.Value)
                local selectedWorldName = WorldSelectDropdown.CurrentOption[1]
                local worldID = WorldNameToID[selectedWorldName]
                local worldTrainingAreas = TrainingData[worldID]
                
                local targetRemote = nil
                -- Iterate backwards to find the best available training area
                for i = #worldTrainingAreas, 1, -1 do
                    local area = worldTrainingAreas[i]
                    if currentStrength >= area.RequiredStrength then
                        targetRemote = area.RemoteName
                        break -- Found the best one, no need to check further
                    end
                end

                if targetRemote then
                    -- Fire the remote event for the best training area
                    ReplicatedStorage.Events.Game.Re_TrainPower:FireServer(targetRemote)
                end
                task.wait(0.1) -- Loop delay as commanded
            end
        else
            task.wait(1) -- Wait longer when inactive to save resources
        end
    end
end)

-- You can add the content for the other tabs here as before
-- I will omit them for brevity, but they are part of the full script

-- Load Configuration
Rayfield:LoadConfiguration()
