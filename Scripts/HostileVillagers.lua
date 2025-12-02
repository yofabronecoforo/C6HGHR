--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin HostileVillagers.lua gameplay script
=========================================================================== ]]
g_sRuleset = GameConfiguration.GetValue("RULESET");
print("Loading gameplay script . . .");

--[[ =========================================================================
	
=========================================================================== ]]
g_bBarbarianClans = GameConfiguration.GetValue("GAMEMODE_BARBARIAN_CLANS");

g_kBarbarianTribes = {};
g_kBarbarianIDs = {};

g_sBarbarianCamp = "IMPROVEMENT_BARBARIAN_CAMP";
g_iBarbarianCamp = GameInfo.Improvements[g_sBarbarianCamp] and GameInfo.Improvements[g_sBarbarianCamp].Index or -1;
if (g_iBarbarianCamp == -1) then return; end

g_sHorses = "RESOURCE_HORSES";
g_iHorses = GameInfo.Resources[g_sHorses] and GameInfo.Resources[g_sHorses].Index or -1;
if (g_iHorses == -1) then return; end

-- g_sHutsGame = "HGHR_Huts_This_Game";
-- g_sHutsTurn = "HGHR_Huts_This_Turn";
-- g_sRewardsGame = "HGHR_Rewards_This_Game";
-- g_sRewardsTurn = "HGHR_Rewards_This_Turn";

-- g_kScriptProperties = { 
--     { Name = g_sHutsGame, Value = 0 }, 
--     { Name = g_sHutsTurn, Value = 0 }, 
--     { Name = g_sRewardsGame, Value = 0 }, 
--     { Name = g_sRewardsTurn, Value = 0 } 
-- };

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_InitBarbarianTribes( bIsNewGame:boolean ) 
    local sAction:string = bIsNewGame and "Configuring" or "Validating";
    print(string.format("%s hostile tribe(s) . . .", sAction));
    local kTribes:table = {};
    for n, item in ipairs({ "NAVAL", "CAVALRY", "MELEE" }) do 
        local kResults:table = DB.Query(string.format("SELECT TribeType FROM BarbarianTribes WHERE TribeType LIKE '%%%s%%'", item));
        if (#kResults < 1) then 
            print(string.format("==> [-1]: FAILED to identify %s tribe(s), aborting.", item));
            return nil;
        end
        kTribes[n] = {};
        print(string.format("==> [%2d]: %-9s", n, item), kTribes[n]);
        for i, row in ipairs(kResults) do 
            local sTribe:string = row.TribeType;
            local iTribe:number = GameInfo.BarbarianTribes[sTribe].Index;
            kTribes[n][i] = iTribe;
            print(string.format("======> [%2d / %2d]: %3d", i, #kResults, iTribe), sTribe);
        end
    end
    return kTribes;
end

--[[ =========================================================================
	force grant free Techs for Barbarian Player(s)
    return table of Barbarian Player IDs
=========================================================================== ]]
function HostileVillagers_InitBarbarianTechs( bIsNewGame:boolean ) 
    local kTechs:table = DB.Query("SELECT TechnologyType FROM Technologies WHERE BarbarianFree = 1");
    local kPlayers:table = {};
    local sAction:string = bIsNewGame and "Configuring" or "Validating";
    for _, pPlayer in ipairs(PlayerManager.GetAliveBarbarians()) do 
        local iPlayer:number = pPlayer:GetID();
        kPlayers[(#kPlayers + 1)] = iPlayer;
        print(string.format("%s free Technologies for Barbarian Player %d . . .", sAction, iPlayer));
        local pPlayerTechs:object = pPlayer:GetTechs();
        for i, tech in ipairs(kTechs) do 
            local sTech:string = tech.TechnologyType
            local iTech:number = GameInfo.Technologies[sTech].Index;
            local bHasTech:boolean = pPlayerTechs:HasTech(iTech);
            print(string.format("==> [%3d]: %-11s %3d", i, bHasTech and "Researched" or "Researching", iTech), sTech);
            if not bHasTech then pPlayerTechs:SetResearchProgress(iTech, pPlayerTechs:GetResearchCost(iTech)); end
        end
    end
    return kPlayers;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_Initialize() 
    local bIsLoadGame:boolean = Game:GetProperty("HGHR_Initialized") or false;
    print(string.format("%s game: Initializing configuration for %s . . .", (not bIsLoadGame) and "New" or "Load", g_sRuleset));
    print(string.format("%-36s", "Barbarian Clans mode is enabled:"), g_bBarbarianClans);
    g_kBarbarianTribes = HostileVillagers_InitBarbarianTribes((not bIsLoadGame));
    g_kBarbarianIDs = HostileVillagers_InitBarbarianTechs((not bIsLoadGame));
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
HostileVillagers_Initialize();
if not g_kBarbarianTribes or (#g_kBarbarianTribes < 1) then return; end
if not g_kBarbarianIDs or (#g_kBarbarianIDs < 1) then return; end

--[[ =========================================================================
	
=========================================================================== ]]
HostileVillagers = {};
HostileVillagers.__index = HostileVillagers;
setmetatable(HostileVillagers, {});

--[[ =========================================================================
	
=========================================================================== ]]
function GetHostileCombatModifiers() 
    local iBarbarian:number = g_kBarbarianIDs[1]; -- if there are multiple Barbarian Players, we only need one valid ID here
    local pPlayer:object = Players[iBarbarian];
    local pPlayerCulture:object = pPlayer:GetCulture();
    local pPlayerTechs:object = pPlayer:GetTechs();
    local kUnits:table = {};
    for row in GameInfo.HostileVillagers_Units() do 
        local sCivic:string = row.PrereqCivic;
        local iCivic:number = sCivic and GameInfo.Civics[sCivic].Index or -1;
        local bHasCivic:boolean = ((iCivic == -1) or pPlayerCulture:HasCivic(iCivic));
        local sTech:string = row.PrereqTech;
        local iTech:number = sTech and GameInfo.Technologies[sTech].Index or -1;
        local bHasTech:boolean = ((iTech == -1) or pPlayerTechs:HasTech(iTech));
        if (bHasCivic and bHasTech) then kUnits[(#kUnits + 1)] = string.format("'%s'", row.UnitType); end
    end
    local sQuery:string = "SELECT MAX(u.Combat) Maximum, AVG(u.Combat) Average FROM Units u";
    local sJoin:string = "JOIN HostileVillagers_Units h ON h.UnitType = u.UnitType";
    local sCondition:string = string.format("WHERE h.UnitType IN (%s)", table.concat(kUnits, ", "));
    local kCombat:table = DB.Query(string.format("%s %s %s", sQuery, sJoin, sCondition));
    return kCombat[1].Maximum, kCombat[1].Average;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_CreateTribe( x:number, y:number, range:number ) 
    for ring = 1, range, 1 do 
        for _, pPlot in ipairs(Map.GetRingPlots(x, y, ring)) do 
            local bIsUnimproved:boolean = (pPlot:GetImprovementType() == -1);
            local bCanHaveCamp:boolean  = ImprovementBuilder.CanHaveImprovement(pPlot, g_iBarbarianCamp, -1);
            local bIsUnoccupied:boolean = (pPlot:GetUnitCount() == 0);
            if (bIsUnimproved and bCanHaveCamp and bIsUnoccupied) then 
                local iPlot:number = pPlot:GetIndex();
                local cX:number = pPlot:GetX();
                local cY:number = pPlot:GetY();
                local bIsCoastal:boolean = pPlot:IsCoastalLand();
                local bIsHorsesNearby:boolean = false;
                for _, pPlot in ipairs(Map.GetNeighborPlots(cX, cY, range)) do 
                    bIsHorsesNearby = (pPlot:GetResourceType() == g_iHorses);
                    if bIsHorsesNearby then break; end
                end
                local iType:number = bIsCoastal and 1 or bIsHorsesNearby and 2 or 3;
                local kTribes:table = g_kBarbarianTribes[iType];
                local iTribe:number = (#kTribes > 1) and kTribes[(((cX + cY + range) % #kTribes) + 1)] or kTribes[1];
                local sTribe:string = GameInfo.BarbarianTribes[iTribe].TribeType;
                print(string.format("==> [%2d]: %-26s %-5d (x %3d, y %3d)", iTribe, sTribe, iPlot, cX, cY));
                local pBarbMgr:object = Game.GetBarbarianManager();
                local numTribes:number = pBarbMgr:CreateTribeOfType(iTribe, iPlot); -- returns total number of tribes placed
                return iTribe, numTribes;
            end
        end
    end
    print("==> [-1]: Failed to create hostile tribe.");
    return -1, -1;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_New( x:number, y:number, range:number, units:number ) 
    local iTribe:number = -1;
    local count:number = -1;
    iTribe, count = HostileVillagers_CreateTribe(x, y, range);
    if (iTribe == -1) then return; end
    local iPlot:number = Map.GetPlot(x, y):GetIndex();
    local kTribe:table = GameInfo.BarbarianTribes[iTribe];
    local kUnitTags:table = { "MeleeTag" };
    if (units > 1) then kUnitTags[(#kUnitTags + 1)] = "RangedTag"; end
    if (units > 2) then kUnitTags[(#kUnitTags + 1)] = "MeleeTag"; end
    if (units > 3) then kUnitTags[(#kUnitTags + 1)] = "RangedTag"; end
    for i, tag in ipairs(kUnitTags) do 
        local class:string = kTribe[tag];
        local unknown:boolean = Game.GetBarbarianManager():CreateTribeUnits(iTribe, class, 1, iPlot, range); -- not entirely sure what this return value indicates
        print(string.format("======> [%2d / %2d]: %-22s %-5d (x %3d, y %3d)", i, #kUnitTags, class, iPlot, x, y), unknown);
    end
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_OnGoodyHutReward( iPlayer:number, iUnit:number, iGoodyhut:number, iSubtype:number ) 
    if (iPlayer == -1) or (iUnit == -1) then return; end
    local pPlayer:object = Players[iPlayer];
    if not pPlayer then return; end
    local pUnit:object = UnitManager.GetUnit(iPlayer, iUnit);
    if not pUnit then return; end
    local iX:number = pUnit:GetX();
    local iY:number = pUnit:GetY();
    if not iX or (iX < 0) or not iY or (iY < 0) then return; end
    local iRange:number = 3;
    local sEvent:string = string.format("%-12s %-12s (x %3d, y %3d)", iGoodyhut, iSubtype, iX, iY);
    if (GameInfo.GoodyHutSubTypes_HGHR[iSubtype]) then 
        local kSubtype:table = GameInfo.GoodyHutSubTypes_HGHR[iSubtype];
        print(sEvent, string.format("The villagers are %s hostile!", kSubtype.Adverb));
        return LuaEvents.HostileVillagers_New(iX, iY, iRange, kSubtype.NumUnits);
    end
    local pPlot:object = Map.GetPlot(iX, iY);
    if not pPlot then return; end
    local iPlot:number = pPlot:GetIndex();
    if not iPlot or (iPlot < 0) then return; end
    local iTurn:number = Game.GetCurrentGameTurn();
    local iDifficulty:number = GameInfo.Difficulties[PlayerConfigurations[iPlayer]:GetHandicapTypeID()].RowId;
    local iEra:number = (g_sRuleset ~= "RULESET_STANDARD") and Game.GetEras():GetCurrentEra() or pPlayer:GetEras():GetEra();
    local iReward:number = GameInfo.HostileVillagers_GoodyHutSubTypes[iSubtype].Modifier;
    local iThreshold:number = GameInfo.HostileVillagers_GoodyHutSubTypes[iSubtype].Threshold;
    local iMax:number = -1;
    local iAvg:number = -1;
    iMax, iAvg = GetHostileCombatModifiers();
    local iCombat:number = pUnit:GetCombat();
    iCombat = (iCombat > 0) and iCombat or (iAvg * -1);
    local iDiscovery:number = math.ceil((iMax - iCombat) / 10);
    local sIncident:string = string.format("%d_%d_%d_%d_%d_%d_%d_%d", iTurn, iPlot, iX, iY, iGoodyhut, iSubtype, iPlayer, iUnit);
    local iIncident:number = DB.MakeHash(sIncident);
    local iRandom:number = iIncident % iThreshold;
    local iHostility:number = (iDifficulty * iEra) + iReward + iDiscovery + iRandom;
    local sResult:string = string.format("%3d (%3d / %3d)", iRandom, iHostility, iThreshold);
    if (iHostility < iThreshold) then 
        print(sEvent, "The villagers are unconcerned.", sResult);
        return;
    end
    local kThresholds:table = { (iThreshold * 0.3), (iThreshold * 0.15), (iThreshold * 0.05) };
    local iIndex:number = (iRandom <= kThresholds[3]) and 3 or (iRandom <= kThresholds[2]) and 2 or (iRandom <= kThresholds[1]) and 1 or 0;
    local kSubtype:table = GameInfo.GoodyHutSubTypes_HGHR[iIndex];
    print(sEvent, string.format("The villagers are %s hostile!", kSubtype.Adverb), sResult);
    return LuaEvents.HostileVillagers_New(iX, iY, iRange, kSubtype.NumUnits);
end

--[[ =========================================================================
	
=========================================================================== ]]
function TestViaUnit( player:number, unit:number ) 
    player = player or 0;
    unit = unit or 131073;
    for row in GameInfo.GoodyHutSubTypes_HGHR() do 
        HostileVillagers_OnGoodyHutReward(player, unit, GameInfo.GoodyHuts["GOODYHUT_HOSTILES"].Hash, row.Hash);
    end
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_InitEventHandlers() 
    print("Configuring handler for Events.GoodyHutReward . . .");
    Events.GoodyHutReward.Add(HostileVillagers_OnGoodyHutReward);
    print("Configuring handler for LuaEvents.HostileVillagers_New . . .");
    LuaEvents.HostileVillagers_New.Add(HostileVillagers_New);
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_Finalize() 
    local bIsLoadGame:boolean = Game:GetProperty("HGHR_Initialized") or false;
    print(string.format("%s game: Finalizing configuration for %s . . .", (not bIsLoadGame) and "New" or "Load", g_sRuleset));
    HostileVillagers_InitEventHandlers();
    Game:SetProperty("HGHR_Initialized", true);
    print(string.format("Configuration for %s complete.", g_sRuleset));
    return;
end

--[[ =========================================================================
	hook HostileVillagers_Finalize() to LoadScreenClose
=========================================================================== ]]
print("Deferring additional configuration to Events.LoadScreenClose.");
Events.LoadScreenClose.Add(HostileVillagers_Finalize);

--[[ =========================================================================
	End HostileVillagers.lua gameplay script
=========================================================================== ]]
