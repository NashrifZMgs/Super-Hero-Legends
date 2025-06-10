-- Services and Aliases
local p,rs,lp,ws = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("Players").LocalPlayer, game:GetService("Workspace");

-- Script State Variables
local isAT, isAH = false, false;
local liveTrainData = {}; -- { ["World 1"] = { {RemoteName="TrainPower001", Req=100}, ... }, ... }
local liveEggData = {}; -- { ["Draw001"] = { Req=5, DisplayName="Draw001 (5 Wins)" }, ... }
local livePetModels = {}; -- { "Pet001", "Pet002", ... }

-- Helper Functions
local function pN(s) s=tostring(s):gsub("[^%d%.%a]",""):lower(); local nS={k=1e3,m=1e6,b=1e9,t=1e12,qa=1e15,qi=1e18,sx=1e21,sp=1e24,oc=1e27,no=1e30}; local x=s:match("([a-z]+)$"); if x and nS[x]then local n=s:sub(1,#s-#x); return tonumber(n)*nS[x]end; return tonumber(s)or 0; end;

-- Rayfield UI Initialization
local RF = loadstring(game:HttpGet('https://sirius.menu/rayfield'))();
local W = RF:CreateWindow({Name="Fighting Sword",LoadingTitle="Fighting Sword Interface",LoadingSubtitle="by Nexus-Lua",Theme="Amethyst",ToggleUIKeybind=Enum.KeyCode.LeftControl,ConfigurationSaving={Enabled=true,FolderName="FightingSwordConfig",FileName="FightingSword"}});
local FT,PT,MT,ST,UT,MiscT,ProT,SetT=W:CreateTab("Farm","swords"),W:CreateTab("Pet","dog"),W:CreateTab("Map","map"),W:CreateTab("Shop","shopping-cart"),W:CreateTab("Upgrade","arrow-up-circle"),W:CreateTab("Misc","sliders-horizontal"),W:CreateTab("Profile","user"),W:CreateTab("Settings","settings");

-- UI Element Declarations
local WSD, ATT, EID, AutoDeleteDropdown, AHT;

-- Live Data Scanning Engine
local function refreshAllLiveData()
    liveTrainData, liveEggData, livePetModels = {}, {}, {};
    local tempWorldOptions, tempEggOptions, tempPetOptions = {}, {}, {"None"};
    local hatchGuis = lp.PlayerGui:FindFirstChild("HatchGuis")

    -- Scan Worlds for Training Spots & Eggs
    local worldsFolder = ws:FindFirstChild("Worlds")
    if worldsFolder then
        for _, world in ipairs(worldsFolder:GetChildren()) do
            local worldNum = world.Name
            if tonumber(worldNum) then
                local worldName = "World " .. worldNum
                liveTrainData[worldName] = {}; table.insert(tempWorldOptions, worldName);
                for _, spot in ipairs(world:GetChildren()) do
                    if spot.Name:match("TrainPower") and spot:FindFirstChild("HeadStat") then
                        local reqLabel = spot.HeadStat:FindFirstChild("Frame.Frame.TextLabel")
                        if reqLabel then table.insert(liveTrainData[worldName], {RemoteName = spot.Name, Req = pN(reqLabel.Text)}) end
                    end
                    if spot.Name == "Eggs" then
                        for _, egg in ipairs(spot:GetChildren()) do
                            local costLabel = egg:FindFirstChild("PriceHUD.EggCost.Amount")
                            if costLabel and hatchGuis and hatchGuis:FindFirstChild(egg.Name) then
                                local req = pN(costLabel.Text); local displayName = egg.Name .. " (" .. costLabel.Text:gsub(" ","") .. " Wins)";
                                liveEggData[egg.Name] = {Req = req, DisplayName = displayName}; table.insert(tempEggOptions, displayName);
                            end
                        end
                    end
                end
            end
        end
    end

    -- Scan for all possible Pet Models
    local petModelFolder = rs:FindFirstChild("Asserts.PetModels")
    if petModelFolder then for _, petModel in ipairs(petModelFolder:GetChildren()) do table.insert(tempPetOptions, petModel.Name) end end
    livePetModels = tempPetOptions;

    -- Refresh UI Dropdowns with newly scanned data
    if WSD and #tempWorldOptions > 0 then local cur = WSD.CurrentOption[1]; WSD:Refresh(tempWorldOptions); if table.find(tempWorldOptions, cur) then WSD:Set({cur}) end end
    if EID and #tempEggOptions > 0 then local cur = EID.CurrentOption[1]; EID:Refresh(tempEggOptions); if table.find(tempEggOptions, cur) then EID:Set({cur}) end end
    if AutoDeleteDropdown and #livePetModels > 1 then local cur = AutoDeleteDropdown.CurrentOption; AutoDeleteDropdown:Refresh(livePetModels); AutoDeleteDropdown:Set(cur) end
    RF:Notify({Title="Live Data", Content="Refreshed all game data.", Duration=3, Image="refresh-cw"})
end

-- Farm Tab
FT:CreateSection("Auto Train Power");
FT:CreateButton({Name = "Refresh Live Data", Callback = refreshAllLiveData});
WSD = FT:CreateDropdown({Name="Select World",Options={},Flag="AutoTrainWorld",Callback=function()end});
ATT = FT:CreateToggle({Name="Auto Train Power",CurrentValue=false,Flag="AutoTrainToggle",Callback=function(V)
    isAT=V;
    if isAT then
        local c=lp.Character or lp.CharacterAdded:Wait(); local pT=c:WaitForChild("PlayerTag",5); local sO=pT and pT:WaitForChild("Strength",5);
        if not sO then RF:Notify({Title="Error",Content="Strength object not found!",Duration=8,Image="alert-octagon"});isAT=false;ATT:Set(false);return end
        local selectedWorldName = WSD.CurrentOption[1]; local worldNum = selectedWorldName and selectedWorldName:match("%d+"); if not worldNum then return end
        local worldID = "World" .. string.format("%03d", worldNum); local a={[1]=worldID}; rs.Events.World.Rf_TeleportToWorld:InvokeServer(unpack(a));
        RF:Notify({Title="Auto-Train",Content="Teleporting to "..selectedWorldName,Duration=4,Image="play"})
    else RF:Notify({Title="Auto-Train",Content="Stopped.",Duration=4,Image="hand"}) end
end});
task.spawn(function() while true do if isAT then local c=lp.Character; if c then local pT=c:FindFirstChild("PlayerTag"); if pT then local sS=pT:FindFirstChild("Strength"); if sS then
    local cS=pN(sS.Text); local selectedWorldName = WSD.CurrentOption[1];
    if selectedWorldName and liveTrainData[selectedWorldName] then
        local wTA=liveTrainData[selectedWorldName]; local tR_arg=nil;
        table.sort(wTA, function(a,b) return a.Req > b.Req end);
        for _,a in ipairs(wTA) do if cS>=a.Req then tR_arg=a.RemoteName; break end end;
        if tR_arg then local args={[1]=tR_arg}; rs.Events.Game.Re_TrainPower:FireServer(unpack(args)); end
    end
end end end; task.wait(0.1) else task.wait(1) end end end);

-- Pet Tab
PT:CreateSection("Auto Hatch & Delete");
PT:CreateButton({Name = "Refresh Live Data", Callback = refreshAllLiveData});
EID = PT:CreateDropdown({Name="Select Egg",Options={},Flag="AutoHatchEgg",Callback=function()end});
AutoDeleteDropdown = PT:CreateDropdown({Name="Auto-Delete Pet",Options={"None"},CurrentOption={"None"},MultipleOptions=true,Flag="AutoDeletePets",Callback=function()end});
AHT = PT:CreateToggle({Name="Auto Hatch",CurrentValue=false,Flag="AutoHatchToggle",Callback=function(V) isAH=V; RF:Notify({Title="Auto-Hatch",Content=V and"Started."or"Stopped.",Duration=3,Image=V and"play"or"hand"})end});

task.spawn(function() while true do if isAH then local l=lp:FindFirstChild("leaderstats"); local wS=l and l:FindFirstChild("\240\159\143\134Wins"); if wS then
    local currentEggName = EID.CurrentOption[1]; local selectedEggID;
    if currentEggName then for id, data in pairs(liveEggData) do if data.DisplayName == currentEggName then selectedEggID = id; break; end end end

    if selectedEggID and liveEggData[selectedEggID] and wS.Value >= liveEggData[selectedEggID].Req then
        local deleteList = {};
        for _, petNameToDelete in ipairs(AutoDeleteDropdown.CurrentOption) do if petNameToDelete ~= "None" then table.insert(deleteList, petNameToDelete) end end
        rs.Events.Pets.Re_Hatch:FireServer("Hatch", selectedEggID, deleteList);
    end
end; task.wait(0.1) else task.wait(1) end end end);

-- Auto-refresh & Initial Scan
task.spawn(function() task.wait(3); refreshAllLiveData(); while task.wait(30) do refreshAllLiveData() end end)

-- Map Tab
local mapWorlds = {"Castle", "Mushroom Forest", "Desert Pyramid", "Snow Land", "Underwater", "Alien Desert", "Candy", "Energy Factory", "Altar", "Demon King", "Heavenly Gates", "Halls of Valhalla", "Voidfallen Kingdom", "Realm of the Monkey King", "The Fractal Fortress", "The Timeless Cavern"}
MT:CreateSection("Teleport");
local TDD = MT:CreateDropdown({Name="Select Destination",Options=mapWorlds,CurrentOption={mapWorlds[1]},Flag="TeleportDestination",Callback=function(O)end});
MT:CreateButton({Name="Teleport",Callback=function()
    local rootPart = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if not rootPart then RF:Notify({Title="Error",Content="Cannot find char.",Duration=5,Image="alert-triangle"}); return end
    local selectedWorldName = TDD.CurrentOption[1]; local worldIndex;
    for i, name in ipairs(mapWorlds) do if name == selectedWorldName then worldIndex = i; break; end end
    if not worldIndex then RF:Notify({Title="Error",Content="Invalid world.",Duration=5,Image="alert-triangle"}); return end
    local targetObject;
    if worldIndex == 1 then targetObject = ws:FindFirstChild("SpawnLocation") else
        local worldPart = ws:FindFirstChild("Map_Model") and ws.Map_Model:FindFirstChild("World" .. string.format("%02d", worldIndex))
        targetObject = worldPart and worldPart:FindFirstChild("Core.Sword.Sword")
    end
    if targetObject and targetObject:IsA("BasePart") then rootPart.CFrame = targetObject.CFrame + Vector3.new(0, 5, 0); RF:Notify({Title="Teleport",Content="Teleported to "..selectedWorldName,Duration=5,Image="send"}) else RF:Notify({Title="Error",Content="Teleport point for "..selectedWorldName.." not found.",Duration=5,Image="alert-triangle"}) end
end});

-- Profile Tab
ProT:CreateSection("Live Player Stats");
local SL,KL,RL,WL=ProT:CreateButton({Name="Strength: ...",Callback=function()end}),ProT:CreateButton({Name="Kills: ...",Callback=function()end}),ProT:CreateButton({Name="Rebirths: ...",Callback=function()end}),ProT:CreateButton({Name="Wins: ...",Callback=function()end});
local function tS(sN,lE,pr) local l=lp:WaitForChild("leaderstats",10); if not l then lE:Set(pr..": N/A"); return end; local sO=l:FindFirstChild(sN); if sO then lE:Set(pr..": "..sO.Value); sO.Changed:Connect(function(nV)lE:Set(pr..": "..nV)end) else lE:Set(pr..": N/A") end end;
tS("\240\159\146\128 Kill",KL,"Kills"); tS("\240\159\145\145Rebirth",RL,"Rebirths"); tS("\240\159\143\134Wins",WL,"Wins");
task.spawn(function() local c=lp.Character or lp.CharacterAdded:Wait(); local pT=c:WaitForChild("PlayerTag",10); if not pT then SL:Set("Strength: N/A"); return end; local sO=pT:WaitForChild("Strength",10); if not sO then SL:Set("Strength: N/A"); return end; local function u()SL:Set(sO.Text)end; u(); sO:GetPropertyChangedSignal("Text"):Connect(u) end);

-- Settings Tab
SetT:CreateSection("UI Management");
SetT:CreateButton({Name="Destroy UI",Callback=function()RF:Destroy()end});

-- Finalization
RF:LoadConfiguration();
