

local SCRIPT_DATA = {
    {
        ClassName = "LocalScript",
        Closure = function()
            if not game:IsLoaded() then
                game.Loaded:Wait()
            end
            if Fluent then
                Fluent.Destroy()
            end

            local Library = require(script.Library)
            Library.Debug = true

            local Libraries = Library.Libraries
            local Services = Library.Services
            local Variables = Library.Variables
            local Generic = Libraries.Generic
            local Special = Libraries.Special
            local RBXUtil = Libraries.RBXUtil
            local Tree = RBXUtil.Tree
            local Promise = RBXUtil.Promise
            local Signal = RBXUtil.Signal
            local Trove = RBXUtil.Trove
            local TableUtil = RBXUtil.TableUtil

            local GameModules = Special.GameModules.Get()
            local Interface = Generic.Interface.Get()
            local Threading = Generic.Threading
            local Functions = Library.Functions
            local SpecialFunctions = Functions.Special
            local GenericFunctions = Functions.Generic
            local LRM_Variables = Variables.LRM_Variables

            local Players = Services.Players
            local RunService = Services.RunService
            local Workspace = Services.Workspace
            local ReplicatedStorage = Services.ReplicatedStorage
            local UserInputService = Services.UserInputService
            local GuiService = Services.GuiService
            local CoreGui = Services.CoreGui
            local CollectionService = Services.CollectionService

            local LocalPlayer = Players.LocalPlayer
            local FindFirstChild = game.FindFirstChild
            local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
            local FindFirstAncestor = game.FindFirstAncestor
            local IsA = game.IsA

            local Knit = GameModules.Knit
            local ClickService = Knit.GetService('ClickService')
            local RebirthService = Knit.GetService('RebirthService')
            local EggService = Knit.GetService('EggService')
            local FarmService = Knit.GetService('FarmService')
            local UpgradeService = Knit.GetService('UpgradeService')
            local RewardService = Knit.GetService('RewardService')
            local PetService = Knit.GetService('PetService')
            local IndexService = Knit.GetService('IndexService')
            local PrestigeService = Knit.GetService('PrestigeService')
            local InventoryService = Knit.GetService('InventoryService')

            local HatchingController = Knit.GetController('HatchingController')
            local FarmController = Knit.GetController('FarmController')
            local DataController = Knit.GetController('DataController')
            DataController:waitForData()
            local Replica = DataController.replica

            local ModuleFunctions = GameModules.Functions
            local ModuleVariables = GameModules.Variables

            setthreadidentity(8)
            setthreadcontext(8)

            local ScriptCache = Library.Cache.ScriptCache
            ScriptCache.InitTime = DateTime.now().UnixTimestamp

            local MainThread = Threading.new('MainThread')
            local FluentUI = Interface.Fluent
            local SaveManager = Interface.SaveManager
            local ThemeManager = Interface.ThemeManager

            getgenv().Fluent = FluentUI

            local Window = FluentUI:CreateWindow({
                Title = "strelizia.cc",
                SubTitle = "v" .. LRM_Variables.LRM_ScriptVersion,
                TabWidth = 120,
                Size = UDim2.fromOffset(600, 480),
                Resize = true,
                MinSize = Vector2.new(430, 350),
                Acrylic = false,
                Theme = "Darker",
                MinimizeKey = Enum.KeyCode.RightControl
            })

            local Tabs = {
                Home = Window:CreateTab({ Title = "Home", Icon = "house" }),
                Farming = Window:CreateTab({ Title = "Farming", Icon = "egg" }),
                Crops = Window:CreateTab({ Title = "Crops", Icon = "wheat" }),
                Misc = Window:CreateTab({ Title = "Others", Icon = "circle-ellipsis" }),
                Settings = Window:CreateTab({ Title = "Settings", Icon = "settings" }),
            }

            local Sections = {
                Home_Information = Tabs.Home:AddSection("↳ Information"),
                Home_Credits = Tabs.Home:AddSection("↳ Credits"),
                Farming_Clicking = Tabs.Farming:AddSection("↳ Clicking"),
                Farming_Rebirth = Tabs.Farming:AddSection("↳ Rebirthing"),
                Farming_Hatching = Tabs.Farming:AddSection("↳ Hatching"),
                Farming_Upgrades = Tabs.Farming:AddSection("↳ Upgrades"),
                Crops_Claim = Tabs.Crops:AddSection("↳ Auto Claim"),
                Crops_Upgrade = Tabs.Crops:AddSection("↳ Auto Upgrade"),
                Other_Chests = Tabs.Misc:AddSection("↳ Chests"),
                Other_Items = Tabs.Misc:AddSection("↳ Items"),
                Other_Combining = Tabs.Misc:AddSection("↳ Combining"),
                Other_Misc = Tabs.Misc:AddSection("↳ Misc")
            }

            do -- Home Tab
                local UptimeParagraph = Sections.Home_Information:CreateParagraph("ClientUptimeParagraph", {
                    Title = "Client Uptime: nil",
                    TitleAlignment = Enum.TextXAlignment.Center,
                })
                Threading.new("ClientUptimeParagraph", function(thread)
                    while FluentUI.Loaded and task.wait(1) do
                        UptimeParagraph.Instance.TitleLabel.Text = string.format("Script Uptime: %s", GenericFunctions.FormatHms(GenericFunctions.GetUptime()))
                    end
                end):Start()

                local LuaHeapParagraph = Sections.Home_Information:CreateParagraph("LuaHeapParagraph", {
                    Title = "Lua Heap (Megabytes): nil",
                    TitleAlignment = Enum.TextXAlignment.Center,
                })
                Threading.new("LuaHeapParagraph", function(thread)
                    while FluentUI.Loaded and task.wait(1) do
                        LuaHeapParagraph.Instance.TitleLabel.Text = string.format('Lua Heap: %sMB', tostring(GenericFunctions.CommaNumber(math.ceil(gcinfo() / 1000))))
                    end
                end):Start()

                Sections.Home_Information:CreateButton({
                    Title = "Join Discord",
                    Description = "prompts discord invite if the user is on pc, copies to clipboard otherwise",
                    Callback = function()
                        GenericFunctions.PromptDiscordJoin('Vf4Wu3Cft7', true)
                        FluentUI:Notify({ Title = "Discord Prompted/Copied", Content = "discord invite has been prompted/copied to your clipboard!", Duration = 2 })
                    end
                })

                Sections.Home_Credits:CreateParagraph("Credits", {
                    Title = "vma, kalas, pryxo (felix was moral support!!)",
                    TitleAlignment = Enum.TextXAlignment.Center,
                })
            end

            do -- Farming Tab
                local AutoClickToggle = Sections.Farming_Clicking:Toggle("AutoClickToggle", { Title = "Auto Click", Default = false, Description = "automatically clicks for you" })
                AutoClickToggle:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoClickToggle'
                        return
                    end
                    Threading.new('AutoClickToggle', function(thread)
                        while FluentUI.Loaded and task.wait() do
                            ClickService.click:Fire()
                        end
                    end):Start()
                end)

                local suffix_promisify = Promise.promisify(ModuleFunctions.suffixes)
                local function get_rebirth_options()
                    local unlocked_options = SpecialFunctions.GetUnlockedRebirthOptions()
                    local options = {}
                    for i, option in unlocked_options do
                        local success, formatted_value = suffix_promisify(option):await()
                        table.insert(options, { Name = string.format('%s Rebirths', tostring(formatted_value)), Value = i })
                    end
                    table.insert(options, { Name = 'Best Option Unlocked', Value = math.huge })
                    return options
                end

                local rebirth_options = get_rebirth_options()
                local RebirthsDropdown = Sections.Farming_Rebirth:Dropdown("RebirthsDropdown", {
                    Title = "Rebirth Option",
                    Description = "determines which rebirth option will be bought",
                    Values = rebirth_options,
                    Displayer = function(option)
                        return option.Name
                    end,
                    Multi = false,
                })

                local update_rebirth_dropdown = Promise.promisify(function(options)
                    RebirthsDropdown:SetValues(options)
                end)
                MainThread:Add(Replica:OnSet({'upgrades'}, function()
                    setthreadcontext(8)
                    setthreadidentity(8)
                    update_rebirth_dropdown(get_rebirth_options()):catch(warn):await()
                end), 'Disconnect')

                local AutoRebirthToggle = Sections.Farming_Rebirth:Toggle("AutoRebirthToggle", { Title = "Auto Rebirth", Default = false, Description = "automatically rebirths for you based on the preference above" })
                AutoRebirthToggle:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoRebirthToggle'
                        return
                    end
                    Threading.new('AutoRebirthToggle', function(thread)
                        while FluentUI.Loaded and task.wait(0.016666666666666666) do
                            local selected_option = RebirthsDropdown.Value
                            if not selected_option then continue end
                            local rebirth_value = (selected_option.Value == math.huge and SpecialFunctions.GetBestRebirthOption()) or selected_option.Value
                            if SpecialFunctions.CanAffordRebirth(rebirth_value) then
                                RebirthService:rebirth(rebirth_value)
                            end
                        end
                    end):Start()
                end)

                local egg_list = {}
                for name, data in GameModules.Eggs do
                    table.insert(egg_list, { Name = string.format('%s Egg | Price: %s', tostring(name), tostring(ModuleFunctions.suffixes(data.cost))), Value = name, Cost = data.cost or 0 })
                end
                table.sort(egg_list, function(a, b)
                    return a.Cost > b.Cost
                end)

                local EggDropdown = Sections.Farming_Hatching:Dropdown("EggDropdown", {
                    Title = "Selected Egg",
                    Description = "determines which egg will be hatched",
                    Values = egg_list,
                    Searchable = true,
                    AutoDeselect = true,
                    Displayer = function(egg)
                        return egg.Name
                    end,
                    Multi = false,
                })

                GenericFunctions.AssertFunctions({'hookfunction'}, function()
                    local HideHatchAnimation = Sections.Farming_Hatching:Toggle("HideHatchAnimation", { Title = "Hide Hatch Animation", Default = false, Description = "prevents the eggs from showing up on screen" })
                    local original_egg_animation
                    original_egg_animation = hookfunction(HatchingController.eggAnimation, function(controller, ...)
                        if HideHatchAnimation.Value then
                            return nil
                        end
                        return original_egg_animation(controller, ...)
                    end)
                    MainThread:Add(function()
                        hookfunction(HatchingController.eggAnimation, original_egg_animation)
                    end)
                end, function(missing_functions)
                    Sections.Farming_Hatching:CreateParagraph("MissingFunctionAssertion", {
                        Title = "Unsupported Feature: Hide Hatch Animation",
                        TitleAlignment = Enum.TextXAlignment.Center,
                        Content = string.format([[This feature cannot be used because your executor doesn't support following functions: %s]], tostring(table.concat(missing_functions, ', '))),
                        ContentAlignment = Enum.TextXAlignment.Center
                    })
                end)

                local AutoOpenEggs = Sections.Farming_Hatching:Toggle("AutoOpenEggs", { Title = "Auto Open Eggs", Default = false, Description = "automatically opens eggs based on the configuration above" })
                AutoOpenEggs:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoOpenEggs'
                        return
                    end
                    Threading.new('AutoOpenEggs', function(thread)
                        while FluentUI.Loaded and task.wait(0.016666666666666666) do
                            local selected_egg = EggDropdown.Value
                            if not selected_egg then continue end
                            local required_map = GameModules.Eggs[selected_egg.Value].requiredMap
                            if required_map and (not DataController.data.maps[required_map]) then continue end
                            local max_affordable = GameModules.Util.eggUtils.getMaxAffordable(LocalPlayer, DataController.data, selected_egg.Value)
                            if GameModules.Util.eggUtils.hasEnoughToOpen(DataController.data, selected_egg.Value, max_affordable) then
                                EggService.openEgg:Fire(selected_egg.Value, max_affordable)
                                task.wait(4.15 / GameModules.Values.hatchSpeed(LocalPlayer, DataController.data))
                            end
                        end
                    end):Start()
                end)

                local upgrade_options = TableUtil.Map(GameModules.Upgrades, function(upgrade_data, upgrade_name, mapped_table)
                    table.insert(mapped_table, { Name = ModuleFunctions.toPascal(upgrade_name), Value = upgrade_name })
                end)
                local UpgradesDropdown = Sections.Farming_Upgrades:Dropdown("UpgradesDropdown", {
                    Title = "Selected Upgrades",
                    Description = "determines which upgrades will be bought",
                    Values = upgrade_options,
                    Displayer = function(upgrade)
                        return upgrade.Name
                    end,
                    Multi = true,
                    Default = {}
                })

                local AutoUpgradeToggle = Sections.Farming_Upgrades:Toggle("AutoBuyUpgrades", { Title = "Auto Buy Upgrades", Default = false, Description = "automatically buys upgrades when possible" })
                AutoUpgradeToggle:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoUpgradeToggle'
                        return
                    end
                    Threading.new('AutoUpgradeToggle', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_upgrades = UpgradesDropdown.Value
                            if TableUtil.GetDictionarySize(selected_upgrades) < 1 then continue end

                            for _, upgrade_info in selected_upgrades do
                                local upgrade_name, upgrade_value = upgrade_info.Name, upgrade_info.Value
                                local upgrade_data = GameModules.Upgrades[upgrade_value]

                                if upgrade_data.requiredMap and DataController.data.maps[upgrade_data.requiredMap] == nil then continue end

                                local current_level = (DataController.data.upgrades[upgrade_value] or 0) + 1
                                local next_upgrade_cost = upgrade_data.upgrades[current_level]

                                if not next_upgrade_cost then continue end
                                if next_upgrade_cost.cost > DataController.data.gems then continue end

                                if UpgradeService:upgrade(upgrade_value) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | bought upgrade", Content = string.format('upgrade %s is now level %s', tostring(upgrade_name), tostring(current_level)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)
            end

            do -- Crops Tab
                local farm_options = TableUtil.Map(GameModules.Farms, function(farm_data, farm_name, mapped_table)
                    table.insert(mapped_table, { Name = ModuleFunctions.toPascal(farm_name), Value = farm_name, IsAFarm = not farm_data.isNotFarm })
                end)

                local collectable_farms = TableUtil.Map(farm_options, function(farm_option, _, mapped_table)
                    if not farm_option.IsAFarm then return end
                    table.insert(mapped_table, farm_option)
                end)

                local SelectedClaimFarms = Sections.Crops_Claim:Dropdown("SelectedClaimFarms", {
                    Title = "Selected Crops",
                    Description = "determines which crops will be auto collected",
                    Values = collectable_farms,
                    Multi = true,
                    Displayer = function(farm)
                        return farm.Name
                    end,
                    Default = {}
                })

                local AutoClaimCrops = Sections.Crops_Claim:Toggle("AutoClaimCrops", { Title = "Auto Claim Crops", Default = false, Description = "automatically claim available crops" })
                AutoClaimCrops:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoClaimCrops'
                        return
                    end
                    Threading.new('AutoClaimCrops', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_farms = SelectedClaimFarms.Value
                            if TableUtil.GetDictionarySize(selected_farms) == 0 then continue end

                            local player_farms = DataController.data.farms
                            for _, farm_info in selected_farms do
                                local farm_value = farm_info.Value
                                local farm_name = farm_info.Name
                                if not player_farms[farm_value] then continue end
                                if FarmController:getTimeLeft(farm_value) > 0 then continue end

                                if FarmService:claim(farm_value) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed crops", Content = string.format('%s has been claimed!', tostring(farm_name)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)

                local SelectedUpgradeCrops = Sections.Crops_Upgrade:Dropdown("SelectedUpgradeCrops", {
                    Title = "Selected Upgrades",
                    Description = "determines which crops will be upgraded",
                    Values = farm_options,
                    Multi = true,
                    Displayer = function(crop)
                        return crop.Name
                    end,
                    Default = {}
                })

                local AutoUpgradeCrops = Sections.Crops_Upgrade:Toggle("AutoUpgradeCrops", { Title = "Auto Upgrade Crops", Default = false, Description = "automatically upgrades selected crops" })
                AutoUpgradeCrops:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoUpgradeCrops'
                        return
                    end
                    Threading.new('AutoUpgradeCrops', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_crops = SelectedUpgradeCrops.Value
                            if TableUtil.GetDictionarySize(selected_crops) == 0 then continue end

                            for _, crop_info in selected_crops do
                                local crop_value = crop_info.Value
                                local crop_name = crop_info.Name
                                local player_crop_data = DataController.data.farms[crop_value]

                                if player_crop_data == nil then
                                    local farm_data = GameModules.Farms[crop_value]
                                    local buy_price = farm_data.price or math.huge
                                    if DataController.data.gems <= buy_price then continue end
                                    if FarmService:buy(crop_value) == "success" then
                                        FluentUI:Notify({ Title = "strelizia.cc | bought crop farm", Content = string.format('%s has been bought!', tostring(crop_name)), Duration = 1.5 })
                                        task.wait(0.2)
                                    end
                                    continue
                                end

                                local next_stage = (player_crop_data.stage or 0) + 1
                                local upgrades = GameModules.Farms[crop_value].upgrades
                                if not upgrades then continue end
                                local next_upgrade_data = upgrades[next_stage]

                                if not next_upgrade_data then continue end
                                local upgrade_price = next_upgrade_data.price or math.huge
                                if DataController.data.gems <= upgrade_price then continue end

                                if FarmService:upgrade(crop_value) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | upgraded crop farm", Content = string.format('%s has been upgraded to stage %s!', tostring(crop_name), tostring(next_stage)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)
            end

            do -- Others Tab
                local AutoClaimChests = Sections.Other_Chests:Toggle("AutoClaimChests", { Title = "Auto Claim Chests", Default = false, Description = "automatically claims chests" })
                AutoClaimChests:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoClaimChests'
                        return
                    end
                    Threading.new('AutoClaimChests', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            for chest_name, chest_data in GameModules.Chests do
                                if chest_data.group and select(2, pcall(LocalPlayer.IsInGroup, LocalPlayer, game.CreatorId)) ~= true then
                                    print'Not in group'
                                    continue
                                end
                                local last_claimed_time = DataController.data.chests[chest_name] or 0
                                if os.time() < last_claimed_time + chest_data.cooldown then continue end
                                if RewardService:claimChest(chest_name) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed chest", Content = string.format('%s chest has been opened!', tostring(chest_name)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)

                Sections.Other_Chests:Button({
                    Title = "Claim Minichests",
                    Description = "claims all unlocked chests (areawise)",
                    Callback = function()
                        for _, mini_chest in CollectionService:GetTagged'MiniChest' do
                            local prompt = FindFirstChildWhichIsA(mini_chest, 'ProximityPrompt', true)
                            if not prompt then continue end
                            fireproximityprompt(prompt, 0)
                            fireproximityprompt(prompt, 1)
                        end
                    end
                })

                local potion_list = {}
                for name, data in GameModules.Potions do
                    table.insert(potion_list, { Name = data.name, Layout = data.layoutOrder, Value = name })
                end
                table.sort(potion_list, function(a, b)
                    return a.Layout > b.Layout
                end)

                local PotionsDropdown = Sections.Other_Items:Dropdown("PotionsDropdown", {
                    Title = "Select Potions",
                    Description = "determines which potions will be used",
                    Values = potion_list,
                    Multi = true,
                    Displayer = function(potion)
                        return potion.Name
                    end,
                    Default = {}
                })

                local AutoUsePotions = Sections.Other_Items:Toggle("AutoUsePotions", { Title = "Auto Use Potions", Default = false, Description = "automatically uses potions (only after current one expires)" })
                AutoUsePotions:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoUsePotions'
                        return
                    end
                    Threading.new('AutoUsePotions', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_potions = PotionsDropdown.Value
                            if TableUtil.GetDictionarySize(selected_potions) == 0 then continue end

                            for _, potion_info in selected_potions do
                                local potion_value = potion_info.Value
                                if DataController.data.activeBoosts[potion_value] then continue end

                                local item_id, item_data = SpecialFunctions.GetItemByName('potion', potion_value)
                                if not item_id or not item_data.am or item_data.am < 1 then continue end

                                InventoryService:useItem(item_id, { use = 1 })
                            end
                        end
                    end):Start()
                end)

                local box_list = {}
                for name, data in GameModules.Boxes do
                    table.insert(box_list, { Name = data.name, Layout = data.layoutOrder, Value = name })
                end
                table.sort(box_list, function(a, b)
                    return a.Layout > b.Layout
                end)

                local BoxesDropdown = Sections.Other_Items:Dropdown("BoxesDropdown", {
                    Title = "Select Boxes",
                    Description = "determines which boxes will be opened",
                    Values = box_list,
                    Multi = true,
                    Displayer = function(box)
                        return box.Name
                    end,
                    Default = {}
                })

                local AutoOpenBoxes = Sections.Other_Items:Toggle("AutoOpenBoxes", { Title = "Auto Open Boxes", Default = false, Description = "automatically opens boxes if any are present in the inventory" })
                AutoOpenBoxes:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoOpenBoxes'
                        return
                    end
                    Threading.new('AutoOpenBoxes', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_boxes = BoxesDropdown.Value
                            if TableUtil.GetDictionarySize(selected_boxes) == 0 then continue end

                            for _, box_info in selected_boxes do
                                local box_value = box_info.Value
                                local item_id, item_data = SpecialFunctions.GetItemByName('box', box_value)
                                if not item_id or not item_data.am or item_data.am < 1 then continue end
                                InventoryService:useItem(item_id, { use = item_data.am })
                            end
                        end
                    end):Start()
                end)

                local tier_options = {}
                for tier_id, tier_data in GameModules.Tiers do
                    local next_tier_data = GameModules.Tiers[tier_id + 1]
                    if not next_tier_data then continue end
                    table.insert(tier_options, { Name = string.format('%s -> %s', tostring(tier_data.name), tostring(next_tier_data.name)), Value = tier_id, AttributeName = tier_data.attributeName })
                end

                local UpgradeTierDropdown = Sections.Other_Combining:Dropdown("UpgradeTierDropdown", {
                    Title = "Upgrade Tiers",
                    Description = "determines which tiers will be upgraded",
                    Values = tier_options,
                    Multi = true,
                    Displayer = function(tier)
                        return tier.Name
                    end,
                    Default = {}
                })

                local AutoUpgradeTiers = Sections.Other_Combining:Toggle("AutoUpgradePets", { Title = "Auto Upgrade Pets", Default = false, Description = "automatically upgrades pets tier based on the configuration above" })
                AutoUpgradeTiers:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoUpgradeTiers'
                        return
                    end
                    Threading.new('AutoUpgradeTiers', function(thread)
                        while FluentUI.Loaded and task.wait(0.5) do
                            local selected_tiers = UpgradeTierDropdown.Value
                            if TableUtil.GetDictionarySize(selected_tiers) == 0 then continue end

                            for _, tier_info in selected_tiers do
                                local tier_value = tier_info.Value
                                if (not GameModules.Tiers[tier_value + 1]) then continue end

                                local pets_by_tier = SpecialFunctions.GetPetsByTier(tier_value)
                                for _, pet_data in pets_by_tier do
                                    if pet_data:getLocked() then continue end
                                    if pet_data:getAmount() < 5 then continue end
                                    PetService:craft({ _ }, true)
                                end
                            end
                        end
                    end):Start()
                end)

                local AutoClaimRewards = Sections.Other_Misc:Toggle("AutoClaimRewards", { Title = "Auto Claim Rewards", Default = false, Description = "automatically claims rewards (Playtime, Daily, Achievements)" })
                AutoClaimRewards:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoClaimRewards'
                        return
                    end
                    Threading.new('AutoClaimRewards', function(thread)
                        while FluentUI.Loaded and task.wait(1) do
                            for reward_id, reward_data in GameModules.PlaytimeRewards do
                                if table.find(DataController.data.claimedPlaytimeRewards, reward_id) then continue end
                                if reward_data.required - DataController.data.sessionTime > 0 then continue end
                                if RewardService:claimPlaytimeReward(reward_id) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed playtime reward", Content = string.format('claimed playtime reward no%s', tostring(reward_id)), Duration = 1.5 })
                                end
                            end

                            if (DataController.data.dayReset - os.time() + 86400) <= 0 then
                                if RewardService:claimDailyReward() == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed daily reward", Content = "todays daily reward has been claimed", Duration = 1.5 })
                                end
                            end

                            for achievement_class, achievement_data in GameModules.Achievements do
                                local next_achievement_tier, next_achievement_info = SpecialFunctions.GetNextAchievementByClass(achievement_class)
                                if not next_achievement_tier then continue end
                                if next_achievement_info.amount > achievement_data.getValue(DataController.data) then continue end
                                if RewardService:claimAchievement(achievement_class) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed achievement", Content = string.format('claimed achievement %s (tier %s)', tostring(achievement_class), tostring(next_achievement_tier)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)

                local AutoClaimIndexRewards = Sections.Other_Misc:Toggle("AutoClaimIndexRewards", { Title = "Auto Claim Index Rewards", Default = false, Description = "automatically claims index rewards" })
                AutoClaimIndexRewards:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoClaimIndexRewards'
                        return
                    end
                    Threading.new('AutoClaimIndexRewards', function(thread)
                        while FluentUI.Loaded and task.wait(1) do
                            for reward_id, reward_data in GameModules.IndexRewards do
                                if table.find(DataController.data.claimedIndexRewards, reward_id) then continue end
                                if reward_data.required > GameModules.Util.indexUtils.countIndex(DataController.data, true) then continue end
                                if IndexService:claimIndexReward(reward_id) == "success" then
                                    FluentUI:Notify({ Title = "strelizia.cc | claimed index reward", Content = string.format('claimed index reawrd no%s', tostring(reward_id)), Duration = 1.5 })
                                end
                            end
                        end
                    end):Start()
                end)

                local AutoPrestigeToggle = Sections.Other_Misc:Toggle("AutoPrestigeToggle", { Title = "Auto Prestige", Default = false, Description = "automatically prestiges when possible" })
                AutoPrestigeToggle:OnChanged(function(enabled)
                    if not enabled then
                        Threading.TerminateByIndex'AutoPrestigeToggle'
                        return
                    end
                    Threading.new('AutoPrestigeToggle', function(thread)
                        while FluentUI.Loaded and task.wait(1) do
                            local current_prestige_level = (DataController.data.prestige or 0) + 1
                            local next_prestige_data = GameModules.Prestiges[current_prestige_level]
                            if not next_prestige_data then continue end
                            if next_prestige_data.required > DataController.data.prestigeXp then continue end
                            if PrestigeService:claim() == "success" then
                                FluentUI:Notify({ Title = "strelizia.cc | prestiged", Content = string.format('successfully prestiged to prestige %s', tostring(current_prestige_level)), Duration = 1.5 })
                            end
                        end
                    end):Start()
                end)
            end

            do -- Settings & Initialization
                SaveManager:SetLibrary(FluentUI)
                ThemeManager:SetLibrary(FluentUI)
                SaveManager:IgnoreThemeSettings()
                SaveManager:SetIgnoreIndexes{}
                ThemeManager:SetFolder("StreliziaScriptHub")
                SaveManager:SetFolder("StreliziaScriptHub/" .. game.PlaceId)
                ThemeManager:BuildInterfaceSection(Tabs.Settings)
                SaveManager:BuildConfigSection(Tabs.Settings)

                Window:SelectTab(1)
                FluentUI:Notify({ Title = "strelizia.cc", Content = "script loaded, enjoy <3", Duration = 5 })
                FluentUI:ToggleTransparency(false)
                SaveManager:LoadAutoloadConfig()

                FluentUI.OnUnload:Connect(function()
                    Threading.TerminateAll()
                    local ui_toggle = FindFirstChild(CoreGui, 'UIToggle')
                    if ui_toggle then
                        ui_toggle:Destroy()
                    end
                end)

                do -- Discord Join Prompt
                    Threading.new('DiscordJoinPrompt', function(thread_data)
                        local delay_time = 120
                        while true do
                            local success, file_exists = pcall(isfile, 'StreliziaJoinedDiscord')
                            if success and file_exists == true then
                                break
                            end
                            task.wait(delay_time)
                            delay_time = delay_time * 3
                            local dialog = Window:Dialog({
                                Title = "Discord",
                                Content = "Hey! Want to join our Discord for tons of giveaways, stay updated on script status, and hang out with the community?",
                                Buttons = {
                                    { Title = "Sure", Callback = function() GenericFunctions.PromptDiscordJoin('Vf4Wu3Cft7', true); pcall(writefile, 'StreliziaJoinedDiscord', 'true') end },
                                    { Title = "No", Callback = function() end }
                                }
                            })
                            dialog.Closed:Wait()
                        end
                        Threading.TerminateByIdentifier(thread_data.Identifier)
                    end):Start()
                end

                GenericFunctions.AntiAFK(true)
            end
        end,
        Properties = { Name = "Init" },
        Reference = 1,
        Children = {
            {
                ClassName = "ModuleScript",
                Closure = function()
                    local Library = {
                        Cache = setmetatable({}, {
                            __index = function(cache, key)
                                rawset(cache, key, {})
                                return rawget(cache, key)
                            end,
                        }),
                    }

                    function Library.SetupLazyLoader(script_instance, target_table)
                        local modules = {}
                        for _, module_child in script_instance:GetChildren() do
                            modules[module_child.Name] = module_child
                        end
                        setmetatable(target_table, {
                            __index = function(self_table, module_name)
                                local module_instance = modules[module_name]
                                assert(module_instance, string.format('[Library]: Cannot find module %s in %s', module_name, script_instance.Name))

                                local success, required_module = pcall(require, module_instance)
                                assert(success, string.format('[Library]: Failed to Initalize Module %s in %s: %s', module_name, script_instance.Name, tostring(required_module)))
                                assert(typeof(required_module) == 'function', string.format('[Library]: Module %s is NOT a Function', module_name))

                                local success_call, result = pcall(required_module, Library)
                                assert(success_call, string.format('[Library]: Failed to Load Module %s in %s: %s', module_name, script_instance.Name, tostring(result)))

                                rawset(self_table, module_name, result)
                                return result
                            end,
                        })
                    end

                    Library.SetupLazyLoader(script, Library)
                    return Library
                end,
                Properties = { Name = "Library" },
                Reference = 2,
                Children = {
                    {
                        ClassName = "ModuleScript",
                        Closure = function()
                            return function(Library)
                                local Functions = {}
                                Library.SetupLazyLoader(script, Functions)
                                return Functions
                            end
                        end,
                        Properties = { Name = "Functions" },
                        Reference = 3,
                        Children = {
                            {
                                ClassName = "ModuleScript",
                                Closure = function()
                                    return function(Library)
                                        local Generic = {}
                                        Library.SetupLazyLoader(script, Generic)
                                        return Generic
                                    end
                                end,
                                Properties = { Name = "Generic" },
                                Reference = 4,
                                Children = {
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local Stats = Services.Stats
                                                local Network = Stats.Network.ServerStatsItem["Data Ping"]
                                                local GetValue = Network.GetValue
                                                return function()
                                                    local success, ping = pcall(GetValue, Network)
                                                    return ping or 0
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetPing" },
                                        Reference = 26,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local cache = {}
                                                return function(number)
                                                    local num_str = tostring(number)
                                                    if cache[num_str] then return cache[num_str] end
                                                    local formatted = num_str:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                                                    cache[num_str] = formatted
                                                    return formatted
                                                end
                                            end
                                        end,
                                        Properties = { Name = "CommaNumber" },
                                        Reference = 23,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local Players = Services.Players
                                                local Workspace = Services.Workspace
                                                local LocalPlayer = Players.LocalPlayer
                                                return function(part, options)
                                                    local character = LocalPlayer.Character
                                                    if (not character) then return false end
                                                    options = options or {}
                                                    local origin = options.From or Workspace.CurrentCamera.CFrame.Position
                                                    local direction = (part.Position - origin).Unit
                                                    local ray_params = RaycastParams.new()
                                                    ray_params:AddToFilter(LocalPlayer.Character)
                                                    ray_params.FilterType = Enum.RaycastFilterType.Exclude
                                                    for _, ignored_instance in options.Ignore or {} do
                                                        ray_params:AddToFilter(ignored_instance)
                                                    end
                                                    local ray_result = Workspace:Raycast(origin, direction * 1000, ray_params)
                                                    if ray_result then
                                                        local hit_instance = ray_result.Instance
                                                        if hit_instance and ((hit_instance == part) or (options.ParentMatching and hit_instance.Parent == part.Parent)) then
                                                            return true
                                                        end
                                                    end
                                                    return false
                                                end
                                            end
                                        end,
                                        Properties = { Name = "IsPartVisible" },
                                        Reference = 27,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local cache = {};
                                                return function(seconds)
                                                    local cached = cache[tostring(seconds)];
                                                    if cached then return cached end;

                                                    local total_minutes = (seconds - seconds % 60) / 60;
                                                    seconds = seconds - total_minutes * 60;
                                                    local total_hours = (total_minutes - total_minutes % 60) / 60;
                                                    total_minutes = total_minutes - total_hours * 60;

                                                    local formatted_time = string.format("%02i", total_hours) .. ":" .. string.format("%02i", total_minutes) .. ":" .. string.format("%02i", seconds);
                                                    cache[tostring(seconds)] = formatted_time;
                                                    return formatted_time;
                                                end
                                            end
                                        end,
                                        Properties = { Name = "FormatHms" },
                                        Reference = 18,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local HttpRequest = Library.Functions.Generic.HttpRequest
                                                local Services = Library.Services
                                                local HttpService = Services.HttpService
                                                return function(discord_code, copy_to_clipboard)
                                                    if copy_to_clipboard then
                                                        setclipboard("https://www.discord.gg/" .. discord_code)
                                                    end
                                                    if (not HttpRequest) then return false end
                                                    HttpRequest({
                                                        Url = "http://127.0.0.1:6463/rpc?v=1",
                                                        Method = "POST",
                                                        Headers = { ["Content-Type"] = "application/json", Origin = "https://discord.com" },
                                                        Body = HttpService:JSONEncode({ cmd = "INVITE_BROWSER", args = { code = discord_code }, nonce = HttpService:GenerateGUID(false) })
                                                    })
                                                    return true
                                                end
                                            end
                                        end,
                                        Properties = { Name = "PromptDiscordJoin" },
                                        Reference = 25,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                return function(func, retries, delay, args)
                                                    retries = retries or 3
                                                    delay = delay or 1
                                                    args = args or {}
                                                    local attempt = 0
                                                    while attempt < retries do
                                                        local success, result = pcall(func, unpack(args))
                                                        if success and result then return true end
                                                        attempt = attempt + delay
                                                        task.wait(delay)
                                                    end
                                                    return false
                                                end
                                            end
                                        end,
                                        Properties = { Name = "Timeout" },
                                        Reference = 22,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local MessageType = { Info = '🔵', Warn = '🟠', Success = '🟢', Error = '🔴' }
                                                local function output_message(message_type, message)
                                                    local time_data = os.date"*t"
                                                    string.format("%s:%s:%s", time_data.hour, time_data.min, time_data.sec)
                                                    print(string.format("%s | [Library]: %s", MessageType[message_type], message))
                                                end
                                                return output_message
                                            end
                                        end,
                                        Properties = { Name = "OutputMessage" },
                                        Reference = 30,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Connection
                                                local Services = Library.Services
                                                local VirtualUser = Services.VirtualUser
                                                local Players = Services.Players
                                                local Random = Random.new()
                                                local LocalPlayer = Players.LocalPlayer
                                                local Button2Down = VirtualUser.Button2Down
                                                local Button2Up = VirtualUser.Button2Up
                                                return function(enable)
                                                    if enable == false then
                                                        if Connection then Connection:Disconnect() end
                                                        return true
                                                    end
                                                    if Connection then return true end
                                                    Connection = LocalPlayer.Idled:Connect(function()
                                                        local camera = Workspace.CurrentCamera
                                                        Button2Down(VirtualUser, Vector2.new(0, 0), camera.CFrame)
                                                        task.wait(Random:NextNumber(0, 1))
                                                        Button2Up(VirtualUser, Vector2.new(0, 0), camera.CFrame)
                                                    end)
                                                end
                                            end
                                        end,
                                        Properties = { Name = "AntiAFK" },
                                        Reference = 19,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                return (syn and syn.request) or (http and http.request) or httprequest or request or function() return end
                                            end
                                        end,
                                        Properties = { Name = "HttpRequest" },
                                        Reference = 24,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Actions = Library.Cache.Actions
                                                return function(required_actions)
                                                    for _, action_name in required_actions do
                                                        local action_state = Actions[action_name]
                                                        if action_state then return false end
                                                    end
                                                    return true
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetActionState" },
                                        Reference = 35,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local GuiService = Services.GuiService
                                                return function()
                                                    local camera = Workspace.CurrentCamera
                                                    local viewport_size = camera.ViewportSize
                                                    local inset_x, inset_y = GuiService:GetGuiInset()
                                                    return Vector2.new(viewport_size.X, viewport_size.Y), inset_x, inset_y
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetScreenSize" },
                                        Reference = 29,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local FindFirstChild = game.FindFirstChild
                                                return function(player)
                                                    local character = player.Character
                                                    if (not character) then return false end
                                                    local primary_part = character.PrimaryPart
                                                    if (not primary_part) then return false end
                                                    local humanoid = FindFirstChild(character, "Humanoid")
                                                    if (not humanoid) or (humanoid.Health <= 0) then return false end
                                                    return character
                                                end
                                            end
                                        end,
                                        Properties = { Name = "IsAlive" },
                                        Reference = 20,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local Trove = Library.Libraries.RBXUtil.Trove
                                                local Drawing = Drawing
                                                local RunService = Services.RunService
                                                return function(draw_type, properties, update_callback)
                                                    if (not Drawing) then return end
                                                    local new_trove = Trove.new()
                                                    local drawing_object = new_trove:Add(Drawing.new(draw_type), 'Destroy')
                                                    for prop, value in properties do
                                                        drawing_object[prop] = value
                                                    end
                                                    new_trove:Add(RunService.Heartbeat:Connect(function(delta_time)
                                                        update_callback(drawing_object, delta_time, new_trove)
                                                    end))
                                                    return new_trove
                                                end
                                            end
                                        end,
                                        Properties = { Name = "SmartDraw" },
                                        Reference = 36,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                return function(class_name, properties)
                                                    local instance = Instance.new(class_name)
                                                    for prop, value in properties do
                                                        instance[prop] = value
                                                    end
                                                    return instance
                                                end
                                            end
                                        end,
                                        Properties = { Name = "CreateInstance" },
                                        Reference = 28,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Actions = Library.Cache.Actions
                                                return function(actions, state)
                                                    for _, action_name in actions do
                                                        Actions[action_name] = state
                                                    end
                                                    return true
                                                end
                                            end
                                        end,
                                        Properties = { Name = "SetActionState" },
                                        Reference = 34,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local ScriptCache = Library.Cache.ScriptCache
                                                return function()
                                                    local init_time = ScriptCache.InitTime
                                                    if (not init_time) then return 0 end
                                                    return DateTime.now().UnixTimestamp - init_time
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetUptime" },
                                        Reference = 17,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local GetPing = Library.Functions.Generic.GetPing
                                                return function(min_ping, max_ping)
                                                    local current_ping = GetPing()
                                                    if current_ping < min_ping then return end
                                                    while GetPing() > max_ping do
                                                        task.wait(0.2)
                                                    end
                                                end
                                            end
                                        end,
                                        Properties = { Name = "HaltLatency" },
                                        Reference = 16,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local Players = Services.Players
                                                local LocalPlayer = Players.LocalPlayer
                                                local Mouse = LocalPlayer:GetMouse()
                                                return function()
                                                    return Vector2.new(Mouse.X, Mouse.Y)
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetMousePosition" },
                                        Reference = 33,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                return function(func, options)
                                                    options = options or {}
                                                    local retries = options.Retries or 2
                                                    local args = options.Arguments or {}
                                                    local retry_delay = options.RetryDelay or 0
                                                    local success, result
                                                    for i = 1, retries do
                                                        success, result = pcall(func, unpack(args))
                                                        if success and result == true then break end
                                                        task.wait(retry_delay)
                                                    end
                                                    return success, result
                                                end
                                            end
                                        end,
                                        Properties = { Name = "Retry" },
                                        Reference = 31,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        ClassName = "ModuleScript",
                                        Closure = function()
                                            return function(Library)
                                                local FindFirstChild = game.FindFirstChild
                                                local required_modules_cache = {}
                                                local initialized_modules = {}

                                                local function require_and_cache(module_instance, load_if_not_loaded)
                                                    local cached = required_modules_cache[module_instance];
                                                    if cached then return cached end;

                                                    local initialized = initialized_modules[module_instance]
                                                    local module_result = (initialized or (select(2, pcall(require, module_instance))));
                                                    local is_function = typeof(module_result) == 'function';

                                                    if (not initialized and is_function) then
                                                        initialized_modules[module_instance] = module_result;
                                                    end

                                                    local final_result = (is_function and select(2, pcall(module_result, Library)));
                                                    required_modules_cache[module_instance] = final_result;
                                                    return final_result;
                                                end

                                                return function(functions_to_assert, on_success, on_failure, ignore_init_error)
                                                    local missing_functions = {};
                                                    local callbacks = {
                                                        [true] = on_success,
                                                        [false] = on_failure
                                                    };

                                                    for _, func_name in functions_to_assert do
                                                        local module_instance = FindFirstChild(script, func_name)
                                                        if (not module_instance) then continue end
                                                        local result = require_and_cache(module_instance, ignore_init_error)
                                                        if (not result) then table.insert(missing_functions, func_name) end;
                                                    end

                                                    local all_present = #missing_functions == 0;
                                                    if callbacks[all_present] then
                                                        pcall(callbacks[all_present], missing_functions);
                                                    end
                                                    return all_present, missing_functions;
                                                end
                                            end
                                        end,
                                        Properties = { Name = "AssertFunctions" },
                                        Reference = 5,
                                        Children = {
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local function test_function()
                                                            local constant = "Constant"
                                                            return constant
                                                        end
                                                        return function()
                                                            local getconstants = (debug and debug.getconstants) or getconstants
                                                            if not getconstants then return false end
                                                            local success, constants = pcall(getconstants, test_function)
                                                            if not success or (typeof(constants) ~= 'table') or #constants ~= 1 or constants[1] ~= 'Constant' then return false end
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "getconstants" },
                                                Reference = 7,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local dummy_table = setmetatable({}, {})
                                                        local locked_table = setmetatable({}, { __metatable = "locked" })
                                                        local dummy_metatable = getmetatable(dummy_table)
                                                        return function(enable_test)
                                                            local getrawmetatable = getrawmetatable
                                                            if not getrawmetatable then return false end
                                                            local success1, meta1 = pcall(getrawmetatable, dummy_table);
                                                            if (not success1) or meta1 ~= dummy_metatable then return false end;
                                                            local success2, meta2 = pcall(getrawmetatable, locked_table);
                                                            if (not success2) or (meta2.__metatable ~= 'locked') then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "getrawmetatable" },
                                                Reference = 8,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_func = function() return false end
                                                        return function()
                                                            local hookfunction = hookfunction;
                                                            if not hookfunction then return false end;
                                                            local success, original_func = pcall(hookfunction, test_func, function() return true end);
                                                            if not success then return false end;
                                                            local success2, result = pcall(test_func);
                                                            if not success2 or result ~= true then return false end;
                                                            hookfunction(test_func, original_func);
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "hookfunction" },
                                                Reference = 15,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_data = { 1, 2, 3, 'Hi', 'Test' }
                                                        local function test_upvalues()
                                                            local a, b, c, d = table.unpack(test_data)
                                                            return table.pack(a, b, c, d)
                                                        end
                                                        return function()
                                                            local getupvalues = debug and debug.getupvalues or getupvalues;
                                                            if (not getupvalues) then return false end;
                                                            local success, upvalues = pcall(getupvalues, test_upvalues)
                                                            if not success or typeof(upvalues) ~= 'table' or typeof(upvalues[1]) ~= 'table' or (table.unpack(upvalues[1]) ~= table.unpack(test_data)) then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "getupvalues" },
                                                Reference = 10,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local function check_drawing_properties(drawing_object)
                                                            return (pcall(function() return (drawing_object.Radius and drawing_object.Color and drawing_object.NumSides and drawing_object.Position and drawing_object.Transparency and typeof(drawing_object.Destroy) == 'function') end))
                                                        end
                                                        return function()
                                                            local Drawing = Drawing;
                                                            if (not Drawing) or (not Drawing.new) then return false end;
                                                            local success1, circle_drawing = pcall(Drawing.new, 'Circle');
                                                            if (not success1) or (not check_drawing_properties(circle_drawing)) then return false end;
                                                            local success2, _ = pcall(circle_drawing.Destroy, circle_drawing);
                                                            if (not success2) then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "drawing" },
                                                Reference = 13,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_cases = {
                                                            Param = { Function = function(a, b, c, d) local e = 5; return e end, Expected = { source = "=", what = "Lua", numparams = 4, func = nil, short_src = "", name = "Function", is_vararg = 0, nups = 0, } },
                                                            Lua = { Function = function() return 'Hi i am lua indeed' end, Expected = { source = "=", what = "Lua", numparams = 0, func = nil, short_src = "", name = "Function", is_vararg = 0, nups = 0, } },
                                                            C = { Function = print or function() return 'well this aint no C' end, Expected = { source = "=[C]", what = "C", numparams = 0, func = nil, short_src = "[C]", currentline = -1, name = "print", is_vararg = 1, nups = 0, } }
                                                        }
                                                        return function()
                                                            local getinfo = (debug and debug.getinfo) or getinfo
                                                            if not getinfo then return false end
                                                            for _, test_case in test_cases do
                                                                test_case.Expected.func = test_case.Function;
                                                                local success, info = pcall(getinfo, test_case.Function);
                                                                if not success or (typeof(info) ~= 'table') then return false end;
                                                                for prop, expected_value in test_case.Expected do
                                                                    if (info[prop] == expected_value) then continue end
                                                                    return false
                                                                end
                                                            end
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "debug_getinfo" },
                                                Reference = 6,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_func = function() return nil end;
                                                        return function()
                                                            local newcclosure = newcclosure;
                                                            if not newcclosure then return false end;
                                                            local success, created_cclosure = pcall(newcclosure, test_func);
                                                            if not success or typeof(created_cclosure) ~= "function" or created_cclosure == test_func then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "newcclosure" },
                                                Reference = 11,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local CreateInstance = Library.Functions.Generic.CreateInstance
                                                        local Services = Library.Libraries.Generic.Services
                                                        local Trove = Library.Libraries.Generic.Trove
                                                        local RunService = Services.RunService
                                                        local Workspace = Services.Workspace
                                                        local Players = Services.Players
                                                        local LocalPlayer = Players.LocalPlayer
                                                        local function create_part()
                                                            return CreateInstance("Part", { Parent = Workspace, Size = Vector3.zero, Anchored = true, CanCollide = false, Transparency = 1 })
                                                        end
                                                        local WaitForChild = game.WaitForChild
                                                        return function()
                                                            local firetouchinterest = firetouchinterest
                                                            if not firetouchinterest then return false end
                                                            local new_trove = Trove.new();
                                                            local part_instance = new_trove:Add(create_part())
                                                            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
                                                            local root_part = WaitForChild(character, 'HumanoidRootPart', 10)
                                                            if (not root_part) then new_trove:Destroy(); return false end;
                                                            local touched = false
                                                            new_trove:Add(part_instance.Touched:Once(function() touched = true end))
                                                            local success, _ = pcall(firetouchinterest, part_instance, root_part, 0);
                                                            if (not success) then new_trove:Destroy(); return false end;
                                                            local wait_time = 0;
                                                            while (wait_time < 0.5 and not touched) do
                                                                wait_time = wait_time + task.wait()
                                                            end
                                                            new_trove:Destroy();
                                                            return touched
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "firetouchinterest" },
                                                Reference = 14,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_table = setmetatable({}, {
                                                            __index = function(self_table, key)
                                                                return false
                                                            end,
                                                        })
                                                        local function access_table(tbl, key)
                                                            return tbl[key]
                                                        end
                                                        return function()
                                                            local hookmetamethod = hookmetamethod;
                                                            if (not hookmetamethod) then return false end;
                                                            local success, _ = pcall(hookmetamethod, test_table, "__index", function() return true end);
                                                            if (not success) then return false end;
                                                            local success2, result = pcall(access_table, test_table, 'Test');
                                                            if (not success2) or result ~= true then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "hookmetamethod" },
                                                Reference = 12,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local test_func = function() return end;
                                                        return function()
                                                            local islclosure = islclosure;
                                                            if not islclosure then return false end;
                                                            local success1, is_lua_closure = pcall(islclosure, test_func);
                                                            if not success1 or is_lua_closure ~= true then return false end;
                                                            local print_func = print;
                                                            if (not print_func) then return false end;
                                                            local success2, is_c_closure = pcall(islclosure, print_func);
                                                            if not success2 or is_c_closure == true then return false end;
                                                            return true
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "islclosure" },
                                                Reference = 9,
                                                ClassName = "ModuleScript"
                                            }
                                        }
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local OutputMessage = Library.Functions.Generic.OutputMessage
                                                return function(benchmark_name, expected_time)
                                                    local start_time = os.clock();
                                                    return function()
                                                        local elapsed_time_ms = math.ceil((os.clock() - start_time) * 1000);
                                                        local expected_ms = expected_time or 250
                                                        if elapsed_time_ms > expected_ms and Library.Debug then
                                                            OutputMessage('Warn', string.format('%s Benchmark took long to complete (%sms) (Expected: %sms)', tostring(benchmark_name), tostring(elapsed_time_ms), tostring(expected_ms)))
                                                        end
                                                        return elapsed_time_ms
                                                    end
                                                end
                                            end
                                        end,
                                        Properties = { Name = "Benchmark" },
                                        Reference = 32,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local Players = Services.Players
                                                local LocalPlayer = Players.LocalPlayer
                                                return function(anchored)
                                                    local character = LocalPlayer.Character
                                                    if (not character) or (not character.HumanoidRootPart) then return end
                                                    character.HumanoidRootPart.Anchored = anchored
                                                end
                                            end
                                        end,
                                        Properties = { Name = "SetPlayerAnchored" },
                                        Reference = 21,
                                        ClassName = "ModuleScript"
                                    }
                                }
                            },
                            {
                                ClassName = "ModuleScript",
                                Closure = function()
                                    return function(Library)
                                        local Special = {}
                                        Library.SetupLazyLoader(script, Special)
                                        return Special
                                    end
                                end,
                                Properties = { Name = "Special" },
                                Reference = 37,
                                Children = {
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Libraries = Library.Libraries
                                                local GameModules = Libraries.Special.GameModules.Get();
                                                local Knit = GameModules.Knit
                                                local DataController = Knit.GetController'DataController'
                                                local Rebirths = GameModules.Rebirths
                                                local Upgrades = GameModules.Upgrades
                                                return function()
                                                    local best_option;
                                                    local rebirth_button_upgrade = Upgrades.rebirthButtons.upgrades[DataController.data.upgrades.rebirthButtons or 0];
                                                    for option_id, option_data in Rebirths do
                                                        if rebirth_button_upgrade.value >= option_id then
                                                            best_option = option_id
                                                            continue
                                                        end
                                                        break
                                                    end
                                                    return best_option
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetBestRebirthOption" },
                                        Reference = 39,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local GameModules = Library.Libraries.Special.GameModules.Get();
                                                local DataController = GameModules.Knit.GetController'DataController';
                                                local Items = GameModules.Items
                                                local PetItem = Items.pet
                                                return function(tier)
                                                    local pets = {};
                                                    for id, pet_data in DataController.data.inventory.pet do
                                                        local pet_object = PetItem(pet_data.nm):setData(pet_data);
                                                        if pet_object:getTier() == tier then
                                                            pets[id] = pet_object
                                                        end
                                                    end
                                                    return pets
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetPetsByTier" },
                                        Reference = 42,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local GameModules = Library.Libraries.Special.GameModules.Get()
                                                local DataController = GameModules.Knit.GetController'DataController';
                                                return function(item_type, item_name)
                                                    for item_id, item_data in DataController.data.inventory[item_type] do
                                                        if item_data.nm == item_name then
                                                            return item_id, item_data
                                                        end
                                                    end
                                                    return nil
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetItemByName" },
                                        Reference = 44,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Libraries = Library.Libraries
                                                local GameModules = Libraries.Special.GameModules.Get();
                                                local Knit = GameModules.Knit
                                                local DataController = Knit.GetController'DataController'
                                                local Rebirths = GameModules.Rebirths
                                                local Variables = GameModules.Variables
                                                return function(option_id)
                                                    local rebirth_option_data = Rebirths[option_id];
                                                    if not rebirth_option_data then return false end;
                                                    local current_clicks = DataController.data.clicks;
                                                    return current_clicks >= (Variables.rebirthPrice + DataController.data.rebirths * Variables.rebirthPriceMultiplier) * rebirth_option_data + Variables.rebirthPriceMultiplier * (rebirth_option_data * (rebirth_option_data - 1) / 2)
                                                end
                                            end
                                        end,
                                        Properties = { Name = "CanAffordRebirth" },
                                        Reference = 40,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local GameModules = Library.Libraries.Special.GameModules.Get()
                                                local DataController = GameModules.Knit.GetController'DataController';
                                                local Achievements = GameModules.Achievements
                                                return function(achievement_class)
                                                    for tier, achievement_data in Achievements[achievement_class].list do
                                                        if DataController.data.claimedAchievements[string.format('%s%s', tostring(achievement_class), tostring(tier))] then continue end;
                                                        return tier, achievement_data
                                                    end
                                                    return nil
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetNextAchievementByClass" },
                                        Reference = 43,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Libraries = Library.Libraries
                                                local GameModules = Libraries.Special.GameModules.Get();
                                                local Knit = GameModules.Knit
                                                local DataController = Knit.GetController'DataController'
                                                local Rebirths = GameModules.Rebirths
                                                local Upgrades = GameModules.Upgrades
                                                return function()
                                                    local unlocked_options = {}
                                                    local rebirth_button_upgrade = Upgrades.rebirthButtons.upgrades[DataController.data.upgrades.rebirthButtons or 0];
                                                    for option_id, option_data in Rebirths do
                                                        if rebirth_button_upgrade.value < option_id then continue end
                                                        table.insert(unlocked_options, option_data)
                                                    end
                                                    return unlocked_options
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetUnlockedRebirthOptions" },
                                        Reference = 38,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local CollectionService = Services.CollectionService;
                                                local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
                                                return function(group_id)
                                                    local trees = {};
                                                    for _, tagged_tree in CollectionService:GetTagged'Tree' do
                                                        local model = FindFirstChildWhichIsA(tagged_tree, 'Model');
                                                        if not model then continue end
                                                        local tree_group_id = tagged_tree:GetAttribute'groupId';
                                                        if tree_group_id ~= group_id then continue end
                                                        local tree_id = tagged_tree:GetAttribute'treeId'
                                                        local current_id = tagged_tree:GetAttribute'currentId'
                                                        if not tree_id or not current_id then continue end
                                                        table.insert(trees, { Id = tree_id, TreeType = current_id, CFrame = model:GetPivot() })
                                                    end
                                                    return trees
                                                end
                                            end
                                        end,
                                        Properties = { Name = "GetTreesByGroupId" },
                                        Reference = 41,
                                        ClassName = "ModuleScript"
                                    }
                                }
                            }
                        }
                    },
                    {
                        ClassName = "ModuleScript",
                        Closure = function()
                            return function(Library)
                                local Libraries = {}
                                Library.SetupLazyLoader(script, Libraries)
                                return Libraries
                            end
                        end,
                        Properties = { Name = "Libraries" },
                        Reference = 45,
                        Children = {
                            {
                                ClassName = "ModuleScript",
                                Closure = function()
                                    return function(Library)
                                        local Generic = {}
                                        Library.SetupLazyLoader(script, Generic)
                                        return Generic
                                    end
                                end,
                                Properties = { Name = "Generic" },
                                Reference = 46,
                                Children = {
                                    {
                                        ClassName = "ModuleScript",
                                        Closure = function()
                                            return function(Library)
                                                local iscclosure = iscclosure
                                                local newcclosure = newcclosure
                                                local Trove = Library.Libraries.RBXUtil.Trove
                                                local Services = Library.Services
                                                local Metatable = require(script.Metatable)(Library)
                                                local HttpService = Services.HttpService
                                                local Threading = {}
                                                Threading.Settings = { CanStart = true }
                                                Threading.List = {}

                                                function Threading.new(identifier, func)
                                                    local uuid = HttpService:GenerateGUID(false)
                                                    local thread_obj = setmetatable({
                                                        Running = false,
                                                        Terminated = false,
                                                        Index = identifier,
                                                        Trove = Trove.new(),
                                                        Identifier = uuid,
                                                        Thread = func and ((iscclosure(func) and func) or (newcclosure(func))) or nil,
                                                        Creation = DateTime.now().UnixTimestamp
                                                    }, Metatable)
                                                    Threading.List[uuid] = thread_obj
                                                    return thread_obj
                                                end

                                                function Threading.GetByIndex(identifier)
                                                    local results = {};
                                                    for uuid, thread_obj in Threading.List do
                                                        if thread_obj.Index ~= identifier then continue end
                                                        table.insert(results, thread_obj)
                                                    end
                                                    if #results == 0 then return false end
                                                    return results
                                                end

                                                function Threading.TerminateByIndex(identifier)
                                                    for uuid, thread_obj in Threading.List do
                                                        if thread_obj.Index ~= identifier then continue end
                                                        thread_obj:_terminate()
                                                        Threading.List[uuid] = nil
                                                    end
                                                end

                                                function Threading.GetByIdentifier(uuid)
                                                    return Threading.List[uuid] or nil
                                                end

                                                function Threading.TerminateByIdentifier(uuid)
                                                    local thread_obj = Threading.GetByIdentifier(uuid);
                                                    if thread_obj then
                                                        thread_obj:_terminate()
                                                        Threading.List[uuid] = nil
                                                    end
                                                end

                                                function Threading.TerminateAll()
                                                    for uuid, thread_obj in Threading.List do
                                                        thread_obj:_terminate()
                                                        Threading.List[uuid] = nil
                                                    end
                                                end

                                                function Threading.SetOption(setting, value)
                                                    Threading.Settings[setting] = value
                                                end

                                                return Threading
                                            end
                                        end,
                                        Properties = { Name = "Threading" },
                                        Reference = 48,
                                        Children = {
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local OutputMessage = Library.Functions.Generic.OutputMessage
                                                        local Metatable = {}
                                                        Metatable.__index = Metatable

                                                        function Metatable.Start(self, ...)
                                                            if self.Running or self.Terminated or (not self.Thread) then return self end
                                                            self.Running = true
                                                            local success, result = pcall(task.spawn, self.Thread, self, ...);
                                                            if not success or typeof(result) ~= 'thread' then
                                                                OutputMessage('Error', string.format('Failed to start thread %s: %s', tostring(self.Index), tostring(tostring(result))))
                                                                return self
                                                            end
                                                            self.Trove:Add(result)
                                                            return self
                                                        end

                                                        function Metatable._terminate(self)
                                                            if self.Terminated then return self end
                                                            self.Running = false
                                                            self.Terminated = true
                                                            self.Trove:Destroy()
                                                            return self
                                                        end

                                                        function Metatable.Add(self, object, cleanup_func)
                                                            if (self.Terminated) or (not self.Running) then return self end
                                                            local success, result = pcall(self.Trove.Add, self.Trove, object, cleanup_func);
                                                            if not success then
                                                                OutputMessage('Error', string.format('Failed to add object %s to Thread %s: %s', tostring(tostring(object)), tostring(self.Index), tostring(tostring(result))))
                                                            end
                                                            return self
                                                        end

                                                        function Metatable.GetAge(self)
                                                            return (DateTime.now().UnixTimestamp - self.Creation)
                                                        end

                                                        return Metatable
                                                    end
                                                end,
                                                Properties = { Name = "Metatable" },
                                                Reference = 49,
                                                ClassName = "ModuleScript"
                                            }
                                        }
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local RBXUtil = Library.Libraries.RBXUtil
                                                local GenericFunctions = Library.Functions.Generic
                                                local Promise = RBXUtil.Promise
                                                local Signal = RBXUtil.Signal
                                                local GetDictionarySize = RBXUtil.TableUtil.GetDictionarySize
                                                local OutputMessage = GenericFunctions.OutputMessage
                                                local Benchmark = GenericFunctions.Benchmark

                                                local InterfaceModules = {
                                                    Fluent = { Id = 97404758083545, Expected = 1500 },
                                                    SaveManager = { Id = 132828910264093, Expected = 1200 },
                                                    ThemeManager = { Id = 72525158718178, Expected = 1200 }
                                                }

                                                local InterfaceCache = {
                                                    Cached = false,
                                                    Caching = false,
                                                    OnCached = Signal.new(),
                                                    Cache = {}
                                                }

                                                local function load_interface_modules()
                                                    local benchmark_total = Benchmark('Interface', 8000)
                                                    InterfaceCache.Caching = true
                                                    local promises = {}
                                                    for module_name, module_info in InterfaceModules do
                                                        table.insert(promises, Promise.new(function(resolve, reject)
                                                            local benchmark_module = Benchmark(string.format('Interface/%s', tostring(module_name)), module_info.Expected)
                                                            local success, result = pcall(game.GetObjects, game, string.format('rbxassetid://%s', tostring(module_info.Id)))
                                                            if success then
                                                                if Library.Debug then
                                                                    OutputMessage('Success', string.format('Successfully loaded Interface Module %s: %sms Elapsed', tostring(module_name), tostring(benchmark_module())))
                                                                end
                                                                resolve(loadstring(result[1].Source)())
                                                            else
                                                                reject(tostring(result))
                                                            end
                                                        end):andThen(function(module_data)
                                                            InterfaceCache.Cache[module_name] = module_data
                                                        end):catch(function(error_msg)
                                                            OutputMessage('Error', string.format('Failed to load Interface Module %s: %s', tostring(module_name), tostring(error_msg)))
                                                        end))
                                                    end
                                                    Promise.all(promises):await()
                                                    if Library.Debug then
                                                        OutputMessage('Info', string.format('Took %sms to load Interface Class (%s Modules)', tostring(benchmark_total()), tostring(GetDictionarySize(InterfaceModules))))
                                                    end
                                                    InterfaceCache.Cached = true
                                                    InterfaceCache.Caching = false
                                                    InterfaceCache.OnCached:Fire(InterfaceCache.Cache)
                                                    return InterfaceCache.Cache
                                                end

                                                return {
                                                    Get = function()
                                                        if InterfaceCache.Cached == false then
                                                            if InterfaceCache.Caching == true then return InterfaceCache.OnCached:Wait() end
                                                            return load_interface_modules()
                                                        end
                                                        return InterfaceCache.Cache
                                                    end,
                                                }
                                            end
                                        end,
                                        Properties = { Name = "Interface" },
                                        Reference = 47,
                                        ClassName = "ModuleScript"
                                    }
                                }
                            },
                            {
                                ClassName = "ModuleScript",
                                Closure = function()
                                    return function(Library)
                                        local Special = {}
                                        Library.SetupLazyLoader(script, Special)
                                        return Special
                                    end
                                end,
                                Properties = { Name = "Special" },
                                Reference = 50,
                                Children = {
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local RBXUtil = Library.Libraries.RBXUtil
                                                local GenericFunctions = Library.Functions.Generic
                                                local ReplicatedStorage = Services.ReplicatedStorage
                                                local Players = Services.Players
                                                local Promise = RBXUtil.Promise
                                                local Tree = RBXUtil.Tree
                                                local TableUtil = RBXUtil.TableUtil
                                                local Signal = RBXUtil.Signal
                                                local OutputMessage = GenericFunctions.OutputMessage

                                                local GameModulesCache = {
                                                    Caching = false,
                                                    Cached = false,
                                                    Cache = {},
                                                    OnCached = Signal.new()
                                                }

                                                local function get_module_paths()
                                                    local LocalPlayer = Players.LocalPlayer
                                                    local character = LocalPlayer.Character
                                                    local paths = {
                                                        Knit = Tree.Find(ReplicatedStorage, 'Packages/Knit'),
                                                        Upgrades = Tree.Find(ReplicatedStorage, 'Shared/List/Upgrades'),
                                                        Rebirths = Tree.Find(ReplicatedStorage, 'Shared/List/Rebirths'),
                                                        Functions = Tree.Find(ReplicatedStorage, 'Shared/Functions'),
                                                        Variables = Tree.Find(ReplicatedStorage, 'Shared/Variables'),
                                                        Eggs = Tree.Find(ReplicatedStorage, 'Shared/List/Pets/Eggs'),
                                                        Values = Tree.Find(ReplicatedStorage, 'Shared/Values'),
                                                        Util = Tree.Find(ReplicatedStorage, 'Shared/Util'),
                                                        Farms = Tree.Find(ReplicatedStorage, 'Shared/List/Farms'),
                                                        Trees = Tree.Find(ReplicatedStorage, 'Shared/List/Trees'),
                                                        Chests = Tree.Find(ReplicatedStorage, 'Shared/List/Chests'),
                                                        Tiers = Tree.Find(ReplicatedStorage, 'Shared/List/Pets/Tiers'),
                                                        Items = Tree.Find(ReplicatedStorage, 'Shared/Items'),
                                                        PlaytimeRewards = Tree.Find(ReplicatedStorage, 'Shared/List/PlaytimeRewards'),
                                                        Achievements = Tree.Find(ReplicatedStorage, 'Shared/List/Achievements'),
                                                        IndexRewards = Tree.Find(ReplicatedStorage, 'Shared/List/IndexRewards'),
                                                        Prestiges = Tree.Find(ReplicatedStorage, 'Shared/List/Prestige/Prestiges'),
                                                        Potions = Tree.Find(ReplicatedStorage, 'Shared/List/Items/Potions'),
                                                        Boxes = Tree.Find(ReplicatedStorage, 'Shared/List/Items/Boxes'),
                                                    }
                                                    return paths
                                                end

                                                local function load_game_modules()
                                                    local promises = {}
                                                    GameModulesCache.Caching = true
                                                    for module_name, module_path in get_module_paths() do
                                                        table.insert(promises, Promise.new(function(resolve, reject)
                                                            local success, result = pcall(require, module_path);
                                                            if success then
                                                                resolve(result)
                                                            else
                                                                reject(tostring(result))
                                                            end
                                                        end):andThen(function(module_data)
                                                            GameModulesCache.Cache[module_name] = module_data
                                                        end):catch(function(error_msg)
                                                            OutputMessage('Error', string.format('Failed to require Game Module %s: %s', tostring(module_path.Name), tostring(error_msg)))
                                                        end))
                                                    end
                                                    Promise.all(promises):await()
                                                    GameModulesCache.Caching = false
                                                    GameModulesCache.Cached = true
                                                    GameModulesCache.OnCached:Fire(GameModulesCache.Cache)
                                                    return GameModulesCache.Cache
                                                end

                                                local function get_or_load_modules()
                                                    if GameModulesCache.Cached == false then
                                                        if GameModulesCache.Caching == true then return GameModulesCache.OnCached:Wait() end
                                                        return load_game_modules()
                                                    end
                                                    return GameModulesCache.Cache
                                                end

                                                return table.freeze({ Get = get_or_load_modules })
                                            end
                                        end,
                                        Properties = { Name = "GameModules" },
                                        Reference = 51,
                                        ClassName = "ModuleScript"
                                    }
                                }
                            },
                            {
                                ClassName = "ModuleScript",
                                Closure = function()
                                    return function(Library)
                                        local RBXUtil = {}
                                        Library.SetupLazyLoader(script, RBXUtil)
                                        return RBXUtil
                                    end
                                end,
                                Properties = { Name = "RBXUtil" },
                                Reference = 52,
                                Children = {
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local original_thread_func;
                                                local function thread_wrapper(func, ...)
                                                    local old_thread_func = original_thread_func
                                                    original_thread_func = nil
                                                    func(...)
                                                    original_thread_func = old_thread_func
                                                end

                                                local function thread_loop(func, ...)
                                                    thread_wrapper(func, ...)
                                                    while true do
                                                        thread_wrapper(coroutine.yield())
                                                    end
                                                end

                                                local ConnectionMetatable = {}
                                                ConnectionMetatable.__index = ConnectionMetatable
                                                function ConnectionMetatable.Disconnect(self)
                                                    if not self.Connected then return end
                                                    self.Connected = false
                                                    if self._signal._handlerListHead == self then
                                                        self._signal._handlerListHead = self._next
                                                    else
                                                        local current = self._signal._handlerListHead
                                                        while current and current._next ~= self do
                                                            current = current._next
                                                        end
                                                        if current then current._next = self._next end
                                                    end
                                                end
                                                ConnectionMetatable.Destroy = ConnectionMetatable.Disconnect
                                                setmetatable(ConnectionMetatable, {
                                                    __index = function(self, key) error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2) end,
                                                    __newindex = function(self, key, value) error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2) end,
                                                })

                                                local SignalMetatable = {}
                                                SignalMetatable.__index = SignalMetatable
                                                function SignalMetatable.new()
                                                    return setmetatable({ _handlerListHead = false, _proxyHandler = nil, _yieldedThreads = nil }, SignalMetatable)
                                                end

                                                function SignalMetatable.Wrap(rbx_signal)
                                                    assert(typeof(rbx_signal) == "RBXScriptSignal", "Argument #1 to Signal.Wrap must be a RBXScriptSignal; got " .. typeof(rbx_signal))
                                                    local new_signal = SignalMetatable.new()
                                                    new_signal._proxyHandler = rbx_signal:Connect(function(...) new_signal:Fire(...) end)
                                                    return new_signal
                                                end

                                                function SignalMetatable.Is(obj)
                                                    return type(obj) == "table" and getmetatable(obj) == SignalMetatable
                                                end

                                                function SignalMetatable.Connect(self, func)
                                                    local new_connection = setmetatable({ Connected = true, _signal = self, _fn = func, _next = false }, ConnectionMetatable)
                                                    if self._handlerListHead then
                                                        new_connection._next = self._handlerListHead
                                                        self._handlerListHead = new_connection
                                                    else
                                                        self._handlerListHead = new_connection
                                                    end
                                                    return new_connection
                                                end

                                                function SignalMetatable.ConnectOnce(self, func) return self:Once(func) end

                                                function SignalMetatable.Once(self, func)
                                                    local connection
                                                    local fired = false
                                                    connection = self:Connect(function(...)
                                                        if fired then return end
                                                        fired = true
                                                        connection:Disconnect()
                                                        func(...)
                                                    end)
                                                    return connection
                                                end

                                                function SignalMetatable.GetConnections(self)
                                                    local connections = {}
                                                    local current = self._handlerListHead
                                                    while current do
                                                        table.insert(connections, current)
                                                        current = current._next
                                                    end
                                                    return connections
                                                end

                                                function SignalMetatable.DisconnectAll(self)
                                                    local current = self._handlerListHead
                                                    while current do
                                                        current.Connected = false
                                                        current = current._next
                                                    end
                                                    self._handlerListHead = false
                                                    local yielded_threads = rawget(self, "_yieldedThreads")
                                                    if yielded_threads then
                                                        for thread in yielded_threads do
                                                            if coroutine.status(thread) == "suspended" then
                                                                warn(debug.traceback(thread, "signal disconnected; yielded thread cancelled", 2))
                                                                task.cancel(thread)
                                                            end
                                                        end
                                                        table.clear(yielded_threads)
                                                    end
                                                end

                                                function SignalMetatable.Fire(self, ...)
                                                    local current = self._handlerListHead
                                                    while current do
                                                        if current.Connected then
                                                            if not original_thread_func then original_thread_func = coroutine.create(thread_loop) end
                                                            task.spawn(original_thread_func, current._fn, ...)
                                                        end
                                                        current = current._next
                                                    end
                                                end

                                                function SignalMetatable.FireDeferred(self, ...)
                                                    local current = self._handlerListHead
                                                    while current do
                                                        local connection = current
                                                        task.defer(function(...) if connection.Connected then connection._fn(...) end end, ...)
                                                        current = current._next
                                                    end
                                                end

                                                function SignalMetatable.Wait(self)
                                                    local yielded_threads = rawget(self, "_yieldedThreads")
                                                    if not yielded_threads then
                                                        yielded_threads = {}
                                                        rawset(self, "_yieldedThreads", yielded_threads)
                                                    end
                                                    local current_thread = coroutine.running()
                                                    yielded_threads[current_thread] = true
                                                    self:Once(function(...)
                                                        yielded_threads[current_thread] = nil
                                                        task.spawn(current_thread, ...)
                                                    end)
                                                    return coroutine.yield()
                                                end

                                                function SignalMetatable.Destroy(self)
                                                    self:DisconnectAll()
                                                    local proxy_handler = rawget(self, "_proxyHandler")
                                                    if proxy_handler then proxy_handler:Disconnect() end
                                                end

                                                setmetatable(SignalMetatable, {
                                                    __index = function(self, key) error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2) end,
                                                    __newindex = function(self, key, value) error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2) end,
                                                })

                                                return table.freeze({ new = SignalMetatable.new, Wrap = SignalMetatable.Wrap, Is = SignalMetatable.Is })
                                            end
                                        end,
                                        Properties = { Name = "Signal" },
                                        Reference = 55,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local ERROR_NON_PROMISE_VALUE = "Non-promise value passed into %s at index %s"
                                                local ERROR_PROMISE_LIST = "Please pass a list of promises to %s"
                                                local ERROR_HANDLER_FUNCTION = "Please pass a handler function to %s!"

                                                local PROMISE_CONSUMER_METATABLE = { __mode = "k" }

                                                local function is_callable(obj)
                                                    if type(obj) == "function" then return true end
                                                    if type(obj) == "table" then
                                                        local mt = getmetatable(obj)
                                                        if mt and type(rawget(mt, "__call")) == "function" then return true end
                                                    end
                                                    return false
                                                end

                                                local function create_status_enum(name, values)
                                                    local enum_table = {}
                                                    for _, value in ipairs(values) do
                                                        enum_table[value] = value
                                                    end
                                                    return setmetatable(enum_table, {
                                                        __index = function(self, key) error(string.format("%s is not in %s!", key, name), 2) end,
                                                        __newindex = function() error(string.format("Creating new members in %s is not allowed!", name), 2) end,
                                                    })
                                                end

                                                local PromiseErrorMetatable = {}
                                                do
                                                    PromiseErrorMetatable = {
                                                        Kind = create_status_enum("Promise.Error.Kind", { "ExecutionError", "AlreadyCancelled", "NotResolvedInTime", "TimedOut" }),
                                                    }
                                                    PromiseErrorMetatable.__index = PromiseErrorMetatable

                                                    function PromiseErrorMetatable.new(options, parent_error)
                                                        options = options or {}
                                                        return setmetatable({
                                                            error = tostring(options.error) or "[This error has no error text.]",
                                                            trace = options.trace,
                                                            context = options.context,
                                                            kind = options.kind,
                                                            parent = parent_error,
                                                            createdTick = os.clock(),
                                                            createdTrace = debug.traceback(),
                                                        }, PromiseErrorMetatable)
                                                    end

                                                    function PromiseErrorMetatable.is(obj)
                                                        if type(obj) == "table" then
                                                            local mt = getmetatable(obj)
                                                            if type(mt) == "table" then return rawget(obj, "error") ~= nil and type(rawget(mt, "extend")) == "function" end
                                                        end
                                                        return false
                                                    end

                                                    function PromiseErrorMetatable.isKind(obj, kind)
                                                        assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")
                                                        return PromiseErrorMetatable.is(obj) and obj.kind == kind
                                                    end

                                                    function PromiseErrorMetatable.extend(self, options)
                                                        options = options or {}
                                                        options.kind = options.kind or self.kind
                                                        return PromiseErrorMetatable.new(options, self)
                                                    end

                                                    function PromiseErrorMetatable.getErrorChain(self)
                                                        local chain = { self }
                                                        while chain[#chain].parent do
                                                            table.insert(chain, chain[#chain].parent)
                                                        end
                                                        return chain
                                                    end

                                                    function PromiseErrorMetatable.__tostring(self)
                                                        local parts = {
                                                            string.format("-- Promise.Error(%s) --", self.kind or "?"),
                                                        }
                                                        for _, error_obj in ipairs(self:getErrorChain()) do
                                                            table.insert(
                                                                parts,
                                                                table.concat({
                                                                    error_obj.trace or error_obj.error,
                                                                    error_obj.context,
                                                                }, "\n")
                                                            )
                                                        end
                                                        return table.concat(parts, "\n")
                                                    end
                                                end

                                                local function pack_args(...) return select("#", ...), { ... } end
                                                local function pack_xpcall_result(success, ...) return success, select("#", ...), { ... } end

                                                local function wrap_error(traceback_info)
                                                    assert(traceback_info ~= nil, "traceback is nil")
                                                    return function(err)
                                                        if type(err) == "table" then return err end
                                                        return PromiseErrorMetatable.new({
                                                            error = err,
                                                            kind = PromiseErrorMetatable.Kind.ExecutionError,
                                                            trace = debug.traceback(tostring(err), 2),
                                                            context = "Promise created at:\n\n" .. traceback_info,
                                                        })
                                                    end
                                                end

                                                local function protected_call(traceback_info, func, ...)
                                                    return pack_xpcall_result(xpcall(func, wrap_error(traceback_info), ...))
                                                end

                                                local function create_handler_wrapper(traceback_info, resolve_func, reject_func, cancel_func)
                                                    return function(...)
                                                        local success, num_results, results = protected_call(traceback_info, resolve_func, ...)
                                                        if success then reject_func(unpack(results, 1, num_results)) else cancel_func(results[1]) end
                                                    end
                                                end

                                                local function is_empty_table(t) return next(t) == nil end

                                                local Promise = {
                                                    Error = PromiseErrorMetatable,
                                                    Status = create_status_enum("Promise.Status", { "Started", "Resolved", "Rejected", "Cancelled" }),
                                                    _getTime = os.clock,
                                                    _timeEvent = game:GetService"RunService".Heartbeat,
                                                    _unhandledRejectionCallbacks = {},
                                                }
                                                Promise.prototype = {}
                                                Promise.__index = Promise.prototype

                                                function Promise._new(source_trace, executor, parent_promise)
                                                    if parent_promise ~= nil and not Promise.is(parent_promise) then error("Argument #2 to Promise.new must be a promise or nil", 2) end
                                                    local self = {
                                                        _thread = nil,
                                                        _source = source_trace,
                                                        _status = Promise.Status.Started,
                                                        _values = nil,
                                                        _valuesLength = -1,
                                                        _unhandledRejection = true,
                                                        _queuedResolve = {},
                                                        _queuedReject = {},
                                                        _queuedFinally = {},
                                                        _cancellationHook = nil,
                                                        _parent = parent_promise,
                                                        _consumers = setmetatable({}, PROMISE_CONSUMER_METATABLE),
                                                    }

                                                    if parent_promise and parent_promise._status == Promise.Status.Started then
                                                        parent_promise._consumers[self] = true
                                                    end

                                                    setmetatable(self, Promise)

                                                    local function resolve_callback(...) self:_resolve(...) end
                                                    local function reject_callback(...) self:_reject(...) end
                                                    local function cancellation_handler(cancel_func)
                                                        if cancel_func then
                                                            if self._status == Promise.Status.Cancelled then cancel_func() else self._cancellationHook = cancel_func end
                                                        end
                                                        return self._status == Promise.Status.Cancelled
                                                    end

                                                    self._thread = coroutine.create(function()
                                                        local success, num_results, results = protected_call(self._source, executor, resolve_callback, reject_callback, cancellation_handler)
                                                        if not success then reject_callback(results[1]) end
                                                    end)
                                                    task.spawn(self._thread)
                                                    return self
                                                end

                                                function Promise.new(executor)
                                                    return Promise._new(debug.traceback(nil, 2), executor)
                                                end

                                                function Promise.__tostring(self)
                                                    return string.format("Promise(%s)", self._status)
                                                end

                                                function Promise.defer(func)
                                                    local source_trace = debug.traceback(nil, 2)
                                                    local promise
                                                    promise = Promise._new(source_trace, function(resolve, reject, cancel)
                                                        local connection
                                                        connection = Promise._timeEvent:Connect(function()
                                                            connection:Disconnect()
                                                            local success, num_results, results = protected_call(source_trace, func, resolve, reject, cancel)
                                                            if not success then reject(results[1]) end
                                                        end)
                                                    end)
                                                    return promise
                                                end
                                                Promise.async = Promise.defer

                                                function Promise.resolve(...)
                                                    local num_args, args = pack_args(...)
                                                    return Promise._new(debug.traceback(nil, 2), function(resolve)
                                                        resolve(unpack(args, 1, num_args))
                                                    end)
                                                end

                                                function Promise.reject(...)
                                                    local num_args, args = pack_args(...)
                                                    return Promise._new(debug.traceback(nil, 2), function(resolve, reject)
                                                        reject(unpack(args, 1, num_args))
                                                    end)
                                                end

                                                function Promise._try(source_trace, func, ...)
                                                    local num_args, args = pack_args(...)
                                                    return Promise._new(source_trace, function(resolve)
                                                        resolve(func(unpack(args, 1, num_args)))
                                                    end)
                                                end

                                                function Promise.try(func, ...)
                                                    return Promise._try(debug.traceback(nil, 2), func, ...)
                                                end

                                                function Promise._all(source_trace, promises, expected_count)
                                                    if type(promises) ~= "table" then error(string.format(ERROR_PROMISE_LIST, "Promise.all"), 3) end
                                                    for i, p in pairs(promises) do
                                                        if not Promise.is(p) then error(string.format(ERROR_NON_PROMISE_VALUE, "Promise.all", tostring(i)), 3) end
                                                    end

                                                    if #promises == 0 or expected_count == 0 then return Promise.resolve({}) end

                                                    return Promise._new(source_trace, function(resolve, reject, cancel_hook)
                                                        local results = {}
                                                        local connections = {}
                                                        local resolved_count = 0
                                                        local rejected_count = 0
                                                        local finished = false

                                                        local function cancel_all()
                                                            for _, conn in ipairs(connections) do conn:cancel() end
                                                        end

                                                        local function handle_resolve(index, ...)
                                                            if finished then return end
                                                            resolved_count = resolved_count + 1
                                                            if expected_count == nil then
                                                                results[index] = ...
                                                            else
                                                                results[resolved_count] = ...
                                                            end

                                                            if resolved_count >= (expected_count or #promises) then
                                                                finished = true
                                                                resolve(results)
                                                                cancel_all()
                                                            end
                                                        end

                                                        cancel_hook(cancel_all)

                                                        for i, p in ipairs(promises) do
                                                            connections[i] = p:andThen(function(...)
                                                                handle_resolve(i, ...)
                                                            end, function(...)
                                                                rejected_count = rejected_count + 1
                                                                if expected_count == nil or #promises - rejected_count < expected_count then
                                                                    cancel_all()
                                                                    finished = true
                                                                    reject(...)
                                                                end
                                                            end)
                                                        end

                                                        if finished then cancel_all() end
                                                    end)
                                                end

                                                function Promise.all(promises)
                                                    return Promise._all(debug.traceback(nil, 2), promises)
                                                end

                                                function Promise.fold(list, func, initial_value)
                                                    assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
                                                    assert(is_callable(func), "Bad argument #2 to Promise.fold: must be a function")
                                                    local folded_promise = Promise.resolve(initial_value)
                                                    return Promise.each(list, function(value, index)
                                                        folded_promise = folded_promise:andThen(function(current_value)
                                                            return func(current_value, value, index)
                                                        end)
                                                    end):andThen(function()
                                                        return folded_promise
                                                    end)
                                                end

                                                function Promise.some(promises, count)
                                                    assert(type(count) == "number", "Bad argument #2 to Promise.some: must be a number")
                                                    return Promise._all(debug.traceback(nil, 2), promises, count)
                                                end

                                                function Promise.any(promises)
                                                    return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(results)
                                                        return results[1]
                                                    end)
                                                end

                                                function Promise.allSettled(promises)
                                                    if type(promises) ~= "table" then error(string.format(ERROR_PROMISE_LIST, "Promise.allSettled"), 2) end
                                                    for i, p in pairs(promises) do
                                                        if not Promise.is(p) then error(string.format(ERROR_NON_PROMISE_VALUE, "Promise.allSettled", tostring(i)), 2) end
                                                    end

                                                    if #promises == 0 then return Promise.resolve({}) end

                                                    return Promise._new(debug.traceback(nil, 2), function(resolve, reject, cancel_hook)
                                                        local results = {}
                                                        local connections = {}
                                                        local settled_count = 0

                                                        local function handle_settle(index, ...)
                                                            settled_count = settled_count + 1
                                                            results[index] = ...
                                                            if settled_count >= #promises then resolve(results) end
                                                        end

                                                        cancel_hook(function() for _, conn in ipairs(connections) do conn:cancel() end end)

                                                        for i, p in ipairs(promises) do
                                                            connections[i] = p:finally(function(...) handle_settle(i, ...) end)
                                                        end
                                                    end)
                                                end

                                                function Promise.race(promises)
                                                    assert(type(promises) == "table", string.format(ERROR_PROMISE_LIST, "Promise.race"))
                                                    for i, p in pairs(promises) do
                                                        assert(Promise.is(p), string.format(ERROR_NON_PROMISE_VALUE, "Promise.race", tostring(i)))
                                                    end

                                                    return Promise._new(debug.traceback(nil, 2), function(resolve, reject, cancel_hook)
                                                        local connections = {}
                                                        local resolved = false

                                                        local function cancel_all()
                                                            for _, conn in ipairs(connections) do conn:cancel() end
                                                        end

                                                        local function resolve_once(resolver)
                                                            return function(...)
                                                                cancel_all()
                                                                resolved = true
                                                                return resolver(...)
                                                            end
                                                        end

                                                        if cancel_hook(resolve_once(reject)) then return end

                                                        for i, p in ipairs(promises) do
                                                            connections[i] = p:andThen(resolve_once(resolve), resolve_once(reject))
                                                        end

                                                        if resolved then cancel_all() end
                                                    end)
                                                end

                                                function Promise.each(list, func)
                                                    assert(type(list) == "table", string.format(ERROR_PROMISE_LIST, "Promise.each"))
                                                    assert(is_callable(func), string.format(ERROR_HANDLER_FUNCTION, "Promise.each"))

                                                    return Promise._new(debug.traceback(nil, 2), function(resolve, reject, cancel_hook)
                                                        local results = {}
                                                        local connections = {}
                                                        local cancelled = false

                                                        local function cancel_all()
                                                            for _, conn in ipairs(connections) do conn:cancel() end
                                                        end

                                                        cancel_hook(function() cancelled = true; cancel_all() end)

                                                        local processed_list = {}
                                                        for i, item in ipairs(list) do
                                                            if Promise.is(item) then
                                                                if item:getStatus() == Promise.Status.Cancelled then
                                                                    cancel_all()
                                                                    return reject(PromiseErrorMetatable.new({
                                                                        error = "Promise is cancelled",
                                                                        kind = PromiseErrorMetatable.Kind.AlreadyCancelled,
                                                                        context = string.format(
                                                                            "The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
                                                                            i, item._source
                                                                        ),
                                                                    }))
                                                                elseif item:getStatus() == Promise.Status.Rejected then
                                                                    cancel_all()
                                                                    return reject(select(2, item:await()))
                                                                end
                                                                local chained = item:andThen(function(...) return ... end)
                                                                table.insert(connections, chained)
                                                                processed_list[i] = chained
                                                            else
                                                                processed_list[i] = item
                                                            end
                                                        end

                                                        for i, item in ipairs(processed_list) do
                                                            if Promise.is(item) then
                                                                local success, val = item:await()
                                                                if not success then
                                                                    cancel_all()
                                                                    return reject(val)
                                                                end
                                                                item = val
                                                            end

                                                            if cancelled then return end

                                                            local result_promise = Promise.resolve(func(item, i))
                                                            table.insert(connections, result_promise)
                                                            local success, result_val = result_promise:await()
                                                            if not success then
                                                                cancel_all()
                                                                return reject(result_val)
                                                            end
                                                            results[i] = result_val
                                                        end
                                                        resolve(results)
                                                    end)
                                                end

                                                function Promise.is(obj)
                                                    if type(obj) ~= "table" then return false end
                                                    local mt = getmetatable(obj)
                                                    if mt == Promise then return true
                                                    elseif mt == nil then return is_callable(obj.andThen)
                                                    elseif type(mt) == "table" and type(rawget(rawget(mt, "__index"), "andThen")) == "function" then return true
                                                    end
                                                    return false
                                                end

                                                function Promise.promisify(func)
                                                    return function(...)
                                                        return Promise._try(debug.traceback(nil, 2), func, ...)
                                                    end
                                                end

                                                do
                                                    local first_delay_node
                                                    local delay_connection

                                                    function Promise.delay(seconds)
                                                        assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
                                                        if not (seconds >= 0.016666666666666666) or seconds == math.huge then seconds = 0.016666666666666666 end

                                                        return Promise._new(debug.traceback(nil, 2), function(resolve, reject, cancel_hook)
                                                            local start_time = Promise._getTime()
                                                            local end_time = start_time + seconds
                                                            local new_delay_node = { resolve = resolve, startTime = start_time, endTime = end_time, }

                                                            if delay_connection == nil then
                                                                first_delay_node = new_delay_node
                                                                delay_connection = Promise._timeEvent:Connect(function()
                                                                    local current_time = Promise._getTime()
                                                                    while first_delay_node ~= nil and first_delay_node.endTime < current_time do
                                                                        local completed_node = first_delay_node
                                                                        first_delay_node = completed_node.next
                                                                        if first_delay_node == nil then delay_connection:Disconnect(); delay_connection = nil
                                                                        else first_delay_node.previous = nil end
                                                                        completed_node.resolve(Promise._getTime() - completed_node.startTime)
                                                                    end
                                                                end)
                                                            else
                                                                if first_delay_node.endTime < end_time then
                                                                    local current = first_delay_node
                                                                    local next_node = current.next
                                                                    while next_node ~= nil and next_node.endTime < end_time do
                                                                        current = next_node
                                                                        next_node = current.next
                                                                    end
                                                                    current.next = new_delay_node
                                                                    new_delay_node.previous = current
                                                                    if next_node ~= nil then new_delay_node.next = next_node; next_node.previous = new_delay_node end
                                                                else
                                                                    new_delay_node.next = first_delay_node
                                                                    first_delay_node.previous = new_delay_node
                                                                    first_delay_node = new_delay_node
                                                                end
                                                            end

                                                            cancel_hook(function()
                                                                local next_node = new_delay_node.next
                                                                if first_delay_node == new_delay_node then
                                                                    if next_node == nil then delay_connection:Disconnect(); delay_connection = nil
                                                                    else next_node.previous = nil end
                                                                    first_delay_node = next_node
                                                                else
                                                                    local prev_node = new_delay_node.previous
                                                                    prev_node.next = next_node
                                                                    if next_node ~= nil then next_node.previous = prev_node end
                                                                end
                                                            end)
                                                        end)
                                                    end
                                                end

                                                function Promise.prototype.timeout(self, seconds, error_value)
                                                    local source_trace = debug.traceback(nil, 2)
                                                    return Promise.race({
                                                        Promise.delay(seconds):andThen(function()
                                                            return Promise.reject(error_value == nil and PromiseErrorMetatable.new({
                                                                kind = PromiseErrorMetatable.Kind.TimedOut,
                                                                error = "Timed out",
                                                                context = string.format(
                                                                    "Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
                                                                    seconds, source_trace
                                                                ),
                                                            }) or error_value)
                                                        end),
                                                        self,
                                                    })
                                                end

                                                function Promise.prototype.getStatus(self) return self._status end

                                                function Promise.prototype._andThen(self, source_trace, resolve_handler, reject_handler)
                                                    self._unhandledRejection = false
                                                    if self._status == Promise.Status.Cancelled then
                                                        local cancelled_promise = Promise.new(function() end)
                                                        cancelled_promise:cancel()
                                                        return cancelled_promise
                                                    end

                                                    return Promise._new(source_trace, function(resolve, reject, cancel_hook)
                                                        local actual_resolve = resolve
                                                        if resolve_handler then actual_resolve = create_handler_wrapper(source_trace, resolve_handler, resolve, reject) end
                                                        local actual_reject = reject
                                                        if reject_handler then actual_reject = create_handler_wrapper(source_trace, reject_handler, resolve, reject) end

                                                        if self._status == Promise.Status.Started then
                                                            table.insert(self._queuedResolve, actual_resolve)
                                                            table.insert(self._queuedReject, actual_reject)
                                                            cancel_hook(function()
                                                                if self._status == Promise.Status.Started then
                                                                    table.remove(self._queuedResolve, table.find(self._queuedResolve, actual_resolve))
                                                                    table.remove(self._queuedReject, table.find(self._queuedReject, actual_reject))
                                                                end
                                                            end)
                                                        elseif self._status == Promise.Status.Resolved then
                                                            actual_resolve(unpack(self._values, 1, self._valuesLength))
                                                        elseif self._status == Promise.Status.Rejected then
                                                            actual_reject(unpack(self._values, 1, self._valuesLength))
                                                        end
                                                    end, self)
                                                end

                                                function Promise.prototype.andThen(self, resolve_handler, reject_handler)
                                                    assert(resolve_handler == nil or is_callable(resolve_handler), string.format(ERROR_HANDLER_FUNCTION, "Promise:andThen"))
                                                    assert(reject_handler == nil or is_callable(reject_handler), string.format(ERROR_HANDLER_FUNCTION, "Promise:andThen"))
                                                    return self:_andThen(debug.traceback(nil, 2), resolve_handler, reject_handler)
                                                end

                                                function Promise.prototype.catch(self, reject_handler)
                                                    assert(reject_handler == nil or is_callable(reject_handler), string.format(ERROR_HANDLER_FUNCTION, "Promise:catch"))
                                                    return self:_andThen(debug.traceback(nil, 2), nil, reject_handler)
                                                end

                                                function Promise.prototype.tap(self, tap_handler)
                                                    assert(is_callable(tap_handler), string.format(ERROR_HANDLER_FUNCTION, "Promise:tap"))
                                                    return self:_andThen(debug.traceback(nil, 2), function(...)
                                                        local tapped_result = tap_handler(...)
                                                        if Promise.is(tapped_result) then
                                                            local num_args, args = pack_args(...)
                                                            return tapped_result:andThen(function() return unpack(args, 1, num_args) end)
                                                        end
                                                        return ...
                                                    end)
                                                end

                                                function Promise.prototype.andThenCall(self, func, ...)
                                                    assert(is_callable(func), string.format(ERROR_HANDLER_FUNCTION, "Promise:andThenCall"))
                                                    local num_args, args = pack_args(...)
                                                    return self:_andThen(debug.traceback(nil, 2), function() return func(unpack(args, 1, num_args)) end)
                                                end

                                                function Promise.prototype.andThenReturn(self, ...)
                                                    local num_args, args = pack_args(...)
                                                    return self:_andThen(debug.traceback(nil, 2), function() return unpack(args, 1, num_args) end)
                                                end

                                                function Promise.prototype.cancel(self)
                                                    if self._status ~= Promise.Status.Started then return end
                                                    self._status = Promise.Status.Cancelled
                                                    if self._cancellationHook then self._cancellationHook() end
                                                    coroutine.close(self._thread)
                                                    if self._parent then self._parent:_consumerCancelled(self) end
                                                    for consumer_promise in pairs(self._consumers) do consumer_promise:cancel() end
                                                    self:_finalize()
                                                end

                                                function Promise.prototype._consumerCancelled(self, consumer_promise)
                                                    if self._status ~= Promise.Status.Started then return end
                                                    self._consumers[consumer_promise] = nil
                                                    if next(self._consumers) == nil then self:cancel() end
                                                end

                                                function Promise.prototype._finally(self, source_trace, finally_handler)
                                                    self._unhandledRejection = false
                                                    local new_promise = Promise._new(source_trace, function(resolve, reject, cancel_hook)
                                                        local finally_chain_promise
                                                        cancel_hook(function()
                                                            self:_consumerCancelled(self)
                                                            if finally_chain_promise then finally_chain_promise:cancel() end
                                                        end)

                                                        local resolve_with_original_status = resolve
                                                        if finally_handler then
                                                            resolve_with_original_status = function(...)
                                                                local result = finally_handler(...)
                                                                if Promise.is(result) then
                                                                    finally_chain_promise = result
                                                                    result:finally(function(status)
                                                                        if status ~= Promise.Status.Rejected then resolve(self) end
                                                                    end):catch(function(...) reject(...) end)
                                                                else
                                                                    resolve(self)
                                                                end
                                                            end
                                                        end

                                                        if self._status == Promise.Status.Started then
                                                            table.insert(self._queuedFinally, resolve_with_original_status)
                                                        else
                                                            resolve_with_original_status(self._status)
                                                        end
                                                    end)
                                                    return new_promise
                                                end

                                                function Promise.prototype.finally(self, finally_handler)
                                                    assert(finally_handler == nil or is_callable(finally_handler), string.format(ERROR_HANDLER_FUNCTION, "Promise:finally"))
                                                    return self:_finally(debug.traceback(nil, 2), finally_handler)
                                                end

                                                function Promise.prototype.finallyCall(self, func, ...)
                                                    assert(is_callable(func), string.format(ERROR_HANDLER_FUNCTION, "Promise:finallyCall"))
                                                    local num_args, args = pack_args(...)
                                                    return self:_finally(debug.traceback(nil, 2), function() return func(unpack(args, 1, num_args)) end)
                                                end

                                                function Promise.prototype.finallyReturn(self, ...)
                                                    local num_args, args = pack_args(...)
                                                    return self:_finally(debug.traceback(nil, 2), function() return unpack(args, 1, num_args) end)
                                                end

                                                function Promise.prototype.awaitStatus(self)
                                                    self._unhandledRejection = false
                                                    if self._status == Promise.Status.Started then
                                                        local current_thread = coroutine.running()
                                                        self:finally(function() task.spawn(current_thread) end):catch(function() end)
                                                        coroutine.yield()
                                                    end

                                                    if self._status == Promise.Status.Resolved then
                                                        return self._status, unpack(self._values, 1, self._valuesLength)
                                                    elseif self._status == Promise.Status.Rejected then
                                                        return self._status, unpack(self._values, 1, self._valuesLength)
                                                    end
                                                    return self._status
                                                end

                                                local function extract_resolved_values(status, ...) return status == Promise.Status.Resolved, ... end

                                                function Promise.prototype.await(self)
                                                    return extract_resolved_values(self:awaitStatus())
                                                end

                                                local function check_and_unwrap_error(status, ...)
                                                    if status ~= Promise.Status.Resolved then
                                                        error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
                                                    end
                                                    return ...
                                                end

                                                function Promise.prototype.expect(self)
                                                    return check_and_unwrap_error(self:awaitStatus())
                                                end
                                                Promise.prototype.awaitValue = Promise.prototype.expect

                                                function Promise.prototype._unwrap(self)
                                                    if self._status == Promise.Status.Started then error("Promise has not resolved or rejected.", 2) end
                                                    local is_resolved = self._status == Promise.Status.Resolved
                                                    return is_resolved, unpack(self._values, 1, self._valuesLength)
                                                end

                                                function Promise.prototype._resolve(self, ...)
                                                    if self._status ~= Promise.Status.Started then
                                                        if Promise.is((...)) then (...):_consumerCancelled(self) end
                                                        return
                                                    end

                                                    if Promise.is((...)) then
                                                        if select("#", ...) > 1 then
                                                            local warning_message = string.format([[When returning a Promise from andThen, extra arguments are discarded! See:%s]], self._source)
                                                            warn(warning_message)
                                                        end
                                                        local chained_promise = ...
                                                        local new_chain = chained_promise:andThen(function(...)
                                                            self:_resolve(...)
                                                        end, function(...)
                                                            local error_value = chained_promise._values[1]
                                                            if chained_promise._error then
                                                                error_value = PromiseErrorMetatable.new({
                                                                    error = chained_promise._error,
                                                                    kind = PromiseErrorMetatable.Kind.ExecutionError,
                                                                    context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
                                                                })
                                                            end
                                                            if PromiseErrorMetatable.isKind(error_value, PromiseErrorMetatable.Kind.ExecutionError) then
                                                                return self:_reject(error_value:extend({
                                                                    error = "This Promise was chained to a Promise that errored.",
                                                                    trace = "",
                                                                    context = string.format(
                                                                        "The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
                                                                        self._source
                                                                    ),
                                                                }))
                                                            end
                                                            self:_reject(...)
                                                        end)

                                                        if new_chain._status == Promise.Status.Cancelled then
                                                            self:cancel()
                                                        elseif new_chain._status == Promise.Status.Started then
                                                            self._parent = new_chain
                                                            new_chain._consumers[self] = true
                                                        end
                                                        return
                                                    end

                                                    self._status = Promise.Status.Resolved
                                                    self._valuesLength, self._values = pack_args(...)
                                                    for _, handler in ipairs(self._queuedResolve) do coroutine.wrap(handler)(...) end
                                                    self:_finalize()
                                                end

                                                function Promise.prototype._reject(self, ...)
                                                    if self._status ~= Promise.Status.Started then return end
                                                    self._status = Promise.Status.Rejected
                                                    self._valuesLength, self._values = pack_args(...)

                                                    if not is_empty_table(self._queuedReject) then
                                                        for _, handler in ipairs(self._queuedReject) do coroutine.wrap(handler)(...) end
                                                    else
                                                        local error_message = tostring((...))
                                                        coroutine.wrap(function()
                                                            Promise._timeEvent:Wait()
                                                            if not self._unhandledRejection then return end
                                                            local full_error_message = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", error_message, self._source)
                                                            for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
                                                                task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
                                                            end
                                                            if Promise.TEST then return end
                                                            warn(full_error_message)
                                                        end)()
                                                    end
                                                    self:_finalize()
                                                end

                                                function Promise.prototype._finalize(self)
                                                    for _, handler in ipairs(self._queuedFinally) do coroutine.wrap(handler)(self._status) end
                                                    self._queuedFinally = nil
                                                    self._queuedReject = nil
                                                    self._queuedResolve = nil
                                                    if not Promise.TEST then
                                                        self._parent = nil
                                                        self._consumers = nil
                                                    end
                                                    task.defer(coroutine.close, self._thread)
                                                end

                                                function Promise.prototype.now(self, error_value)
                                                    local source_trace = debug.traceback(nil, 2)
                                                    if self._status == Promise.Status.Resolved then
                                                        return self:_andThen(source_trace, function(...) return ... end)
                                                    else
                                                        return Promise.reject(error_value == nil and PromiseErrorMetatable.new({
                                                            kind = PromiseErrorMetatable.Kind.NotResolvedInTime,
                                                            error = "This Promise was not resolved in time for :now()",
                                                            context = ":now() was called at:\n\n" .. source_trace,
                                                        }) or error_value)
                                                    end
                                                end

                                                function Promise.retry(func, times, ...)
                                                    assert(is_callable(func), "Parameter #1 to Promise.retry must be a function")
                                                    assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")
                                                    local num_args, args = pack_args(...)
                                                    return Promise.resolve(func(...)):catch(function(...)
                                                        if times > 0 then return Promise.retry(func, times - 1, unpack(args, 1, num_args))
                                                        else return Promise.reject(...) end
                                                    end)
                                                end

                                                function Promise.retryWithDelay(func, times, seconds, ...)
                                                    assert(is_callable(func), "Parameter #1 to Promise.retry must be a function")
                                                    assert(type(times) == "number", "Parameter #2 (times) to Promise.retry must be a number")
                                                    assert(type(seconds) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")
                                                    local num_args, args = pack_args(...)
                                                    return Promise.resolve(func(...)):catch(function(...)
                                                        if times > 0 then
                                                            Promise.delay(seconds):await()
                                                            return Promise.retryWithDelay(func, times - 1, seconds, unpack(args, 1, num_args))
                                                        else return Promise.reject(...) end
                                                    end)
                                                end

                                                function Promise.fromEvent(event, predicate)
                                                    predicate = predicate or function() return true end
                                                    return Promise._new(debug.traceback(nil, 2), function(resolve, reject, cancel_hook)
                                                        local connection
                                                        local resolved_early = false
                                                        local function disconnect_event() connection:Disconnect(); connection = nil end

                                                        connection = event:Connect(function(...)
                                                            local result = predicate(...)
                                                            if result == true then
                                                                resolve(...)
                                                                if connection then disconnect_event() else resolved_early = true end
                                                            elseif type(result) ~= "boolean" then
                                                                error"Promise.fromEvent predicate should always return a boolean"
                                                            end
                                                        end)

                                                        if resolved_early and connection then return disconnect_event() end
                                                        cancel_hook(disconnect_event)
                                                    end)
                                                end

                                                function Promise.onUnhandledRejection(callback)
                                                    table.insert(Promise._unhandledRejectionCallbacks, callback)
                                                    return function()
                                                        local index = table.find(Promise._unhandledRejectionCallbacks, callback)
                                                        if index then table.remove(Promise._unhandledRejectionCallbacks, index) end
                                                    end
                                                end

                                                return Promise
                                            end
                                        end,
                                        Properties = { Name = "Promise" },
                                        Reference = 54,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        ClassName = "ModuleScript",
                                        Closure = function()
                                            return function(Library)
                                                local TableUtil = {}
                                                Library.SetupLazyLoader(script, TableUtil)
                                                return TableUtil
                                            end
                                        end,
                                        Properties = { Name = "TableUtil" },
                                        Reference = 57,
                                        Children = {
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        local Services = Library.Services
                                                        local HttpService = Services.HttpService
                                                        local clonefunction = clonefunction or function(func) return func end

                                                        local function deep_clone_recursive(obj, visited_tables)
                                                            visited_tables = visited_tables or {}
                                                            local obj_type = typeof(obj);
                                                            if obj_type == 'table' then
                                                                if visited_tables[obj] then return visited_tables[obj]
                                                                else
                                                                    local new_table = {}
                                                                    visited_tables[obj] = new_table
                                                                    for key, value in next, obj do
                                                                        new_table[deep_clone_recursive(key, visited_tables)] = deep_clone_recursive(value, visited_tables)
                                                                    end;
                                                                    setmetatable(new_table, deep_clone_recursive(getmetatable(obj), visited_tables))
                                                                    return new_table
                                                                end
                                                            elseif obj_type == 'function' then return clonefunction(obj)
                                                            else return obj end
                                                        end

                                                        return function(obj, use_fast_clone)
                                                            if use_fast_clone then return deep_clone_recursive(obj) end
                                                            return HttpService:JSONDecode(HttpService:JSONEncode(obj))
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "Clone" },
                                                Reference = 58,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(...)
                                                            local combined = {};
                                                            for _, array in { ... } do
                                                                for _, value in array do
                                                                    table.insert(combined, value)
                                                                end
                                                            end
                                                            return combined
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "JoinArrays" },
                                                Reference = 60,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(dictionary)
                                                            local keys = {};
                                                            for key in dictionary do
                                                                table.insert(keys, key)
                                                            end
                                                            return keys
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "Keys" },
                                                Reference = 59,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(dictionary)
                                                            local values = {};
                                                            for _, value in dictionary do
                                                                table.insert(values, value)
                                                            end
                                                            return values
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "Values" },
                                                Reference = 61,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(input_table, map_function)
                                                            local mapped_table = {};
                                                            for key, value in input_table do
                                                                map_function(value, key, mapped_table);
                                                            end
                                                            return mapped_table
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "Map" },
                                                Reference = 63,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(...)
                                                            local combined = {};
                                                            for _, dictionary in { ... } do
                                                                for key, value in dictionary do
                                                                    combined[key] = value
                                                                end
                                                            end
                                                            return combined
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "JoinDictionaries" },
                                                Reference = 62,
                                                ClassName = "ModuleScript"
                                            },
                                            {
                                                Closure = function()
                                                    return function(Library)
                                                        return function(dictionary)
                                                            local count = 0;
                                                            for _ in dictionary do
                                                                count = count + 1
                                                            end
                                                            return count
                                                        end
                                                    end
                                                end,
                                                Properties = { Name = "GetDictionarySize" },
                                                Reference = 64,
                                                ClassName = "ModuleScript"
                                            }
                                        }
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local TreeCache = Library.Cache.TreeCache
                                                local Tree = { Delimiter = "/" };
                                                local WaitForChild = game.WaitForChild
                                                local FindFirstChild = game.FindFirstChild

                                                local function find_and_cache(path, root_instance, wait_for_child_timeout)
                                                    local cached = TreeCache[path];
                                                    if cached then return cached end;

                                                    local path_parts = string.split(path, Tree.Delimiter);
                                                    for _, part in path_parts do
                                                        root_instance = FindFirstChild(root_instance, part) or (wait_for_child_timeout and WaitForChild(root_instance, part, wait_for_child_timeout)) or nil;
                                                        if (not root_instance) then return nil end;
                                                    end
                                                    TreeCache[path] = root_instance;
                                                    return root_instance
                                                end

                                                function Tree.SetDelimiter(delimiter) Tree.Delimiter = delimiter or "/" end

                                                function Tree.Find(root_instance, path)
                                                    local found = find_and_cache(path, root_instance);
                                                    return found
                                                end

                                                function Tree.Await(root_instance, path, timeout)
                                                    local found = find_and_cache(path, root_instance, timeout);
                                                    return found
                                                end

                                                return Tree
                                            end
                                        end,
                                        Properties = { Name = "Tree" },
                                        Reference = 56,
                                        ClassName = "ModuleScript"
                                    },
                                    {
                                        Closure = function()
                                            return function(Library)
                                                local Services = Library.Services
                                                local RunService = Services.RunService
                                                local func_cleanup_marker = newproxy()
                                                local thread_cleanup_marker = newproxy()
                                                local cleanup_function_names = table.freeze({ "Destroy", "Disconnect", "destroy", "disconnect" })

                                                local function get_cleanup_function_name(obj, custom_name)
                                                    local obj_type = typeof(obj)
                                                    if obj_type == "function" then return func_cleanup_marker
                                                    elseif obj_type == "thread" then return thread_cleanup_marker end
                                                    if custom_name then return custom_name end

                                                    if obj_type == "Instance" or obj_type == "DrawingObject" then return "Destroy"
                                                    elseif obj_type == "RBXScriptConnection" then return "Disconnect"
                                                    elseif obj_type == "table" then
                                                        for _, name in cleanup_function_names do
                                                            if typeof(obj[name]) == "function" then return name end
                                                        end
                                                    end
                                                    error(string.format('failed to get cleanup function for object %s: %s', tostring(obj_type), tostring(obj)), 3)
                                                end

                                                local function assert_is_promise(obj)
                                                    if typeof(obj) ~= "table" or typeof(obj.getStatus) ~= "function" or typeof(obj.finally) ~= "function" or typeof(obj.cancel) ~= "function" then
                                                        error("did not receive a promise as an argument", 3)
                                                    end
                                                end

                                                local TroveMetatable = {}
                                                TroveMetatable.__index = TroveMetatable
                                                function TroveMetatable.new()
                                                    local self = setmetatable({}, TroveMetatable)
                                                    self._objects = {}
                                                    self._cleaning = false
                                                    return self
                                                end

                                                function TroveMetatable.Add(self, obj, cleanup_func_name)
                                                    if self._cleaning then error("cannot call trove:Add() while cleaning", 2) end
                                                    local cleanup_name = get_cleanup_function_name(obj, cleanup_func_name)
                                                    table.insert(self._objects, { obj, cleanup_name })
                                                    return obj
                                                end

                                                function TroveMetatable.Clone(self, instance_to_clone)
                                                    if self._cleaning then error("cannot call trove:Clone() while cleaning", 2) end
                                                    return self:Add(instance_to_clone:Clone())
                                                end

                                                function TroveMetatable.Construct(self, constructor, ...)
                                                    if self._cleaning then error("Cannot call trove:Construct() while cleaning", 2) end
                                                    local instance;
                                                    local constructor_type = type(constructor)
                                                    if constructor_type == "table" then instance = constructor.new(...)
                                                    elseif constructor_type == "function" then instance = constructor(...) end
                                                    return self:Add(instance)
                                                end

                                                function TroveMetatable.Connect(self, signal, handler)
                                                    if self._cleaning then error("Cannot call trove:Connect() while cleaning", 2) end
                                                    return self:Add(signal:Connect(handler))
                                                end

                                                function TroveMetatable.BindToRenderStep(self, name, priority, func)
                                                    if self._cleaning then error("cannot call trove:BindToRenderStep() while cleaning", 2) end
                                                    RunService:BindToRenderStep(name, priority, func)
                                                    self:Add(function() RunService:UnbindFromRenderStep(name) end)
                                                end

                                                function TroveMetatable.AddPromise(self, promise)
                                                    if self._cleaning then error("cannot call trove:AddPromise() while cleaning", 2) end
                                                    assert_is_promise(promise)
                                                    if promise:getStatus() == "Started" then
                                                        promise:finally(function()
                                                            if self._cleaning then return end
                                                            self:_findAndRemoveFromObjects(promise, false)
                                                        end)
                                                        self:Add(promise, "cancel")
                                                    end
                                                    return promise
                                                end

                                                function TroveMetatable.Remove(self, obj)
                                                    if self._cleaning then error("cannot call trove:Remove() while cleaning", 2) end
                                                    return self:_findAndRemoveFromObjects(obj, true)
                                                end

                                                function TroveMetatable.Extend(self)
                                                    if self._cleaning then error("cannot call trove:Extend() while cleaning", 2) end
                                                    return self:Construct(TroveMetatable)
                                                end

                                                function TroveMetatable.Clean(self)
                                                    if self._cleaning then return end
                                                    self._cleaning = true
                                                    for _, obj_info in self._objects do
                                                        self:_cleanupObject(obj_info[1], obj_info[2])
                                                    end
                                                    table.clear(self._objects)
                                                    self._cleaning = false
                                                end

                                                function TroveMetatable.WrapClean(self)
                                                    return function() self:Clean() end
                                                end

                                                function TroveMetatable._findAndRemoveFromObjects(self, obj_to_remove, perform_cleanup)
                                                    local objects = self._objects
                                                    for i, obj_info in objects do
                                                        if obj_info[1] == obj_to_remove then
                                                            local last_index = #objects
                                                            objects[i] = objects[last_index]
                                                            objects[last_index] = nil
                                                            if perform_cleanup then self:_cleanupObject(obj_info[1], obj_info[2]) end
                                                            return true
                                                        end
                                                    end
                                                    return false
                                                end

                                                function TroveMetatable._cleanupObject(self, obj, cleanup_type)
                                                    if cleanup_type == func_cleanup_marker then task.spawn(obj)
                                                    elseif cleanup_type == thread_cleanup_marker then pcall(task.cancel, obj)
                                                    else obj[cleanup_type](obj) end
                                                end

                                                function TroveMetatable.AttachToInstance(self, instance)
                                                    if self._cleaning then error("cannot call trove:AttachToInstance() while cleaning", 2)
                                                    elseif not instance:IsDescendantOf(game) then error("instance is not a descendant of the game hierarchy", 2) end
                                                    return self:Connect(instance.Destroying, function() self:Destroy() end)
                                                end

                                                function TroveMetatable.Destroy(self) self:Clean() end

                                                return { new = TroveMetatable.new, }
                                            end
                                        end,
                                        Properties = { Name = "Trove" },
                                        Reference = 53,
                                        ClassName = "ModuleScript"
                                    }
                                }
                            }
                        }
                    },
                    {
                        Closure = function()
                            return function(Library)
                                return {
                                    LRM_Variables = {
                                        LRM_IsUserPremium = LRM_IsUserPremium or true,
                                        LRM_LinkedDiscordID = LRM_LinkedDiscordID or 1132756183229419661,
                                        LRM_ScriptName = LRM_ScriptName or "strelizia.cc",
                                        LRM_TotalExecutions = LRM_TotalExecutions or 5,
                                        LRM_SecondsLeft = LRM_SecondsLeft or 300,
                                        LRM_UserNote = LRM_UserNote or "Developer | Premium | Lifetime",
                                        LRM_ScriptVersion = LRM_ScriptVersion or "0.0.0.1"
                                    }
                                }
                            end
                        end,
                        Properties = { Name = "Variables" },
                        Reference = 65,
                        ClassName = "ModuleScript"
                    },
                    {
                        Closure = function()
                            return function(Library)
                                return setmetatable({}, {
                                    __index = function(self, service_name)
                                        local success, service = pcall(game.GetService, game, service_name);
                                        if success then
                                            local cloned_service = cloneref(service)
                                            rawset(self, service_name, cloned_service)
                                            return cloned_service
                                        end
                                        return nil
                                    end,
                                })
                            end
                        end,
                        Properties = { Name = "Services" },
                        Reference = 66,
                        ClassName = "ModuleScript"
                    }
                }
            }
        }
    }
}

do -- Main script execution
    local VERSION, FLAGS, CURRENT_SCRIPT, NEXT_ITERATOR, UNPACK_TABLE, TABLE_LIB, REQUIRE_FUNC, TYPE_FUNC, PCALL_FUNC, GETFENV_FUNC, SETFENV_FUNC, SETMETATABLE_FUNC, RAWGET_FUNC, COROUTINE_LIB, TASK_LIB, INSTANCE_LIB = '0.4.2', Flags or {}, script, next, unpack, table, require, type, pcall, getfenv, setfenv, setmetatable, rawget, coroutine, task, Instance
    local TABLE_INSERT, TABLE_FREEZE, COROUTINE_WRAP, TASK_DEFER, TASK_CANCEL, INSTANCE_NEW = TABLE_LIB.insert, TABLE_LIB.freeze, COROUTINE_LIB.wrap, TASK_LIB.defer, TASK_LIB.cancel, INSTANCE_LIB.new

    local CONTEXTUAL_EXECUTION = (FLAGS.ContextualExecution == nil and true) or FLAGS.ContextualExecution
    local IS_SERVER, IS_CLIENT = false, false
    if CONTEXTUAL_EXECUTION then
        local RunService = game:GetService'RunService'
        IS_SERVER = RunService:IsServer()
        IS_CLIENT = RunService:IsClient()
    end

    local REF_MAP, REF_PROPERTIES, SCRIPT_CLOSURES, INSTANCE_CACHE, PENDING_SCRIPTS, SHARED_ENVIRONMENT = {}, {}, {}, {}, {}, {}

    local function create_instance_from_data(instance_data)
        local success, new_instance = PCALL_FUNC(INSTANCE_NEW, instance_data.ClassName)
        if not success then return end
        REF_MAP[instance_data.Reference] = new_instance

        if instance_data.Closure then SCRIPT_CLOSURES[new_instance] = instance_data.Closure; if new_instance:IsA'BaseScript' then TABLE_INSERT(PENDING_SCRIPTS, new_instance) end end
        if instance_data.Properties then for prop, value in NEXT_ITERATOR, instance_data.Properties do PCALL_FUNC(function() new_instance[prop] = value end) end end
        if instance_data.RefProperties then for prop, ref_id in NEXT_ITERATOR, instance_data.RefProperties do TABLE_INSERT(REF_PROPERTIES, { InstanceObject = new_instance, Property = prop, ReferenceId = ref_id }) end end
        if instance_data.Attributes then for attr, value in NEXT_ITERATOR, instance_data.Attributes do PCALL_FUNC(new_instance.SetAttribute, new_instance, attr, value) end end
        if instance_data.Children then for _, child_data in NEXT_ITERATOR, instance_data.Children do local child_instance = create_instance_from_data(child_data); if child_instance then child_instance.Parent = new_instance end end end
        return new_instance
    end

    local ROOT_INSTANCES = {}
    do for _, data in NEXT_ITERATOR, SCRIPT_DATA do TABLE_INSERT(ROOT_INSTANCES, create_instance_from_data(data)) end end

    local FENV_PLACEHOLDER = GETFENV_FUNC(0)

    local function execute_script_closure(script_instance)
        local closure = SCRIPT_CLOSURES[script_instance]
        if not closure then return end

        local new_fenv
        do
            local script_env
            local environment_data = {
                maui = TABLE_FREEZE({
                    Version = VERSION,
                    Script = CURRENT_SCRIPT,
                    Shared = SHARED_ENVIRONMENT,
                    GetScript = function() return CURRENT_SCRIPT end,
                    GetShared = function() return SHARED_ENVIRONMENT end
                }),
                script = script_instance,
                require = function(module_object, ...)
                    if module_object and module_object.ClassName == 'ModuleScript' and SCRIPT_CLOSURES[module_object] then
                        return execute_script_closure(module_object)
                    end
                    return REQUIRE_FUNC(module_object, ...)
                end,
                getfenv = function(level, ...)
                    if TYPE_FUNC(level) == 'number' and level >= 0 then
                        if level == 0 then return script_env
                        else
                            level = level + 1
                            local success, result_fenv = PCALL_FUNC(GETFENV_FUNC, level)
                            if success and result_fenv == FENV_PLACEHOLDER then return script_env end
                        end
                    end
                    return GETFENV_FUNC(level, ...)
                end,
                setfenv = function(level, env_table, ...)
                    if TYPE_FUNC(level) == 'number' and level >= 0 then
                        if level == 0 then return SETFENV_FUNC(script_env, env_table)
                        else
                            level = level + 1
                            local success, result_fenv = PCALL_FUNC(GETFENV_FUNC, level)
                            if success and result_fenv == FENV_PLACEHOLDER then return SETFENV_FUNC(script_env, env_table) end
                        end
                    end
                    return SETFENV_FUNC(level, env_table, ...)
                end
            }
            script_env = SETMETATABLE_FUNC({}, { __index = function(tbl, key) local value = RAWGET_FUNC(script_env, key); if value ~= nil then return value end; local value_from_env = environment_data[key]; if value_from_env ~= nil then return value_from_env end; return FENV_PLACEHOLDER[key] end })
            SETFENV_FUNC(closure, script_env)
        end

        local result_func = COROUTINE_WRAP(closure)
        if script_instance:IsA'BaseScript' then
            local run_thread = (not CONTEXTUAL_EXECUTION or not script_instance.Disabled) and TASK_LIB.spawn(result_func)
            if CONTEXTUAL_EXECUTION then
                local connection
                connection = script_instance:GetPropertyChangedSignal'Disabled':Connect(function(disabled)
                    connection:Disconnect()
                    if disabled == false then execute_script_closure(script_instance) else PCALL_FUNC(TASK_CANCEL, run_thread) end
                end)
            end
            return
        else
            local results = { result_func() }
            INSTANCE_CACHE[script_instance] = results
            return UNPACK_TABLE(results)
        end
    end

    for _, ref_prop_data in NEXT_ITERATOR, REF_PROPERTIES do
        PCALL_FUNC(function() ref_prop_data.InstanceObject[ref_prop_data.Property] = REF_MAP[ref_prop_data.ReferenceId] end)
    end

    for _, script_to_run in NEXT_ITERATOR, PENDING_SCRIPTS do
        if not CONTEXTUAL_EXECUTION or ((IS_SERVER and script_to_run.ClassName == 'Script') or (IS_CLIENT and script_to_run.ClassName == 'LocalScript')) then
            execute_script_closure(script_to_run)
        end
    end

    if FLAGS.ReturnMainModule == nil or FLAGS.ReturnMainModule then
        local main_module
        do for _, instance in NEXT_ITERATOR, ROOT_INSTANCES do if instance.ClassName == 'ModuleScript' and instance.Name == 'MainModule' then main_module = instance break end end end
        if main_module then return execute_script_closure(main_module) end
    end
end
```
