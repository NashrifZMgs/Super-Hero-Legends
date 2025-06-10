-- Services and Aliases
local p,rs,lp,ws = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("Players").LocalPlayer, game:GetService("Workspace");

-- Script State Variables
local isAT, isAH = false, false;
local petNicknameToIdMap = {};

-- Data Tables
local nS = {k=1e3,m=1e6,b=1e9,t=1e12,qa=1e15,qi=1e18,sx=1e21,sp=1e24,oc=1e27,no=1e30};
local TD = {
    ["World001"]={{R="TrainPower001",S=1},{R="TrainPower002",S=2e2},{R="TrainPower003",S=3e3},{R="TrainPower004",S=7.5e3},{R="TrainPower005",S=28e3},{R="TrainPower006",S=76e3}},["World002"]={{R="TrainPower008",S=1},{R="TrainPower009",S=363e3},{R="TrainPower010",S=820e3},{R="TrainPower011",S=1.99e6},{R="TrainPower012",S=3.98e6},{R="TrainPower013",S=9.1e6}},["World003"]={{R="TrainPower015",S=1},{R="TrainPower016",S=18.6e6},{R="TrainPower017",S=39e6},{R="TrainPower018",S=84.3e6},{R="TrainPower019",S=178e6},{R="TrainPower020",S=564e6}},["World004"]={{R="TrainPower022",S=1},{R="TrainPower023",S=1.1e9},{R="TrainPower024",S=1.91e9},{R="TrainPower025",S=3.66e9},{R="TrainPower026",S=7.21e9},{R="TrainPower027",S=14.7e9}},
    ["World005"]={{R="TrainPower029",S=1},{R="TrainPower030",S=58.5e9},{R="TrainPower031",S=99.7e9},{R="TrainPower032",S=136e9},{R="TrainPower033",S=255e9},{R="TrainPower034",S=616e9}},["World006"]={{R="TrainPower036",S=1},{R="TrainPower037",S=959.6e9},{R="TrainPower038",S=1.55e12},{R="TrainPower039",S=2.58e12},{R="TrainPower040",S=3.87e12},{R="TrainPower041",S=6.94e12}},["World007"]={{R="TrainPower043",S=1},{R="TrainPower044",S=14.61e12},{R="TrainPower045",S=25.41e12},{R="TrainPower046",S=41.94e12},{R="TrainPower047",S=65.22e12},{R="TrainPower048",S=121.47e12}},["World008"]={{R="TrainPower050",S=1},{R="TrainPower051",S=258.29e12},{R="TrainPower052",S=392.93e12},{R="TrainPower053",S=687.95e12},{R="TrainPower054",S=1.38e15},{R="TrainPower055",S=2.65e15}},
    ["World009"]={{R="TrainPower057",S=1},{R="TrainPower058",S=6.11e15},{R="TrainPower059",S=9.32e15},{R="TrainPower060",S=20.88e15},{R="TrainPower061",S=41.92e15},{R="TrainPower062",S=73.73e15}},["World010"]={{R="TrainPower064",S=392.93e12},{R="TrainPower065",S=10e15},{R="TrainPower066",S=20e15},{R="TrainPower067",S=30e15},{R="TrainPower068",S=50e15},{R="TrainPower069",S=100e15}},["World011"]={{R="TrainPower071",S=100e15},{R="TrainPower072",S=500e15},{R="TrainPower073",S=1e18},{R="TrainPower074",S=10e18},{R="TrainPower075",S=25e18},{R="TrainPower076",S=500e18}},["World012"]={{R="TrainPower078",S=100e15},{R="TrainPower079",S=500e15},{R="TrainPower080",S=1e18},{R="TrainPower081",S=10e18},{R="TrainPower082",S=25e18},{R="TrainPower083",S=500e18}},
    ["World013"]={{R="TrainPower085",S=500e18},{R="TrainPower086",S=1e21},{R="TrainPower087",S=2e21},{R="TrainPower088",S=3e21},{R="TrainPower089",S=4e21},{R="TrainPower090",S=5e21}},["World014"]={{R="TrainPower092",S=10e21},{R="TrainPower093",S=15e21},{R="TrainPower094",S=20e21},{R="TrainPower095",S=30e21},{R="TrainPower096",S=40e21},{R="TrainPower097",S=50e21}},["World015"]={{R="TrainPower099",S=70e21},{R="TrainPower100",S=80e21},{R="TrainPower101",S=90e21},{R="TrainPower102",S=100e21},{R="TrainPower103",S=150e21},{R="TrainPower104",S=200e21}},["World016"]={{R="TrainPower106",S=150e21},{R="TrainPower107",S=200e21},{R="TrainPower108",S=251e21},{R="TrainPower109",S=252e21},{R="TrainPower110",S=253e21}}
};
local ED = {
    {ID="Draw001",Req=5},{ID="Draw002",Req=25},{ID="Draw003",Req=150},{ID="Draw004",Req=450},{ID="Draw005",Req=4e3},{ID="Draw006",Req=10e3},{ID="Draw007",Req=30e3},{ID="Draw008",Req=150e3},{ID="Draw009",Req=1.6e6},{ID="Draw010",Req=3.5e6},{ID="Draw011",Req=8e6},{ID="Draw012",Req=40e6},{ID="Draw013",Req=450e6},{ID="Draw014",Req=1e9},{ID="Draw015",Req=2e9},{ID="Draw016",Req=10e9},{ID="Draw017",Req=150e9},{ID="Draw018",Req=300e9},{ID="Draw019",Req=600e9},{ID="Draw020",Req=3e12},{ID="Draw021",Req=30e12},{ID="Draw022",Req=500e12},{ID="Draw023",Req=15e15},{ID="Draw024",Req=300e15},{ID="Draw025",Req=4.5e18},{ID="Draw026",Req=85e18},{ID="Draw027",Req=1e21},{ID="Draw028",Req=25e21},{ID="Draw029",Req=666e21},{ID="Draw030",Req=5e24},{ID="Draw031",Req=15e24},{ID="Draw032",Req=250e24},{ID="Draw033",Req=450e24},{ID="Draw034",Req=650e24},{ID="Draw035",Req=750e24},{ID="Draw036",Req=0.99e27},{ID="Draw037",Req=1.49e27},{ID="Draw038",Req=1.99e27},{ID="Draw039",Req=99.99e27},{ID="Draw040",Req=1e30},{ID="Draw041",Req=1.75e30},{ID="Draw042",Req=2.5e30}
};
local W_N_ID = {["Castle"]="World001",["Mushroom Forest"]="World002",["Desert Pyramid"]="World003",["Snow Land"]="World004",["Underwater"]="World005",["Alien Desert"]="World006",["Candy"]="World007",["Energy Factory"]="World008",["Altar"]="World009",["Demon King"]="World010",["Heavenly Gates"]="World011",["Halls of Valhalla"]="World012",["Voidfallen Kingdom"]="World013",["Realm of the Monkey King"]="World014",["The Fractal Fortress"]="World015",["The Timeless Cavern"]="World016"};
local O_W_N = {"Castle","Mushroom Forest","Desert Pyramid","Snow Land","Underwater","Alien Desert","Candy","Energy Factory","Altar","Demon King","Heavenly Gates","Halls of Valhalla","Voidfallen Kingdom","Realm of the Monkey King","The Fractal Fortress","The Timeless Cavern"};
local TL = {{Name="Castle",CFrame=CFrame.new(-355.025,108.44,-361.705,0,0,-1,0,1,0,1,0,0)},{Name="Mushroom Forest",CFrame=CFrame.new(-416.749,189.614,-2692.51,1,0,0,0,1,0,0,0,1)},{Name="Desert Pyramid",CFrame=CFrame.new(-390.099,14.414,-5540.87,1,0,0,0,1,0,0,0,1)},{Name="Snow Land",CFrame=CFrame.new(-400,219.814,-7700.34,1,0,0,0,1,0,0,0,1)},{Name="Underwater",CFrame=CFrame.new(-279.721,45.793,-10495.7,1,0,0,0,1,0,0,0,1)},{Name="Alien Desert",CFrame=CFrame.new(-369.141,106.533,-12073.5,1,0,0,0,1,0,0,0,1)},{Name="Candy",CFrame=CFrame.new(-364.411,107.393,-13334.5,1,0,0,0,1,0,0,0,1)},{Name="Energy Factory",CFrame=CFrame.new(-410.601,-20.657,-15130.6,1,0,0,0,1,0,0,0,1)},{Name="Altar",CFrame=CFrame.new(-519.031,-239.127,-17261.9,1,0,0,0,1,0,0,0,1)},{Name="Demon King",CFrame=CFrame.new(-519.031,-239.127,-19761.9,1,0,0,0,1,0,0,0,1)},{Name="Heavenly Gates",CFrame=CFrame.new(-763.321,-239.127,-21523.4,1,0,0,0,1,0,0,0,1)},{Name="Halls of Valhalla",CFrame=CFrame.new(-763.321,-239.127,-24418,1,0,0,0,1,0,0,0,1)},{Name="Voidfallen Kingdom",CFrame=CFrame.new(-763.321,-239.127,-27791.3,1,0,0,0,1,0,0,0,1)},{Name="Realm of the Monkey King",CFrame=CFrame.new(-763.321,-239.127,-29846.2,1,0,0,0,1,0,0,0,1)},{Name="The Fractal Fortress",CFrame=CFrame.new(-763.321,-239.127,-32819.3,1,0,0,0,1,0,0,0,1)},{Name="The Timeless Cavern",CFrame=CFrame.new(-416.749,189.614,-36787.8,1,0,0,0,1,0,0,0,1)}};

-- Helper Functions
local function pN(s) s=tostring(s):gsub("Strength",""):gsub(" ",""):gsub(",",""):lower(); local x=s:match("([a-z]+)$"); if x and nS[x]then local n=s:sub(1,#s-#x); return tonumber(n)*nS[x]end; return tonumber(s)or 0; end;

-- Rayfield UI Initialization
local RF = loadstring(game:HttpGet('https://sirius.menu/rayfield'))();
local W = RF:CreateWindow({Name="Fighting Sword",LoadingTitle="Fighting Sword Interface",LoadingSubtitle="by Nexus-Lua",Theme="Amethyst",ToggleUIKeybind=Enum.KeyCode.LeftControl,ConfigurationSaving={Enabled=true,FolderName="FightingSwordConfig",FileName="FightingSword"}});
local FT,PT,MT,ST,UT,MiscT,ProT,SetT=W:CreateTab("Farm","swords"),W:CreateTab("Pet","dog"),W:CreateTab("Map","map"),W:CreateTab("Shop","shopping-cart"),W:CreateTab("Upgrade","arrow-up-circle"),W:CreateTab("Misc","sliders-horizontal"),W:CreateTab("Profile","user"),W:CreateTab("Settings","settings");

-- Farm Tab
FT:CreateSection("Auto Train Power");
local WSD = FT:CreateDropdown({Name="Select World",Options=O_W_N,CurrentOption={O_W_N[1]},Flag="AutoTrainWorld",Callback=function()end});
local ATT = FT:CreateToggle({Name="Auto Train Power",CurrentValue=false,Flag="AutoTrainToggle",Callback=function(V)
    isAT=V;
    if isAT then
        local c=lp.Character or lp.CharacterAdded:Wait(); local pT=c:WaitForChild("PlayerTag",5); local sO=pT and pT:WaitForChild("Strength",5);
        if not sO then RF:Notify({Title="Error",Content="Strength object not found!",Duration=8,Image="alert-octagon"});isAT=false;ATT:Set(false);return end;
        local sWN=WSD.CurrentOption[1]; local wID=W_N_ID[sWN]; local a={[1]=wID}; rs.Events.World.Rf_TeleportToWorld:InvokeServer(unpack(a));
        RF:Notify({Title="Auto-Train",Content="Teleported to "..sWN..". Starting...",Duration=4,Image="play"})
    else RF:Notify({Title="Auto-Train",Content="Stopped.",Duration=4,Image="hand"}) end
end});
task.spawn(function() while true do if isAT then local c=lp.Character; if c then local pT=c:FindFirstChild("PlayerTag"); if pT then local sS=pT:FindFirstChild("Strength"); if sS then
    local cS=pN(sS.Text); local sWID=W_N_ID[WSD.CurrentOption[1]]; local wTA=TD[sWID]; local tR_arg=nil;
    for i=#wTA,1,-1 do local a=wTA[i]; if cS>=a.S then tR_arg=a.R; break end end;
    if tR_arg then
        local args = {[1] = tR_arg}; -- Corrected data format
        rs.Events.Game.Re_TrainPower:FireServer(unpack(args));
    end
end end end; task.wait(0.1) else task.wait(1) end end end);

-- Pet Tab
PT:CreateSection("Auto Hatch & Delete");
local function gEN() local n={}; for i,d in ipairs(ED)do local r=d.Req; local s; if r>=1e30 then s=string.format("%.2fno",r/1e30)elseif r>=1e27 then s=string.format("%.2foc",r/1e27)elseif r>=1e24 then s=string.format("%.2fsp",r/1e24)elseif r>=1e21 then s=string.format("%.2fsx",r/1e21)elseif r>=1e18 then s=string.format("%.2fqi",r/1e18)elseif r>=1e15 then s=string.format("%.2fqa",r/1e15)elseif r>=1e12 then s=string.format("%.2ft",r/1e12)elseif r>=1e9 then s=string.format("%.2fb",r/1e9)elseif r>=1e6 then s=string.format("%.2fm",r/1e6)elseif r>=1e3 then s=string.format("%.2fk",r/1e3)else s=tostring(r)end; table.insert(n,"Egg "..i.." ("..s:gsub("%.00","").." Wins)")end; return n; end;
local EID = PT:CreateDropdown({Name="Select Egg",Options=gEN(),CurrentOption={gEN()[1]},Flag="AutoHatchEgg",Callback=function()end});
local AutoDeleteDropdown = PT:CreateDropdown({Name="Auto-Delete Pet",Options={"None","Pet 1","Pet 2","Pet 3","Pet 4"},CurrentOption={"None"},MultipleOptions=true,Flag="AutoDeletePets",Callback=function()end});
PT:CreateToggle({Name="Auto Hatch",CurrentValue=false,Flag="AutoHatchToggle",Callback=function(V) isAH=V; RF:Notify({Title="Auto-Hatch",Content=V and"Started."or"Stopped.",Duration=3,Image=V and"play"or"hand"})end});

task.spawn(function() while true do if isAH then local l=lp:FindFirstChild("leaderstats"); local wS=l and l:FindFirstChild("\240\159\143\134Wins"); if wS then
    local cW=wS.Value; local sEN=EID.CurrentOption[1]; local sEI=tonumber(sEN:match("%d+")); local sED=ED[sEI];
    if sED and cW>=sED.Req then
        local deleteList = {};
        local startPetId = (sEI - 1) * 4 + 1;
        for _, nickname in ipairs(AutoDeleteDropdown.CurrentOption) do
            local petIndex = tonumber(nickname:match("%d+"));
            if petIndex then
                local actualId = string.format("Pet%03d", startPetId + petIndex - 1);
                table.insert(deleteList, actualId);
            end
        end
        rs.Events.Pets.Re_Hatch:FireServer("Hatch", sED.ID, deleteList);
    end
end; task.wait(0.1) else task.wait(1) end end end);

-- Map Tab
local function gLN() local n={}; for i,d in ipairs(TL) do table.insert(n,d.Name) end; return n; end;
MT:CreateSection("Teleport");
local TDD = MT:CreateDropdown({Name="Select Destination",Options=gLN(),CurrentOption={gLN()[1]},Flag="TeleportDestination",Callback=function(O)end});
MT:CreateButton({Name="Teleport",Callback=function() local c=lp.Character; local rP=c and c:FindFirstChild("HumanoidRootPart"); if not rP then RF:Notify({Title="Error",Content="Cannot find char.",Duration=5,Image="alert-triangle"}); return end; local sLN=TDD.CurrentOption[1]; local tCF; for i,d in ipairs(TL) do if d.Name==sLN then tCF=d.CFrame; break end end; if tCF then rP.CFrame=tCF; RF:Notify({Title="Teleport",Content="Teleported to "..sLN,Duration=5,Image="send"}) else RF:Notify({Title="Error",Content="Invalid location",Duration=5,Image="alert-triangle"}) end end});

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
