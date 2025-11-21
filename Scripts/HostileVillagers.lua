--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin HostileVillagers.lua gameplay script
=========================================================================== ]]
g_sRuleset = GameConfiguration.GetValue("RULESET");
print(string.format("Loading gameplay script for %s . . .", g_sRuleset));

--[[ =========================================================================
	
=========================================================================== ]]
HostileVillagers = {};
HostileVillagers.__index = HostileVillagers;
setmetatable(HostileVillagers, {});

--[[ =========================================================================
	force grant free Techs for the Barbarian Player(s)
=========================================================================== ]]
function HostileVillagers_InitBarbarianTechs() 
    local techs:table = DB.Query("SELECT TechnologyType FROM Technologies WHERE BarbarianFree = 1");
    local players:table = PlayerManager.GetAliveBarbarians();
    for _, pPlayer in ipairs(players) do 
        local player:number = pPlayer:GetID();
        print(string.format("Validating free Technologies for Barbarian Player %d . . .", player));
        local pPlayerTechs:object = pPlayer:GetTechs();
        for i, v in ipairs(techs) do 
            local tech:number = GameInfo.Technologies[v.TechnologyType].Index;
            if not pPlayerTechs:HasTech(tech) then 
                pPlayerTechs:SetResearchProgress(tech, pPlayerTechs:GetResearchCost(tech));
            end
            print(string.format("==> [%3d]: %3d  %s", i, tech, v.TechnologyType));
        end
    end
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function GetHostileCombatModifiers( set:string ) 
    -- local func:string = "GetHostileCombatModifiers:";
    if (set == nil) then 
        local valid:table = {};
        for row in GameInfo.HostileVillagers_Units() do 
            local unit:string = row.UnitType;
            local prereq:string = row.PrereqTech;
            local tech:number = prereq and GameInfo.Technologies[prereq].Index or -1;
            if (tech == -1) or Players[63]:GetTechs():HasTech(tech) then 
                valid[(#valid + 1)] = string.format("'%s'", unit);
            end
        end
        set = table.concat(valid, ", ");
    end
    local combat:table = DB.Query(string.format("SELECT MAX(u.Combat) MaxCombat, AVG(u.Combat) AvgCombat FROM Units u JOIN HostileVillagers_Units h ON h.UnitType = u.UnitType WHERE h.UnitType IN (%s)", set));
    -- vprint(func, combat[1].MaxCombat, combat[1].AvgCombat);
    -- print(combat[1].MaxCombat, combat[1].AvgCombat);
    return combat[1].MaxCombat, combat[1].AvgCombat;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_CreateTribe( x:number, y:number, range:number ) 
    local camp:number = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;
    for ring = 1, range, 1 do 
        for _, pPlot in ipairs(Map.GetRingPlots(x, y, ring)) do 
            local bIsUnimproved:boolean = (pPlot:GetImprovementType() == -1);
            local bCanHaveCamp:boolean  = ImprovementBuilder.CanHaveImprovement(pPlot, camp, -1);
            local bIsUnoccupied:boolean = (pPlot:GetUnitCount() == 0);
            if (bIsUnimproved and bCanHaveCamp and bIsUnoccupied) then 
                local plot:number = pPlot:GetIndex();
                local cX:number = pPlot:GetX();
                local cY:number = pPlot:GetY();
                local bIsCoastal:boolean = pPlot:IsCoastalLand();
                local bIsHorsesNearby:boolean = false;
                for _, pPlot in ipairs(Map.GetNeighborPlots(cX, cY, range)) do 
                    local resource:number = pPlot:GetResourceType();
                    if ((resource > -1) and (GameInfo.Resources[resource].ResourceType == "RESOURCE_HORSES")) then 
                        bIsHorsesNearby = true;
                        break;
                    end
                end
                local condition:string = bIsCoastal and "%NAVAL%" or bIsHorsesNearby and "%CAVALRY%" or "%MELEE%";
                local tribes:table = DB.Query(string.format("SELECT TribeType FROM BarbarianTribes WHERE TribeType LIKE '%s'", condition));
                if (#tribes < 1) then 
                    print("[-2]: Failed to identify any potential hostile tribes.");
                    return -1, -1;
                end
                local index:number = (#tribes > 1) and (((cX + cY + range) % #tribes) + 1) or 1;
                local hostiles:string = tribes[index].TribeType;
                local tribe:number = GameInfo.BarbarianTribes[hostiles].Index;
                print(string.format("[%2d]:", tribe), hostiles, plot, string.format("(x %d, y %d)", cX, cY));
                local count:number = Game.GetBarbarianManager():CreateTribeOfType(tribe, plot); -- returns total number of tribes placed
                return tribe, count;
            end
        end
    end
    print("[-1]: Failed to create hostile tribe.");
    return -1, -1;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_ViaUnit( x:number, y:number, range:number, units:number ) 
    local tribe:number = -1;
    local count:number = -1;
    tribe, count = HostileVillagers_CreateTribe(x, y, range);
    if (tribe == -1) then return; end
    local plot:number = Map.GetPlot(x, y):GetIndex();
    local kTribe:table = GameInfo.BarbarianTribes[tribe];
    local kUnitTags:table = { "MeleeTag" };
    if (units > 1) then kUnitTags[(#kUnitTags + 1)] = "RangedTag"; end
    if (units > 2) then kUnitTags[(#kUnitTags + 1)] = "MeleeTag"; end
    if (units > 3) then kUnitTags[(#kUnitTags + 1)] = "RangedTag"; end
    for i, tag in ipairs(kUnitTags) do 
        local class:string = kTribe[tag];
        local unknown:boolean = Game.GetBarbarianManager():CreateTribeUnits(tribe, class, 1, plot, range); -- not entirely sure what this return value indicates
        print(string.format("[%2d / %2d]:", i, #kUnitTags), class, plot, string.format("(x %d, y %d)", x, y), "1");
    end
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_OnGoodyHutReward( player:number, unit:number, goodyhut:number, subtype:number ) 
    if (player == -1) or (unit == -1) then return; end
    local pUnit:object = UnitManager.GetUnit(player, unit);
    if not pUnit then return; end
    local range:number = 3;
    local x:number = pUnit:GetX();
    local y:number = pUnit:GetY();
    if (GameInfo.GoodyHutSubTypes_HGHR[subtype]) then 
        print(goodyhut, subtype);
        local kSubtype:table = GameInfo.GoodyHutSubTypes_HGHR[subtype];
        return LuaEvents.HostileVillagers_ViaUnit(x, y, range, kSubtype.NumUnits);
    end
    local reward:number = GameInfo.HostileVillagers_GoodyHutSubTypes[subtype].Modifier;
    local threshold:number = GameInfo.HostileVillagers_GoodyHutSubTypes[subtype].Threshold;
    local combat:number = pUnit:GetCombat();
    local max:number = -1;
    local avg:number = -1;
    max, avg = GetHostileCombatModifiers();
    combat = (combat > 0) and combat or (avg * -1);
    local discovery:number = math.ceil((max - combat) / 10);
    local difficulty:number = GameInfo.Difficulties[PlayerConfigurations[player]:GetHandicapTypeID()].RowId;
    local era:number = (g_sRuleset ~= "RULESET_STANDARD") and Game.GetEras():GetCurrentEra() or Players[player]:GetEras():GetEra();
    print(goodyhut, subtype, string.format("[ D %d | E %d | S %d | U %d (%d) ]", difficulty, era, reward, discovery, max), threshold);
    return;
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
    print("Configuring handler for LuaEvents.HostileVillagers_ViaUnit . . .");
    LuaEvents.HostileVillagers_ViaUnit.Add(HostileVillagers_ViaUnit);
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_Initialize() 
    print(string.format("Finalizing configuration for %s . . .", g_sRuleset));
    HostileVillagers_InitBarbarianTechs();
    HostileVillagers_InitEventHandlers();
    print(string.format("Configuration for %s complete.", g_sRuleset));
    return;
end

--[[ =========================================================================
	hook HostileVillagers_Initialize() to LoadScreenClose
=========================================================================== ]]
print("Deferring additional configuration to Events.LoadScreenClose.");
Events.LoadScreenClose.Add(HostileVillagers_Initialize);

--[[ =========================================================================
	End HostileVillagers.lua gameplay script
=========================================================================== ]]
