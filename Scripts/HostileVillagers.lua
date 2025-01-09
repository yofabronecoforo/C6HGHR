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
function IsResourceInNearbyPlot( i:number, x:number, y:number, r:number ) 
    r = (r > 1) and r or 1;
    for dX = (r * -1), r do 
        for dY = (r * -1), r do 
            local pPlot:object = Map.GetPlotXYWithRangeCheck(x, y, dX, dY, r);
            if (pPlot and pPlot:GetResourceType() == i) then 
                return true;
            end
        end
    end
    return false;
end

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
function GetEligibleUnit( kUnits:table, era:number, x:number, y:number ) 
    local barb:number = HostileVillagers.iBarbarianID;
    local pPlayer:object = Players[barb];
    local pPlayerTechs:object = pPlayer:GetTechs();
    local resources:table = {};
    for e = era, 0, -1 do 
        local kUnit:table = kUnits[e];
        local unitType:string = kUnit.UnitType;
        local t:number = kUnit.Tech;
        local r:number = kUnit.Resource;
        if (t == -1) then 
            return unitType;
        elseif pPlayerTechs:HasTech(t) then 
            if (r == -1) then 
                return unitType;
            else 
                resources[r] = resources[r] or IsResourceInNearbyPlot(r, x, y, 3);
                if resources[r] then 
                    return unitType;
                end
            end
        end
    end
    return nil;
end

--[[ =========================================================================
	function GrantHostileReward() 
    places one or more hostile Units near a target plot
    arguments:
        turn is the current Game Turn
        player is the ID of the Player that received the hostile "reward"
        x and y are the Map coordinates of the plot that contained the activated Goody Hut
    returns:
        nothing
=========================================================================== ]]
function GrantHostileReward( self:table, turn:number, player:number, x:number, y:number ) 
    print(turn, player, x, y, self.Hash);
    local barb:number = HostileVillagers.iBarbarianID;
    local era:number = HostileVillagers.bIsNotStandard and Game.GetEras():GetCurrentEra() or Players[barb]:GetEras():GetEra();
    local class:string = self.PromotionClass;
    local unitType:string = GetEligibleUnit(HostileVillagers[class], era, x, y);
    if not unitType then 
        print(string.format("%s has 'FAILED' prerequisites", class));
        if (class == "PROMOTION_CLASS_ANTI_CAVALRY") or (class == "PROMOTION_CLASS_HEAVY_CAVALRY") then 
            class = "PROMOTION_CLASS_MELEE";
        elseif (class == "PROMOTION_CLASS_LIGHT_CAVALRY") then 
            class = "PROMOTION_CLASS_RANGED";
        end
        unitType = GetEligibleUnit(HostileVillagers[class], era, x, y);
        if not unitType then 
            print(string.format("%s has 'FAILED' prerequisites", class));
            print("Strange things are afoot at the Circle K");
            return;
        end 
    end
    print(string.format("%s is valid", class));
    for n = 1, self.NumUnits do 
        print(era, n, self.NumUnits, unitType);
        UnitManager.InitUnitValidAdjacentHex(barb, unitType, x, y, 1);
    end
    if Players[player]:IsHuman() then 
        local unitName:string = Locale.Lookup(GameInfo.Units[unitType].Name);
        local message:string = HostileVillagers.sNotification;
        local summary:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_UNIT", self.NumUnits, unitName);
        NotificationManager.SendNotification(player, NotificationTypes.BARBARIANS_SIGHTED, message, summary, x, y);
    end
    return;
end

--[[ =========================================================================
	function GetHostileRewardData() 
    does exactly what it says on the tin
=========================================================================== ]]
function GetHostileRewardData( hash:number, t:table ) 
    t.Hash = hash;
    local hghr:table = GameInfo.GoodyHutSubTypes_HGHR[t.SubTypeGoodyHut];
    t.PromotionClass = hghr.PromotionClass;
    t.NumUnits = hghr.NumUnits;
    t.Grant = GrantHostileReward;
    print(string.format("[%d] = %s (%s, %d)", hash, tostring(t.Grant), t.SubTypeGoodyHut, t.Weight));
    return t;
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
    return HostileVillagers[subtypeHash]:Grant(turn, player, plotX, plotY);
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
