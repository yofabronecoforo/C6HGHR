--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin HostileVillagers.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script HostileVillagers.lua . . .");

--[[ =========================================================================
	function AbortInit() 
    should be called when any of the below pre-init checks fail
=========================================================================== ]]
function AbortInit() 
    print("Aborting configuration");
    return;
end

--[[ =========================================================================
	pre-init abort gauntlet
=========================================================================== ]]
local g_iBarbarianID:number = -1;
for _, pPlayer in ipairs(Game.GetPlayers()) do 
    if pPlayer:IsBarbarian() then 
        g_iBarbarianID = pPlayer:GetID();
        print(string.format("Barbarian Player ID is %d", g_iBarbarianID));
    end
end
if (g_iBarbarianID == -1) then 
    print("'FAILED' to identify the Barbarian Player ID");
    return AbortInit();
end

local g_bNoBarbarians:boolean = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
print(string.format("'No Barbarians' is %s", tostring(g_bNoBarbarians)));
if g_bNoBarbarians then return AbortInit(); end

local g_iBarbCampIndex:number = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;
if not g_iBarbCampIndex then 
    print("Barbarian Outpost is 'NOT' present in GameInfo.Improvements");
    return AbortInit();
else 
    print(string.format("Barbarian Outpost is GameInfo.Improvements[%d]", g_iBarbCampIndex));
end

local g_bNoGoodyHuts:boolean = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
print(string.format("'No Tribal Villages' is %s", tostring(g_bNoGoodyHuts)));
if g_bNoGoodyHuts then return AbortInit(); end

local g_iGoodyHutIndex:number = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
if not g_iGoodyHutIndex then 
    print("Tribal Village is 'NOT' present in GameInfo.Improvements");
    return AbortInit();
else 
    print(string.format("Tribal Village is GameInfo.Improvements[%d]", g_iGoodyHutIndex));
end

local g_sNotification:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE");
local g_sRowOfDashes:string = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";
local g_sRuleset:string = GameConfiguration.GetValue("RULESET");
local g_bIsNotStandard:boolean = (g_sRuleset ~= "RULESET_STANDARD");

--[[ =========================================================================
	table HostileVillagers 
=========================================================================== ]]
local HostileVillagers:table = {};
HostileVillagers.__index = HostileVillagers;
setmetatable(HostileVillagers, {
    __call = function (class, t) 
        local self:table = setmetatable({}, class);
        self.__index = self;
        return self:New(t);
    end, 
});

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetAdjacentPlotsInRadius( self:table, x:number, y:number, r:number, e:number ) 
    x = (x and x >= 0) and x or (self.X and self.X >= 0) and self.X or 0;
    y = (y and y >= 0) and y or (self.Y and self.Y >= 0) and self.Y or 0;
    r = (r and r > 1) and r or (self.Radius and self.Radius > 1) and self.Radius or 1;
    e = (e and e > 0 and e < r) and e or (self.ExcludeRadius and self.ExcludeRadius > 0 and self.ExcludeRadius < r) and self.ExcludeRadius or 0;
    local pPlot:object = nil;
    local p:number = -1;
    local plots:table = {};
    local exclude:table = { [Map.GetPlot(x, y)] = true };
    if (e > 0) then 
        for eX = (e * -1), e do 
            for eY = (e * -1), e do 
                pPlot = Map.GetPlotXYWithRangeCheck(x, y, eX, eY, e);
                if pPlot then 
                    exclude[pPlot] = true;
                end
            end
        end
    end
    for rX = (r * -1), r do 
        for rY = (r * -1), r do 
            pPlot = Map.GetPlotXYWithRangeCheck(x, y, rX, rY, r);
            if (pPlot and not exclude[pPlot]) then 
                p = #plots + 1;
                plots[p] = pPlot;
            end
        end
    end
    return plots;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function IsValidPlotForImprovement( pPlot:object, i:number ) 
    if (pPlot:GetImprovementType() == -1) then 
        if (pPlot:GetOwner() == -1) then 
            if ImprovementBuilder.CanHaveImprovement(pPlot, i, -1) then 
                return true;
            end
        end
    end
    return false;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function ValidatePlots( self:table ) 
    self.NearbyResources = {};
    self.CampPlots = {};
    self.LandPlots = {};
    self.WaterPlots = {};
    local bHasNoResources:boolean = false;
    local p:number = 0;
    for _, pPlot in ipairs(self.NearbyPlots) do 
        bHasNoResources = (pPlot:GetResourceType() == -1);
        if not bHasNoResources then 
            for _, i in ipairs(HostileVillagers.StrategicResources) do 
                if not self.NearbyResources[i] then 
                    if (pPlot:GetResourceType() == i) then 
                        self.NearbyResources[i] = true;
                        print(GameInfo.Resources[i].ResourceType, " is located nearby");
                    end
                end
            end
        end
        if not pPlot:IsImpassable() and not pPlot:IsNaturalWonder() then 
            if not pPlot:IsMountain() and not pPlot:IsLake() then 
                if (pPlot:GetUnitCount() == 0) then 
                    if self.Outpost and bHasNoResources then 
                        if IsValidPlotForImprovement(pPlot, self.CampIndex) then 
                            p = #self.CampPlots + 1;
                            self.CampPlots[p] = pPlot;
                        end
                    end
                    if not pPlot:IsWater() then 
                        p = #self.LandPlots + 1;
                        self.LandPlots[p] = pPlot;
                    elseif pPlot:IsWater() then 
                        p = #self.WaterPlots + 1;
                        self.WaterPlots[p] = pPlot;
                    end
                end
            end
        end
    end
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetEligibleUnit( self:table, class:string ) 
    class = class and class or self.PromotionClass and self.PromotionClass or "PROMOTION_CLASS_MELEE";
    local kUnits:table = HostileVillagers[class];
    local pPlayer:object = Players[self.BarbarianID];
    local pPlayerTechs:object = pPlayer:GetTechs();
    for e = self.Era, 0, -1 do 
        local kUnit:table = kUnits[e];
        local unitType:string = kUnit.UnitType;
        local t:number = kUnit.Tech;
        local r:number = kUnit.Resource;
        if (t == -1) then 
            print(unitType, " no tech ", " is valid");
            return unitType;
        elseif pPlayerTechs:HasTech(t) then 
            if (r == -1) then 
                print(unitType, t, " no resource ", " is valid");
                return unitType;
            else 
                if self.NearbyResources[r] then 
                    print(unitType, t, r,  " is valid");
                    return unitType;
                end
            end
        end
    end
    print(class, " is 'NOT' valid");
    return nil;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function LogMembers( self:table ) 
    for row in GameInfo.HostileRewardMembers() do 
        print(row.Name, self[row.Name]);
    end
    return;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetMembers( self:table ) 
    local t:table = {};
    for row in GameInfo.HostileRewardMembers() do 
        t[row.Name] = self[row.Name];
    end
    return t;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function Activate( self:table ) 
    self.Era = HostileVillagers.bIsNotStandard and Game.GetEras():GetCurrentEra() or Players[self.BarbarianID]:GetEras():GetEra();
    self.Radius = 3;
    print(self.Turn, self.X, self.Y, self.Player, self.Era, self.Hash);
    self.NearbyPlots = self:GetAdjacentPlotsInRadius();
    print("Found ", #self.NearbyPlots, " valid nearby plot(s)");
    self:ValidatePlots();
    local bCampPlaced:boolean = false;
    if self.Outpost then 
        local cX:number = -1;
        local cY:number = -1;
        print("Found ", #self.CampPlots, " valid plot(s) for a Barbarian Outpost");
        if (#self.CampPlots > 0) then 
            while (not bCampPlaced and #self.CampPlots > 0) do 
                local i:number = #self.CampPlots;
                local pPlot:object = self.CampPlots[i];
                self.CampPlots[i] = nil;
                ImprovementBuilder.SetImprovementType(pPlot, self.CampIndex, self.BarbarianID);
                if (pPlot:GetImprovementType() == self.CampIndex) then 
                    cX = pPlot:GetX();
                    cY = pPlot:GetY();
                    bCampPlaced = true;
                -- else 
                --     table.insert(f, plot);
                end
            end
        end
        if not bCampPlaced then 
            self.NumUnits = self.NumUnits + 2;
        elseif bCampPlaced and Players[self.Player]:IsHuman() then 
            -- local unitName:string = Locale.Lookup(GameInfo.Units[unitType].Name);
            local message:string = HostileVillagers.sNotification;
            local summary:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_CAMP");
            NotificationManager.SendNotification(self.Player, NotificationTypes.NEW_BARBARIAN_CAMP, message, summary, cX, cY);
        end
    end
    print("Found ", #self.LandPlots, " valid plot(s) for a land unit");
    print("Found ", #self.WaterPlots, " valid plot(s) for a naval unit");
    local class:string = self.PromotionClass;
    local unitType:string = self:GetEligibleUnit(class);
    if not unitType then 
        print(string.format("%s has 'FAILED' prerequisites", class));
        if (class == "PROMOTION_CLASS_ANTI_CAVALRY") or (class == "PROMOTION_CLASS_HEAVY_CAVALRY") then 
            class = "PROMOTION_CLASS_MELEE";
        elseif (class == "PROMOTION_CLASS_LIGHT_CAVALRY") then 
            class = "PROMOTION_CLASS_RANGED";
        end
        unitType = self:GetEligibleUnit(class);
        if not unitType then 
            print(string.format("%s has 'FAILED' prerequisites", class));
            print("Strange things are afoot at the Circle K");
            return;
        end 
    end
    print(string.format("%s is valid", class));
    for n = 1, self.NumUnits do 
        print(self.Era, n, self.NumUnits, unitType);
        UnitManager.InitUnitValidAdjacentHex(self.BarbarianID, unitType, self.X, self.Y, 1);
    end
    if Players[self.Player]:IsHuman() then 
        local unitName:string = Locale.Lookup(GameInfo.Units[unitType].Name);
        local message:string = HostileVillagers.sNotification;
        local summary:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_UNIT", self.NumUnits, unitName);
        NotificationManager.SendNotification(self.Player, NotificationTypes.BARBARIANS_SIGHTED, message, summary, self.X, self.Y);
    end
    return;
end

--[[ =========================================================================
	function GetHostileRewardData() 
    does exactly what it says on the tin
=========================================================================== ]]
function GetHostileRewardData( hash:number, t:table ) 
    local reward:table = {};
    local hghr:table = GameInfo.GoodyHutSubTypes_HGHR[t.SubTypeGoodyHut];
    for row in GameInfo.HostileRewardMembers() do 
        if t[row.Name] then 
            reward[row.Name] = t[row.Name];
        elseif hghr[row.Name] then 
            reward[row.Name] = hghr[row.Name];
        end
    end
    reward.Hash = hash;
    reward.CampIndex = g_iBarbCampIndex;
    reward.BarbarianID = g_iBarbarianID;
    reward.GetAdjacentPlotsInRadius = GetAdjacentPlotsInRadius;
    reward.LogMembers = LogMembers;
    reward.GetMembers = GetMembers;
    reward.ValidatePlots = ValidatePlots;
    reward.GetEligibleUnit = GetEligibleUnit;
    reward.Activate = Activate;
    print(string.format("[%d] = %s (%s, %d)", hash, tostring(reward.Activate), reward.SubTypeGoodyHut, reward.Weight));
    return reward;
end

--[[ =========================================================================
	function GetHostileUnitData() 
    does exactly what it says on the tin
=========================================================================== ]]
function GetHostileUnitData( class:string, era:number, t:table ) 
    local tech:string = GameInfo.Units[t.UnitType].PrereqTech;
    t.Tech = tech and GameInfo.Technologies[tech].Index or -1;
    local resource:string = GameInfo.Units[t.UnitType].StrategicResource;
    t.Resource = resource and GameInfo.Resources[resource].Index or -1;
    print(string.format("[%s][%d] = {%s, %d, %d}", class, era, t.UnitType, t.Tech, t.Resource));
    return t;
end

--[[ =========================================================================
	function New() 
    creates a HostileVillagers object with the necessary members
    returns:
        the newly created HostileVillagers object
=========================================================================== ]]
function HostileVillagers:New( t:table ) 
    -- this probably isn't necessary
    t = t or {};
    -- functions
    self.GetHostileRewardData = GetHostileRewardData;
    self.GetHostileUnitData = GetHostileUnitData;
    self.GrantHostileReward = GrantHostileReward;
    self.IsResourceInNearbyPlot = IsResourceInNearbyPlot;
    self.GetEligibleUnit = GetEligibleUnit;
    -- strings
    self.sNotification = g_sNotification;
    self.sRowOfDashes = g_sRowOfDashes;
    self.sRuleset = g_sRuleset;
    -- booleans
    self.bIsNotStandard = g_bIsNotStandard;
    self.bNoBarbarians = g_bNoBarbarians;
    self.bNoGoodyHuts = g_bNoGoodyHuts;
    -- integers
    self.iBarbarianID = g_iBarbarianID;
    self.iBarbCampIndex = g_iBarbCampIndex;
    self.iGoodyHutIndex = g_iGoodyHutIndex;
    -- tables
    self.StrategicResources = {};
    local i:number = -1;
    print("Configuring Strategic Resource lookup table . . .");
    for row in GameInfo.Resources() do 
        if row.ResourceClassType == "RESOURCECLASS_STRATEGIC" then 
            i = #self.StrategicResources + 1;
            self.StrategicResources[i] = row.Index;
            print(string.format("[%d] = %s (%d)", i, row.ResourceType, row.Index));
        end
    end
    print("Configuring Hostile 'Reward' hash table(s) . . .");
    for row in GameInfo.GoodyHutSubTypes() do 
        local hash:number = DB.MakeHash(row.SubTypeGoodyHut);
        if (row.GoodyHut == "GOODYHUT_HOSTILES") then 
            self[hash] = GetHostileRewardData(hash, row);
        -- else 
        --     self.NonHostileRewards[hash] = row;
        end
    end
    print("Configuring Hostile Unit lookup table . . .");
    for row in GameInfo.HostileVillagerUnits() do 
        local class:string = row.PromotionClass;
        self[class] = self[class] or {};
        local era:number = GameInfo.Eras[row.EraType].Index;
        self[class][era] = GetHostileUnitData(class, era, row);
    end
    return self;
end

--[[ =========================================================================
	listener function OnGoodyHutReward() 
    calls GrantHostileReward() for hostile "rewards"
=========================================================================== ]]
function HostileVillagers_OnGoodyHutReward(player, unit, typeHash, subtypeHash) 
    if (player == -1) then return; end
    if (unit == -1) then return; end
    if not HostileVillagers[subtypeHash] then return; end
    local turn:number = Game.GetCurrentGameTurn();
    local pUnit:object = UnitManager.GetUnit(player, unit);
    if not pUnit then 
        print(string.format("Turn %d: Player %d: Unit %d is 'NOT' valid", turn, player, unit));
        return;
    end
    local plotX:number = pUnit:GetX();
    local plotY:number = pUnit:GetY();
    if (plotX < 0 or plotY < 0) then 
        print(string.format("Turn %d: Player %d: Plot (x %d, y %d) is 'NOT' valid", turn, player, plotX, plotY));
        return;
    end
    local kHostile:table = HostileVillagers[subtypeHash]:GetMembers();
    kHostile.Turn = turn;
    kHostile.Player = player;
    kHostile.Unit = unit;
    kHostile.X = plotX;
    kHostile.Y = plotY;
    return kHostile:Activate();
end

--[[ =========================================================================
	configure required components
=========================================================================== ]]
function HostileVillagers_Initialize() 
    print(string.format("Configuring members for %s . . .", g_sRuleset));
    HostileVillagers = HostileVillagers();
    print("Exposing members . . .");
    ExposedMembers.HostileVillagers = HostileVillagers;
    print("Configuring ingame Event listeners . . .");
    Events.GoodyHutReward.Add(HostileVillagers_OnGoodyHutReward);
    print("Clearing temporary variables . . .");
    g_sNotification = nil;
    g_sRowOfDashes = nil;
    g_sRuleset = nil;
    g_bIsNotStandard = nil;
    g_bNoBarbarians = nil;
    g_bNoGoodyHuts = nil;
    g_iBarbarianID = nil;
    g_iBarbCampIndex = nil;
    g_iGoodyHutIndex = nil;
    print("Initialization complete");
    return;
end

--[[ =========================================================================
	defer execution of Initialize() to LoadScreenClose
=========================================================================== ]]
print("Deferring further configuration to LoadScreenClose");
Events.LoadScreenClose.Add(HostileVillagers_Initialize);

--[[ =========================================================================
	End HostileVillagers.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	function 
=========================================================================== ]]
-- function GetNumPlotsWithResource( plots:table, i:number ) 
--     local numPlots:number = 0;
--     for _, pPlot in ipairs(plots) do 
--         if (pPlot:GetResourceType() == i) then 
--             numPlots = numPlots + 1;
--         end
--     end
--     return numPlots;
-- end

--[[ =========================================================================
	function 
=========================================================================== ]]
-- function GetValidPlotsForImprovement( plots:table, i:number ) 
--     local bHasNoUnits:boolean = false;
--     local bHasNoResources:boolean = false;
--     local bIsUnimproved:boolean = false;
--     local bIsVacant:boolean = false;
--     local p:number = 0;
--     local valid:table = {};
--     for _, pPlot in ipairs(plots) do 
--         if (pPlot:GetOwner() == -1) then 
--             bHasNoUnits = (#Units.GetUnitsInPlot(pPlot) == 0);
--             bHasNoResources = (pPlot:GetResourceType() == -1);
--             bIsUnimproved = (pPlot:GetImprovementType() == -1);
--             bIsVacant = (bHasNoUnits and bHasNoResources and bIsUnimproved);
--             if (bIsVacant and ImprovementBuilder.CanHaveImprovement(pPlot, i, -1)) then 
--                 p = #valid + 1;
--                 valid[p] = pPlot;
--             end
--         end
--     end
--     return valid;
-- end

--[[ =========================================================================
	function 
=========================================================================== ]]
-- function GetValidPlotsForUnit( plots:table ) 
--     local p:number = 0;
--     local land:table = {};
--     local water:table = {};
--     for _, pPlot in ipairs(plots) do 
--         if (#Units.GetUnitsInPlot(pPlot) == 0) then 
--             if not pPlot:IsWater() then 
--                 p = #land + 1;
--                 land[p] = pPlot;
--             elseif pPlot:IsWater() then 
--                 p = #water + 1;
--                 water[p] = pPlot;
--             end
--         end
--     end
--     return land, water;
-- end

--[[ =========================================================================
	function IsResourceInNearbyPlot() 
    finds a Resource in Map plots near a target plot
    arguments:
        i is the Index of a Resource in GameInfo.Resources[]
        x and y are the Map coordinates of a target plot
        r is the maximum distance from the target plot of plots to search
    returns:
        true when i is found in any plot within r plots of the target plot, or 
        false otherwise
=========================================================================== ]]
-- function IsResourceInNearbyPlot( i:number, x:number, y:number, r:number ) 
--     r = (r > 1) and r or 1;
--     local pPlot:object = nil;
--     for dX = (r * -1), r do 
--         for dY = (r * -1), r do 
--             pPlot = Map.GetPlotXYWithRangeCheck(x, y, dX, dY, r);
--             if (pPlot and pPlot:GetResourceType() == i) then 
--                 return true;
--             end
--         end
--     end
--     return false;
-- end

--[[ =========================================================================
	function GetEligibleUnit() 
    identifies the most advanced Unit of a given Promotion Class that Barbarian Tech and nearby Resources can produce
    arguments:
        kUnits is a table of relevant Unit data for one Promotion Class
        era is the current Game or Player Era, and is used to index kUnits
        x and y are the Map coordinates of a target plot
    returns:
        a valid UnitType if one is identified, or 
        nil when a valid UnitType is NOT identified
=========================================================================== ]]
-- function GetEligibleUnit( kUnits:table, era:number, x:number, y:number ) 
--     local barb:number = HostileVillagers.iBarbarianID;
--     local pPlayer:object = Players[barb];
--     local pPlayerTechs:object = pPlayer:GetTechs();
--     local resources:table = {};
--     for e = era, 0, -1 do 
--         local kUnit:table = kUnits[e];
--         local unitType:string = kUnit.UnitType;
--         local t:number = kUnit.Tech;
--         local r:number = kUnit.Resource;
--         if (t == -1) then 
--             return unitType;
--         elseif pPlayerTechs:HasTech(t) then 
--             if (r == -1) then 
--                 return unitType;
--             else 
--                 resources[r] = resources[r] or IsResourceInNearbyPlot(r, x, y, 3);
--                 if resources[r] then 
--                     return unitType;
--                 end
--             end
--         end
--     end
--     return nil;
-- end
