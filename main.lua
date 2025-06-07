-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Nexus Farm Bot",
    LoadingTitle = "Nexus-Lua Farm Interface",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "NexusFarmConfig_v33",
        UniqueIdentifier = "NexusFarmScript_033"
    }
})

--[[ GLOBAL SETTINGS & STATE VARIABLES ]]
local useGlobalDelay = true; local globalDelayTime = 0.1; local globalBurstCount = 1
local selectedPlanetIdentifier = "Planet1"
local planetDisplayOptions = {"Home (Planet1)", "Magma (Planet2)", "Mecha (Planet3)"}

local farmStates = {
    Strength = {isActive=false, thread=nil, selectedStation=1, flagName="StrFT_V33", teleportDelay=5},
    Speed    = {isActive=false, thread=nil, selectedStation=1, flagName="SpdFT_V33", teleportDelay=5},
    Aura     = {isActive=false, thread=nil, selectedStation=1, flagName="AurFT_V33", teleportDelay=5}
}

local autoFlightEnabledByUser = false; local autoFlightActive = false; local flightChargeDelay = 6; local autoFlightThread = nil

local eggOptions={"Ethereal Egg (10k)","Wild Egg (200)","Super Egg (1)","Frost Egg (15k)","Magma Egg (5M)","Magmafrost Egg (1B)","Steampunk Egg (2B)","Cyborg Egg (50B)","Futuristic Egg (15T)"};
local defaultEggDisplay=eggOptions[1]; local selectedEggNameForHatch="Ethereal Egg"
local autoHatchingActive,autoEquipBestPetsActive,autoEvolvePetsActive=false,false,false
local autoRebirthActive,autoClaimQuestsActive,autoClaimAFKGiftsActive=false,false,false
local currentAFKGiftToClaim=1

--[[ REMOTE EVENT DEFINITIONS ]]
local ReplicatedStorage=game:GetService("ReplicatedStorage"); local Remotes=ReplicatedStorage.Remotes
local TrainingRemotes,PetSystemRemotes,FlightRemotes=Remotes.Training,Remotes.Pets,Remotes.Flight
local strRemote,spdRemote,aurBeginRemote=TrainingRemotes.Strength.StrengthTrainingEvent,TrainingRemotes.Speed.SpeedTrainingEvent,TrainingRemotes.Aura.AuraTrainingBegin
local superSpeedModeRemote,aurEquilibriumRemote=TrainingRemotes.Speed.SuperSpeedMode,TrainingRemotes.Aura.AuraEquilibriumChange
local teleportRemote=TrainingRemotes.AutoTraining.BeginAutoTraining
local eggPurchaseRemote,equipBestRemote,evolveAllRemote=Remotes.EggSystem.ProcessEggPurchase,PetSystemRemotes.EquipBestPets,PetSystemRemotes.EvolveAllPetsFunction
local rebirthRemote,claimQuestsRemote,claimAFKGiftRemote=Remotes.Rebirth.RebirthRequest,Remotes.Quest.ClaimPermanentQuests,Remotes.AFK.ClaimGift
local initiateFlightRemote,chargeFlightRemote=FlightRemotes.InitiateFlight,FlightRemotes.ChargeValue

--[[ HELPER FUNCTIONS ]]
local planetBasePaths={Planet1=workspace.Planets.Planet1.MainZone,Planet2=workspace.Planets.Planet2.MainZone,Planet3=workspace.Planets.Planet3.MainZone}
local function getStationPath(sT,sN,pId)local cP=pId or selectedPlanetIdentifier;local bP=planetBasePaths[cP];if not bP then return nil end local zP=bP:FindFirstChild(sT.."Zone");if not zP then return nil end local sP=zP:FindFirstChild(sT.."TrainingStations");if not sP then return nil end return sP:FindFirstChild(sT.."TrainingStation"..sN)end
local function getDropdownCallbackString(sV,dN)if type(sV)=="string"then return sV end if type(sV)=="table"then if sV[1]and type(sV[1])=="string"then return sV[1]end if sV.Text and type(sV.Text)=="string"then return sV.Text end if sV.Value and type(sV.Value)=="string"then return sV.Value end end print("W:Could not get string from "..dN);return nil end
local function getActualEggName(dEN)if not dEN then return"Ethereal Egg"end return string.gsub(string.match(dEN,"^[^%(]+")or dEN,"%s*$","")end;selectedEggNameForHatch=getActualEggName(defaultEggDisplay)
local function getStationNumFromDropdown(v,lN)local s=getDropdownCallbackString(v,lN);if not s then return nil end return tonumber(string.match(s,"%d+"))end
local stationDropdownOptions={};for i=1,5 do table.insert(stationDropdownOptions,"Station "..i)end

--[[ UI TABS ]]
local FarmTab=Window:CreateTab("Farm",4483362458);local PetTab=Window:CreateTab("Pet",4483362458);local MiscTab=Window:CreateTab("MISC",4483362458)
local executeManagedFarmLoopWithPeriodicTeleport -- Forward declare

--[[ FARM TAB UI & LOGIC ]]
FarmTab:CreateSection("Auto Flight")
FarmTab:CreateToggle({Name="Auto Flight Sequence",Default=autoFlightEnabledByUser,Flag="AutoFlightToggle_V33",
    Callback=function(value)
        autoFlightEnabledByUser = value
        if autoFlightEnabledByUser then
            autoFlightActive = true -- Activate internal loop control
            if autoFlightThread then task.cancel(autoFlightThread) end
            print("Auto Flight Sequence INITIATED by user.")
            autoFlightThread = task.spawn(function()
                while autoFlightEnabledByUser do
                    if autoFlightActive then
                        print("Executing Flight Sequence...")
                        pcall(function() initiateFlightRemote:InvokeServer() end)
                        print("Flight initiated, waiting 1 second...")
                        task.wait(1)
                        pcall(function() chargeFlightRemote:FireServer(1) end)
                        print("Charging flight, waiting " .. flightChargeDelay .. "s...")
                        task.wait(flightChargeDelay)
                        
                        -- Auto-reset logic
                        if autoFlightEnabledByUser then -- Check again in case user turned it off during the wait
                            print("Auto-restarting flight sequence...")
                            autoFlightActive = false
                            task.wait(0.3)
                            autoFlightActive = true
                        end
                    else
                        task.wait(0.1) -- Wait briefly if internal flag is false
                    end
                end
                autoFlightThread = nil
                autoFlightActive = false
                print("Auto Flight master loop stopped.")
            end)
        else
            -- User manually turned it off. The loop will exit after its current cycle.
            print("Auto Flight Sequence DISABLED by user.")
        end
    end
})
FarmTab:CreateInput({Name="Flight Charge Delay(s)",PlaceholderText="e.g.,6",Default=tostring(flightChargeDelay),Numeric=false,Flag="FlightChargeDelayInput_V33",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=0.1 and nD<=60 then flightChargeDelay=nD;print("Flight Delay:"..flightChargeDelay.."s")else print("Inv flight delay")end end end})

FarmTab:CreateSection("Global Station Farm Controls")
FarmTab:CreateDropdown({Name="Select Planet",Options=planetDisplayOptions,Default=defaultPlanetDisplay,Flag="PlanetSelectDropdown_V33",Callback=function(sV)local sPS=getDropdownCallbackString(sV,"PlanetDd");if not sPS then return end local oPI=selectedPlanetIdentifier;if string.find(sPS,"Planet1")then selectedPlanetIdentifier="Planet1"elseif string.find(sPS,"Planet2")then selectedPlanetIdentifier="Planet2"elseif string.find(sPS,"Planet3")then selectedPlanetIdentifier="Planet3"end;print("Selected Planet:"..selectedPlanetIdentifier);if oPI~=selectedPlanetIdentifier then print("Planet chg.Restarting farms...")for sN,s in pairs(farmStates)do if s.isActive then s.isActive=false;if s.thread then task.cancel(s.thread);s.thread=nil end;Rayfield:UpdateToggle(s.flagName,false);task.wait(0.1);local pR,pBF;if sN=="Strength"then pR,pBF=strRemote,nil elseif sN=="Speed"then pR,pBF=spdRemote,activateSuperSpeedMode elseif sN=="Aura"then pR,pBF=aurEquilibriumRemote,beginAuraTraining end if pR then executeManagedFarmLoopWithPeriodicTeleport(sN,pR,pBF)end end end end end})
FarmTab:CreateToggle({Name="Enable Global Loop Delay",Default=useGlobalDelay,Flag="FarmDelayEnableToggle_V33",Callback=function(v)useGlobalDelay=v;print("Global Delay "..(v and"ON"or"OFF"))end})
FarmTab:CreateInput({Name="Global Delay(s)",PlaceholderText="e.g.,0.1",Default=tostring(globalDelayTime),Numeric=false,Flag="FarmDelayTimeInput_V33",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=0 and nD<=60 then globalDelayTime=math.max(0.1,nD);print("Global Delay:"..globalDelayTime.."s")else print("Inv delay")end end end})
FarmTab:CreateInput({Name="Global Burst Count",PlaceholderText="e.g.,10",Default=tostring(globalBurstCount),Numeric=false,Flag="FarmBurstCountInput_V33",Callback=function(T,FL)if FL then local nBC=tonumber(T);if nBC and nBC>=1 and nBC<=100 then globalBurstCount=math.floor(nBC);print("Global Burst:"..globalBurstCount)else print("Inv burst")end end end})

-- Main Farm Loop Logic (Corrected Timer Access)
executeManagedFarmLoopWithPeriodicTeleport = function(statName, primaryRemote, preBurstActionFunc)
    local farmState = farmStates[statName] -- Always get the fresh state table
    farmState.isActive = not farmState.isActive

    if farmState.isActive then
        if farmState.thread then task.cancel(farmState.thread); farmState.thread = nil end
        print(statName .. " farming INITIATED.")
        
        farmState.thread = task.spawn(function()
            local lastTeleportTime, needsInitialTeleport = 0, true
            while farmState.isActive do
                local currentTargetPlanetId = selectedPlanetIdentifier
                local currentTargetStationNum = farmState.selectedStation
                local currentTeleportDelay = farmState.teleportDelay -- Read current delay value inside the loop

                local stationObject = getStationPath(statName, currentTargetStationNum, currentTargetPlanetId)
                if not stationObject then print(statName.." S"..currentTargetStationNum.." on "..currentTargetPlanetId.." not found. Stopping.");farmState.isActive=false;Rayfield:UpdateToggle(farmState.flagName,false);break end

                if needsInitialTeleport or (os.clock() - lastTeleportTime >= currentTeleportDelay) then
                    print("Teleporting to "..statName.." S"..currentTargetStationNum.." on "..currentTargetPlanetId)
                    pcall(function() teleportRemote:InvokeServer(statName, stationObject) end)
                    lastTeleportTime = os.clock(); needsInitialTeleport = false
                    if preBurstActionFunc then preBurstActionFunc(stationObject) end
                end

                for burst = 1, globalBurstCount do if not farmState.isActive then break end local args;if statName=="Strength"then args={stationObject,(currentTargetStationNum==1 and false or true)};pcall(function()primaryRemote:FireServer(unpack(args))end)elseif statName=="Speed"then args={stationObject};pcall(function()primaryRemote:FireServer(unpack(args))end)elseif statName=="Aura"then args={true};pcall(function()primaryRemote:FireServer(unpack(args))end)end end
                if not farmState.isActive then break end
                if useGlobalDelay and globalDelayTime > 0 then task.wait(globalDelayTime) else task.wait() end
            end
            farmState.thread = nil; if not farmState.isActive then print(statName .. " farming STOPPED.") end
        end)
    else 
        if farmState.thread then task.cancel(farmState.thread); farmState.thread = nil end
        print(statName .. " farming DISABLED.")
    end
end

local function activateSuperSpeedMode(sO)pcall(function()superSpeedModeRemote:InvokeServer()end);print("Super Speed Mode ON.")end
local function beginAuraTraining(sO)if sO then pcall(function()aurBeginRemote:InvokeServer(sO)end);print("AuraTrainingBegin called.")else print("E:No station for AuraBegin")end end

FarmTab:CreateSection("Strength Training");FarmTab:CreateDropdown({Name="Station",Options=stationDropdownOptions,Default="Station 1",Flag="StrS_Dd_V33",Callback=function(v)local n=getStationNumFromDropdown(v,"StrDd");if n then farmStates.Strength.selectedStation=n;print("Sel StrS:"..n)end end});FarmTab:CreateInput({Name="TP Refresh (s)",PlaceholderText="e.g.,5",Default=tostring(farmStates.Strength.teleportDelay),Numeric=false,Flag="StrTPDelay_V33",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=1 and nD<=300 then farmStates.Strength.teleportDelay=nD;print("Str TP Delay:"..nD.."s")else print("Inv TP delay")end end end});FarmTab:CreateToggle({Name="Auto Farm Strength",Default=false,Flag=farmStates.Strength.flagName,Callback=function()executeManagedFarmLoopWithPeriodicTeleport("Strength",strRemote,nil)end})
FarmTab:CreateSection("Speed Training");FarmTab:CreateDropdown({Name="Station",Options=stationDropdownOptions,Default="Station 1",Flag="SpdS_Dd_V33",Callback=function(v)local n=getStationNumFromDropdown(v,"SpdDd");if n then farmStates.Speed.selectedStation=n;print("Sel SpdS:"..n)end end});FarmTab:CreateInput({Name="TP Refresh (s)",PlaceholderText="e.g.,5",Default=tostring(farmStates.Speed.teleportDelay),Numeric=false,Flag="SpdTPDelay_V33",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=1 and nD<=300 then farmStates.Speed.teleportDelay=nD;print("Spd TP Delay:"..nD.."s")else print("Inv TP delay")end end end});FarmTab:CreateToggle({Name="Auto Farm Speed",Default=false,Flag=farmStates.Speed.flagName,Callback=function()executeManagedFarmLoopWithPeriodicTeleport("Speed",spdRemote,activateSuperSpeedMode)end})
FarmTab:CreateSection("Aura Training");FarmTab:CreateDropdown({Name="Station",Options=stationDropdownOptions,Default="Station 1",Flag="AurS_Dd_V33",Callback=function(v)local n=getStationNumFromDropdown(v,"AurDd");if n then farmStates.Aura.selectedStation=n;print("Sel AurS:"..n)end end});FarmTab:CreateInput({Name="TP Refresh (s)",PlaceholderText="e.g.,5",Default=tostring(farmStates.Aura.teleportDelay),Numeric=false,Flag="AurTPDelay_V33",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=1 and nD<=300 then farmStates.Aura.teleportDelay=nD;print("Aur TP Delay:"..nD.."s")else print("Inv TP delay")end end end});FarmTab:CreateToggle({Name="Auto Farm Aura",Default=false,Flag=farmStates.Aura.flagName,Callback=function()executeManagedFarmLoopWithPeriodicTeleport("Aura",aurEquilibriumRemote,beginAuraTraining)end})

--[[ OTHER TABS ]]
PetTab:CreateSection("Auto Hatch Eggs");PetTab:CreateDropdown({Name="Select Egg",Options=eggOptions,Default=defaultEggDisplay,Flag="EggS_Dd_V33",Callback=function(v)local s=getDropdownCallbackString(v,"EggDd");if s then selectedEggNameForHatch=getActualEggName(s);print("Sel Egg: "..selectedEggNameForHatch)end end});PetTab:CreateToggle({Name="Auto Hatch",Default=autoHatchingActive,Flag="EggHT_V33",Callback=function(v)autoHatchingActive=v;if autoHatchingActive then print("Hatch ON")task.spawn(function()while autoHatchingActive do for i=1,globalBurstCount do if not autoHatchingActive then break end pcall(function()eggPurchaseRemote:InvokeServer(selectedEggNameForHatch,1)end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("Hatch OFF")end)else print("Hatch OFF")end end})
PetTab:CreateSection("Pet Management");PetTab:CreateToggle({Name="Auto Equip Best",Default=autoEquipBestPetsActive,Flag="EqBPT_V33",Callback=function(v)autoEquipBestPetsActive=v;if autoEquipBestPetsActive then print("EquipBest ON (8s delay)")task.spawn(function()while autoEquipBestPetsActive do for i=1,globalBurstCount do if not autoEquipBestPetsActive then break end pcall(function()equipBestRemote:InvokeServer(true)end)end task.wait(8);end print("EquipBest OFF")end)else print("EquipBest OFF")end end})
PetTab:CreateToggle({Name="Auto Evolve All",Default=autoEvolvePetsActive,Flag="EvAPT_V33",Callback=function(v)autoEvolvePetsActive=v;if autoEvolvePetsActive then print("EvolveAll ON (8s delay)")task.spawn(function()while autoEvolvePetsActive do for i=1,globalBurstCount do if not autoEvolvePetsActive then break end pcall(function()evolveAllRemote:InvokeServer()end)end task.wait(8);end print("EvolveAll OFF")end)else print("EvolveAll OFF")end end})
MiscTab:CreateSection("General Automation");MiscTab:CreateToggle({Name="Auto Rebirth",Default=autoRebirthActive,Flag="RebT_V33",Callback=function(v)autoRebirthActive=v;if autoRebirthActive then print("Rebirth ON")task.spawn(function()while autoRebirthActive do for i=1,globalBurstCount do if not autoRebirthActive then break end pcall(function()rebirthRemote:InvokeServer()end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("Rebirth OFF")end)else print("Rebirth OFF")end end})
MiscTab:CreateToggle({Name="Auto Claim Quests",Default=autoClaimQuestsActive,Flag="ClQRT_V33",Callback=function(v)autoClaimQuestsActive=v;if autoClaimQuestsActive then print("ClaimQuests ON")task.spawn(function()while autoClaimQuestsActive do for i=1,globalBurstCount do if not autoClaimQuestsActive then break end pcall(function()claimQuestsRemote:InvokeServer()end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("ClaimQuests OFF")end)else print("ClaimQuests OFF")end end})
MiscTab:CreateToggle({Name="Auto Claim AFK Gifts",Default=autoClaimAFKGiftsActive,Flag="ClAFKT_V33",Callback=function(v)autoClaimAFKGiftsActive=v;if autoClaimAFKGiftsActive then print("ClaimAFK ON");currentAFKGiftToClaim=1;task.spawn(function()while autoClaimAFKGiftsActive do print("Claim AFK#"..currentAFKGiftToClaim)pcall(function()claimAFKGiftRemote:InvokeServer(currentAFKGiftToClaim)end)task.wait(2);currentAFKGiftToClaim=(currentAFKGiftToClaim%8)+1;if currentAFKGiftToClaim==1 then if useGlobalDelay and globalDelayTime>0 then print("Cycled AFK. GlobalDelay:"..globalDelayTime.."s");task.wait(globalDelayTime)else task.wait()end end end print("ClaimAFK OFF")end)else print("ClaimAFK OFF")end end})

Rayfield:LoadConfiguration()
print("Nexus-Lua Farm Bot V33 Loaded. TP Timer logic and Flight logic updated.")
