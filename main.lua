-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Nexus Farm Bot",
    LoadingTitle = "Nexus-Lua Farm Interface",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "NexusFarmConfig_v44_Final",
        UniqueIdentifier = "NexusFarmScript_044"
    }
})

--[[
    GLOBAL SETTINGS & STATE VARIABLES
]]
local useGlobalDelay = true; local globalDelayTime = 0.1; local globalBurstCount = 1
local selectedPlanetIdentifier = "Planet1"
local planetDisplayOptions = {"Home (Planet1)", "Magma (Planet2)", "Mecha (Planet3)"}

local farmStates = {
    Strength = {isActive=false, thread=nil, flagName="StrFT_V44"},
    Speed    = {isActive=false, thread=nil, flagName="SpdFT_V44"},
    Aura     = {isActive=false, thread=nil, flagName="AurFT_V44"}
}

local autoFlightActive, flightChargeDelay, autoFlightThread = false, 6, nil
local eggOptions={"Ethereal Egg (10k)","Wild Egg (200)","Super Egg (1)","Frost Egg (15k)","Magma Egg (5M)","Magmafrost Egg (1B)","Steampunk Egg (2B)","Cyborg Egg (50B)","Futuristic Egg (15T)"};
local defaultEggDisplay=eggOptions[1]; local selectedEggNameForHatch="Ethereal Egg"
local autoHatchingActive,autoEquipBestPetsActive,autoEvolvePetsActive=false,false,false
local autoRebirthActive,autoClaimQuestsActive,autoClaimAFKGiftsActive=false,false,false
local currentAFKGiftToClaim=1

--[[ REQUIREMENTS & TELEPORT DATA ]]
local stationRequirements={P1={S={0,100,1e3,10e3,65e3},Spd={0,100,1e3,10e3,65e3},A={0,100,1e3,10e3,65e3}},P2={S={0,1.5e6,5e6,50e6,250e6},Spd={0,1.5e6,5e6,50e6,250e6},A={0,1.5e6,5e6,50e6,250e6}},P3={S={0,5e9,30e9,100e9,500e9},Spd={0,5e9,30e9,100e9,500e9},A={0,5e9,30e9,100e9,500e9}}}
local planetXPositions = {Planet1 = 0.178, Planet2 = -8480.881, Planet3 = -15731.88}

--[[ REMOTE EVENT DEFINITIONS ]]
local ReplicatedStorage=game:GetService("ReplicatedStorage"); local Remotes=ReplicatedStorage.Remotes
local TrainingR,PetSystemR,FlightR=Remotes.Training,Remotes.Pets,Remotes.Flight
local strR,spdR,aurBeginR=TrainingR.Strength.StrengthTrainingEvent,TrainingR.Speed.SpeedTrainingEvent,TrainingR.Aura.AuraTrainingBegin
local superSpeedR,aurEquilibriumR,aurStopR=TrainingR.Speed.SuperSpeedMode,TrainingR.Aura.AuraEquilibriumChange,TrainingR.Aura.AuraTrainingStop
local tpR=TrainingR.AutoTraining.BeginAutoTraining
local eggPR,eqBR,evAR=Remotes.EggSystem.ProcessEggPurchase,PetSystemR.EquipBestPets,PetSystemR.EvolveAllPetsFunction
local rebR,clQR,clAFKR=Remotes.Rebirth.RebirthRequest,Remotes.Quest.ClaimPermanentQuests,Remotes.AFK.ClaimGift
local initFR,chargeFR=FlightR.InitiateFlight,FlightR.ChargeValue

--[[ PLAYER STATS POINTERS (CRITICAL FIX) ]]
local Players=game:GetService("Players");local LocalPlayer=Players.LocalPlayer;local leaderstats=LocalPlayer:WaitForChild("leaderstats")
local strengthStatName, speedStatName, auraStatName = "\240\159\146\170 Strength_Raw", "\226\154\161 Speed_Raw", "\240\159\140\159 Aura_Raw"
local strengthStat=leaderstats:WaitForChild(strengthStatName);local speedStat=leaderstats:WaitForChild(speedStatName);local auraStat=leaderstats:WaitForChild(auraStatName)
local playerStats={Strength=strengthStat,Speed=speedStat,Aura=auraStat}

--[[ HELPER FUNCTIONS ]]
local planetBasePaths={Planet1=workspace.Planets.Planet1,Planet2=workspace.Planets.Planet2,Planet3=workspace.Planets.Planet3}
local function getStationPath(sT,sN,pId)local bP=planetBasePaths[pId or selectedPlanetIdentifier];if not bP then return nil end local zP=bP.MainZone:FindFirstChild(sT.."Zone");if not zP then return nil end local sP=zP:FindFirstChild(sT.."TrainingStations");if not sP then return nil end return sP:FindFirstChild(sT.."TrainingStation"..sN)end
local function getDropdownCallbackString(sV,dN)if type(sV)=="string"then return sV end if type(sV)=="table"then if sV[1]and type(sV[1])=="string"then return sV[1]end if sV.Text and type(sV.Text)=="string"then return sV.Text end if sV.Value and type(sV.Value)=="string"then return sV.Value end end print("W:Could not get string from "..dN);return nil end
local function getActualEggName(dEN)if not dEN then return"Ethereal Egg"end return string.gsub(string.match(dEN,"^[^%(]+")or dEN,"%s*$","")end;selectedEggNameForHatch=getActualEggName(defaultEggDisplay)
local function formatNumber(n)if type(n)~="number"then return "N/A" end local s={"","K","M","B","T","Q","Qi","S","Sp","O","N","D"};local i=1;while n>=1000 and i<#s do n=n/1000;i=i+1 end return string.format("%.2f%s",n,s[i])end
local function getCurrentPlayerPlanet()for pId,pPath in pairs(planetBasePaths)do if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and pPath:IsAncestorOf(LocalPlayer.Character.PrimaryPart)then return pId end end return nil end

--[[ UI TABS ]]
local FarmTab=Window:CreateTab("Farm",4483362458);local PetTab=Window:CreateTab("Pet",4483362458);local MapTab=Window:CreateTab("Map",4483362458);local MiscTab=Window:CreateTab("MISC",4483362458);local ProfileTab=Window:CreateTab("Profile",4483362458)
local StartFarming, StopFarming, StartAuraFarming, StopAuraFarming -- Forward declare

--[[ MAP TAB ]]
MapTab:CreateSection("Planet Teleportation");local selectedMapPlanet="Planet1";MapTab:CreateDropdown({Name="Destination",Options=planetDisplayOptions,Default=defaultPlanetDisplay,Flag="MapPlanetDropdown_V44",Callback=function(v)local s=getDropdownCallbackString(v,"MapDd");if s then if string.find(s,"Planet1")then selectedMapPlanet="Planet1"elseif string.find(s,"Planet2")then selectedMapPlanet="Planet2"elseif string.find(s,"Planet3")then selectedMapPlanet="Planet3"end end end});MapTab:CreateButton({Name="Teleport to Planet",Callback=function()local targetX=planetXPositions[selectedMapPlanet];local char=LocalPlayer.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if hrp and targetX then local currentPos=hrp.CFrame.Position;print("Teleporting to "..selectedMapPlanet.."...");pcall(function()hrp.CFrame=CFrame.new(targetX,currentPos.Y+20,currentPos.Z)end)else print("E:Cannot teleport. HRP or TargetX not found.")end end})

--[[ FARM TAB UI & LOGIC ]]
FarmTab:CreateSection("Auto Flight");FarmTab:CreateToggle({Name="Auto Flight Sequence",Default=autoFlightEnabledByUser,Flag="AutoFlightToggle_V44",Callback=function(v)autoFlightEnabledByUser=v;if autoFlightEnabledByUser then autoFlightActive=true;if autoFlightThread then task.cancel(autoFlightThread)end;print("Auto Flight ON.");autoFlightThread=task.spawn(function()while autoFlightEnabledByUser do if autoFlightActive then print("Flight Sequence Start.");pcall(function()initFR:InvokeServer()end);task.wait(1);pcall(function()chargeFR:FireServer(1)end);print("Flight Charged. Wait "..flightChargeDelay.."s.");task.wait(flightChargeDelay);if autoFlightEnabledByUser then print("Auto-restarting flight.");autoFlightActive=false;task.wait(0.3);autoFlightActive=true end else task.wait(0.1)end end;autoFlightThread=nil;autoFlightActive=false;print("Auto Flight master loop stopped.")end)else print("Auto Flight OFF.")end end});FarmTab:CreateInput({Name="Flight Charge Delay(s)",PlaceholderText="e.g.,6",Default=tostring(flightChargeDelay),Numeric=false,Flag="FlightChargeDelayInput_V44",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=0.1 and nD<=60 then flightChargeDelay=nD;print("Flight Delay:"..flightChargeDelay.."s")else print("Inv flight delay")end end end})
FarmTab:CreateSection("Global Farm Controls");FarmTab:CreateDropdown({Name="Select Planet",Options=planetDisplayOptions,Default=defaultPlanetDisplay,Flag="PlanetSelectDropdown_V44",Callback=function(sV)local sPS=getDropdownCallbackString(sV,"PlanetDd");if not sPS then return end;if string.find(sPS,"Planet1")then selectedPlanetIdentifier="Planet1"elseif string.find(sPS,"Planet2")then selectedPlanetIdentifier="Planet2"elseif string.find(sPS,"Planet3")then selectedPlanetIdentifier="Planet3"end;print("Farm target planet set to: "..selectedPlanetIdentifier)end})
FarmTab:CreateToggle({Name="Enable Global Loop Delay",Default=useGlobalDelay,Flag="FarmDelayEnableToggle_V44",Callback=function(v)useGlobalDelay=v;print("Global Delay "..(v and"ON"or"OFF"))end})
FarmTab:CreateInput({Name="Global Delay(s)",PlaceholderText="e.g.,0.1",Default=tostring(globalDelayTime),Numeric=false,Flag="FarmDelayTimeInput_V44",Callback=function(T,FL)if FL then local nD=tonumber(T);if nD and nD>=0 and nD<=60 then globalDelayTime=math.max(0.1,nD);print("Global Delay:"..globalDelayTime.."s")else print("Inv delay")end end end})
FarmTab:CreateInput({Name="Global Burst Count",PlaceholderText="e.g.,10",Default=tostring(globalBurstCount),Numeric=false,Flag="FarmBurstCountInput_V44",Callback=function(T,FL)if FL then local nBC=tonumber(T);if nBC and nBC>=1 and nBC<=100 then globalBurstCount=math.floor(nBC);print("Global Burst:"..globalBurstCount)else print("Inv burst")end end end})

-- Logic for Strength and Speed
StartFarming=function(statName)local farmState=farmStates[statName];farmState.isActive=true;if farmState.thread then task.cancel(farmState.thread)end;print(statName.." farming INITIATED.");farmState.thread=task.spawn(function()if getCurrentPlayerPlanet()~=selectedPlanetIdentifier then local targetX=planetXPositions[selectedPlanetIdentifier];local char=LocalPlayer.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if hrp and targetX then local currentPos=hrp.CFrame.Position;print("Planet mismatch. TP to "..selectedPlanetIdentifier.."...");pcall(function()hrp.CFrame=CFrame.new(targetX,currentPos.Y+20,currentPos.Z)end);task.wait(2)end end;local lastTeleportTime,needsInitialTeleport=0,true;local currentTargetStationNum,statObject=0,playerStats[statName];while farmState.isActive do local playerStatValue=statObject.Value;local reqTableKey="P"..string.sub(selectedPlanetIdentifier,-1);local statKey=statName=="Speed"and"Spd"or"S";local reqs=stationRequirements[reqTableKey][statKey];local bestStation=1;for i=#reqs,1,-1 do if playerStatValue>=reqs[i]then bestStation=i;break end end;local stationObject=getStationPath(statName,bestStation,selectedPlanetIdentifier);if not stationObject then print(statName.." S"..bestStation.." on "..selectedPlanetIdentifier.." not found. Stopping.");StopFarming(statName);Rayfield:UpdateToggle(farmState.flagName,false);break end;if bestStation~=currentTargetStationNum then currentTargetStationNum,needsInitialTeleport=bestStation,true end;local primaryRemote,preBurstActionFunc;if statName=="Strength"then primaryRemote,preBurstActionFunc=strR,nil elseif statName=="Speed"then primaryRemote,preBurstActionFunc=spdR,activateSuperSpeedMode end;if needsInitialTeleport or(os.clock()-lastTeleportTime>=5)then print("Teleporting to "..statName.." S"..currentTargetStationNum);pcall(function()tpR:InvokeServer(statName,stationObject)end);lastTeleportTime=os.clock();needsInitialTeleport=false;if preBurstActionFunc then preBurstActionFunc(stationObject)end end;for b=1,globalBurstCount do if not farmState.isActive then break end local a={stationObject,(statName=="Strength"and(currentTargetStationNum==1 and false or true))};pcall(function()primaryRemote:FireServer(unpack(a))end)end;if not farmState.isActive then break end;if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end;farmState.thread=nil;if not farmState.isActive then print(statName.." farming STOPPED.")end end)end
StopFarming=function(statName)local farmState=farmStates[statName];if farmState.isActive then farmState.isActive=false;if farmState.thread then task.cancel(farmState.thread);farmState.thread=nil end;print(statName.." farming DISABLED.")end end
local function activateSuperSpeedMode(sO)pcall(function()superSpeedR:InvokeServer()end);print("Super Speed Mode ON.")end

-- Dedicated Logic for Aura
StartAuraFarming=function()local farmState=farmStates.Aura;farmState.isActive=true;if farmState.thread then task.cancel(farmState.thread)end;print("Aura farming INITIATED.");farmState.thread=task.spawn(function()if getCurrentPlayerPlanet()~=selectedPlanetIdentifier then local targetX=planetXPositions[selectedPlanetIdentifier];local char=LocalPlayer.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if hrp and targetX then local currentPos=hrp.CFrame.Position;print("Planet mismatch. TP to "..selectedPlanetIdentifier.."...");pcall(function()hrp.CFrame=CFrame.new(targetX,currentPos.Y+20,currentPos.Z)end);task.wait(2)end end;local lastTeleportTime,needsInitialTeleport=0,true;local currentTargetStationNum,statObject=0,playerStats.Aura;while farmState.isActive do local playerStatValue=statObject.Value;local reqTableKey="P"..string.sub(selectedPlanetIdentifier,-1);local reqs=stationRequirements[reqTableKey].A;local bestStation=1;for i=#reqs,1,-1 do if playerStatValue>=reqs[i]then bestStation=i;break end end;local stationObject=getStationPath("Aura",bestStation,selectedPlanetIdentifier);if not stationObject then print("Aura S"..bestStation.." on "..selectedPlanetIdentifier.." not found. Stopping.");StopAuraFarming();Rayfield:UpdateToggle(farmState.flagName,false);break end;if bestStation~=currentTargetStationNum then pcall(function()aurStopR:FireServer()end);print("Aura STOPPED. New target: S"..bestStation);currentTargetStationNum,needsInitialTeleport=bestStation,true end;if needsInitialTeleport or(os.clock()-lastTeleportTime>=5)then print("Teleporting to Aura S"..currentTargetStationNum);pcall(function()tpR:InvokeServer("Aura",stationObject)end);lastTeleportTime=os.clock();needsInitialTeleport=false;pcall(function()aurBeginR:InvokeServer(stationObject)end);print("AuraTrainingBegin called.")end;for b=1,globalBurstCount do if not farmState.isActive then break end pcall(function()aurEquilibriumR:FireServer(true)end)end;if not farmState.isActive then break end;if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end;farmState.thread=nil;if not farmState.isActive then print("Aura farming STOPPED.")end end)end
StopAuraFarming=function()local farmState=farmStates.Aura;if farmState.isActive then farmState.isActive=false;if farmState.thread then task.cancel(farmState.thread);farmState.thread=nil end;pcall(function()aurStopR:FireServer()end);print("Aura farming DISABLED.")end end

FarmTab:CreateSection("Strength Training");FarmTab:CreateToggle({Name="Auto Farm Strength",Default=false,Flag=farmStates.Strength.flagName,Callback=function(v)if v then StartFarming("Strength")else StopFarming("Strength")end end})
FarmTab:CreateSection("Speed Training");FarmTab:CreateToggle({Name="Auto Farm Speed",Default=false,Flag=farmStates.Speed.flagName,Callback=function(v)if v then StartFarming("Speed")else StopFarming("Speed")end end})
FarmTab:CreateSection("Aura Training");FarmTab:CreateToggle({Name="Auto Farm Aura",Default=false,Flag=farmStates.Aura.flagName,Callback=function(v)if v then StartAuraFarming()else StopAuraFarming()end end})

--[[ OTHER TABS ]]
ProfileTab:CreateSection("Player Stats");local strLbl=ProfileTab:CreateLabel("Strength: Loading...");local spdLbl=ProfileTab:CreateLabel("Speed: Loading...");local aurLbl=ProfileTab:CreateLabel("Aura: Loading...");task.spawn(function()while task.wait(0.5)do if strengthStat and strLbl then strLbl:Set("💪 Strength: "..formatNumber(strengthStat.Value))end;if speedStat and spdLbl then spdLbl:Set("⚡ Speed: "..formatNumber(speedStat.Value))end;if auraStat and aurLbl then aurLbl:Set("☀️ Aura: "..formatNumber(auraStat.Value))end end end)
PetTab:CreateSection("Auto Hatch Eggs");PetTab:CreateDropdown({Name="Select Egg",Options=eggOptions,Default=defaultEggDisplay,Flag="EggS_Dd_V44",Callback=function(v)local s=getDropdownCallbackString(v,"EggDd");if s then selectedEggNameForHatch=getActualEggName(s);print("Sel Egg: "..selectedEggNameForHatch)end end});PetTab:CreateToggle({Name="Auto Hatch",Default=autoHatchingActive,Flag="EggHT_V44",Callback=function(v)autoHatchingActive=v;if v then print("Hatch ON")task.spawn(function()while autoHatchingActive do for i=1,globalBurstCount do if not autoHatchingActive then break end pcall(function()eggPR:InvokeServer(selectedEggNameForHatch,1)end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("Hatch OFF")end)else print("Hatch OFF")end end})
PetTab:CreateSection("Pet Management");PetTab:CreateToggle({Name="Auto Equip Best",Default=autoEquipBestPetsActive,Flag="EqBPT_V44",Callback=function(v)autoEquipBestPetsActive=v;if v then print("EquipBest ON (8s delay)")task.spawn(function()while autoEquipBestPetsActive do for i=1,globalBurstCount do if not autoEquipBestPetsActive then break end pcall(function()eqBR:InvokeServer(true)end)end task.wait(8);end print("EquipBest OFF")end)else print("EquipBest OFF")end end})
PetTab:CreateToggle({Name="Auto Evolve All",Default=autoEvolvePetsActive,Flag="EvAPT_V44",Callback=function(v)autoEvolvePetsActive=v;if v then print("EvolveAll ON (8s delay)")task.spawn(function()while autoEvolvePetsActive do for i=1,globalBurstCount do if not autoEvolvePetsActive then break end pcall(function()evAR:InvokeServer()end)end task.wait(8);end print("EvolveAll OFF")end)else print("EvolveAll OFF")end end})
MiscTab:CreateSection("General Automation");MiscTab:CreateToggle({Name="Auto Rebirth",Default=autoRebirthActive,Flag="RebT_V44",Callback=function(v)autoRebirthActive=v;if v then print("Rebirth ON")task.spawn(function()while autoRebirthActive do for i=1,globalBurstCount do if not autoRebirthActive then break end pcall(function()rebR:InvokeServer()end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("Rebirth OFF")end)else print("Rebirth OFF")end end})
MiscTab:CreateToggle({Name="Auto Claim Quests",Default=autoClaimQuestsActive,Flag="ClQRT_V44",Callback=function(v)autoClaimQuestsActive=v;if v then print("ClaimQuests ON")task.spawn(function()while autoClaimQuestsActive do for i=1,globalBurstCount do if not autoClaimQuestsActive then break end pcall(function()clQR:InvokeServer()end)end if useGlobalDelay and globalDelayTime>0 then task.wait(globalDelayTime)else task.wait()end end print("ClaimQuests OFF")end)else print("ClaimQuests OFF")end end})
MiscTab:CreateToggle({Name="Auto Claim AFK Gifts",Default=autoClaimAFKGiftsActive,Flag="ClAFKT_V44",Callback=function(v)autoClaimAFKGiftsActive=v;if v then print("ClaimAFK ON");currentAFKGiftToClaim=1;task.spawn(function()while autoClaimAFKGiftsActive do print("Claim AFK#"..currentAFKGiftToClaim)pcall(function()clAFKR:InvokeServer(currentAFKGiftToClaim)end)task.wait(2);currentAFKGiftToClaim=(currentAFKGiftToClaim%8)+1;if currentAFKGiftToClaim==1 then if useGlobalDelay and globalDelayTime>0 then print("Cycled AFK. GlobalDelay:"..globalDelayTime.."s");task.wait(globalDelayTime)else task.wait()end end end print("ClaimAFK OFF")end)else print("ClaimAFK OFF")end end})

Rayfield:LoadConfiguration()
print("Nexus-Lua Farm Bot V44 Loaded. Aura logic and CFrame TP systems finalized.")
