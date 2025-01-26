--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin HostileVillagers.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script HostileVillagers.lua . . .");

local g_sRuleset:string = GameConfiguration.GetValue("RULESET");

local g_iLoggingLevel:number = GameConfiguration.GetValue("GAME_ECFE_LOGGING") or -1;
g_iLoggingLevel = 3;
local vprint = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;

--[[ =========================================================================
	function IsExpansionRuleset() 
=========================================================================== ]]
function IsExpansionRuleset() 
    return (g_sRuleset ~= "RULESET_STANDARD");
end

--[[ =========================================================================
	function IsStandardRuleset() 
=========================================================================== ]]
function IsStandardRuleset() 
    return (g_sRuleset == "RULESET_STANDARD");
end

--[[ =========================================================================
	function AbortInit() 
    should be called when any of the below pre-init checks fail
=========================================================================== ]]
function AbortInit() 
    print("Aborting configuration");
    return;
end

--[[ =========================================================================
	pre-init 
=========================================================================== ]]
local g_iBarbarianID:number = -1;
for _, pPlayer in ipairs(Game.GetPlayers()) do 
    if pPlayer:IsBarbarian() then g_iBarbarianID = pPlayer:GetID(); end
end
print("Barbarian Player ID:", g_iBarbarianID);
if (g_iBarbarianID == -1) then return AbortInit(); end

local g_bNoBarbarians:boolean = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
print("'No Barbarians':", g_bNoBarbarians);
if g_bNoBarbarians then return AbortInit(); end

local g_sCampType:string = "IMPROVEMENT_BARBARIAN_CAMP";
local g_iCampIndex:number = GameInfo.Improvements[g_sCampType].Index or -1;
print(string.format("GameInfo.Improvements[%s]: %d", g_sCampType, g_iCampIndex));
if (g_iCampIndex < 0) then return AbortInit(); end

local g_bNoGoodyHuts:boolean = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
print("'No Tribal Villages':", g_bNoGoodyHuts);
if g_bNoGoodyHuts then return AbortInit(); end

local g_sHutType:string = "IMPROVEMENT_GOODY_HUT";
local g_iHutIndex:number = GameInfo.Improvements[g_sHutType].Index or -1;
print(string.format("GameInfo.Improvements[%s]: %d", g_sHutType, g_iHutIndex));
if (g_iHutIndex < 0) then return AbortInit(); end

local g_sNotification:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE");
local g_sRowOfDashes:string = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";

local g_kGoodyHuts:table = {};
local g_kGoodyPlots:table = {};
local g_kStrategicResources:table = {};
local g_kNavalConversion:table = {};
local g_kFallbackClasses:table = {};

--[[ =========================================================================
	table HostileVillagers 
=========================================================================== ]]
print("Configuring Hostile Unit lookup table . . .");
local HostileVillagers:table = {};
for row in GameInfo.HostileVillagerUnits() do 
    local class:string = row.PromotionClass;
    HostileVillagers[class] = HostileVillagers[class] or {};
    local era:number = GameInfo.Eras[row.EraType].Index;
    local unitType:string = row.UnitType;
    local kUnit:table = GameInfo.Units[unitType];
    local tech:string = kUnit.PrereqTech;
    local resource:string = kUnit.StrategicResource;
    local t:table = {};
    t.Class = class;
    t.EraType = row.EraType;
    t.UnitType = unitType;
    t.Tech = tech and GameInfo.Technologies[tech].Index or -1;
    t.Resource = resource and GameInfo.Resources[resource].Index or -1;
    HostileVillagers[class][era] = t;
end

--[[ =========================================================================
	function StrangeThings() 
=========================================================================== ]]
function StrangeThings( s:string ) 
    local msg:string = "Strange things are afoot at the Circle K";
    if s and s ~= nil then 
        msg = string.format("%s: %s", msg, s);
    end
    print(msg);
    return;
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
function GetPlotsWithImprovement( i:number ) 
    local gridWidth:number = 0;
    local gridHeight:number = 0;
    gridWidth, gridHeight = Map.GetGridSize();
    local numMapPlots:number = gridWidth * gridHeight;
    local pPlot:object = nil;
    local plots:table = {};
    local p:number = 0;
    for n = 0, (numMapPlots - 1), 1 do 
        pPlot = Map.GetPlotByIndex(n);
        if (pPlot:GetImprovementType() == i) then 
            p = p + 1;
            plots[p] = pPlot;
        end
    end
    return plots;
end

--[[ =========================================================================
	function GetPlotsWithGoodyHut() 
    this is a wrapper for GetPlotsWithImprovement(g_iHutIndex)
    returns: 
        a table of all plots which contain IMPROVEMENT_GOODY_HUT
=========================================================================== ]]
function GetPlotsWithGoodyHut() 
    return GetPlotsWithImprovement(g_iHutIndex);
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetAdjacentPlotData( pTargetPlot:object, i:number, r:number ) 
    local exclude:table = { [pTargetPlot] = true };
    local x:number = pTargetPlot:GetX();
    local y:number = pTargetPlot:GetY();
    local resources:table = {};
    local n:number = 0;
    local ring:table = {};
    local camp:table = {};
    local unit:table = {};
    for l = 1, r do 
        ring[l] = Map.GetRingPlots(x, y, l);
        for _, pPlot in ipairs(ring[l]) do 
            for _, s in ipairs(g_kStrategicResources) do 
                resources[s] = resources[s] or {};
                if (pPlot:GetResourceType() == s) then 
                    n = #resources[s] + 1;
                    resources[s][n] = pPlot;
                    if l > 1 then 
                        exclude[pPlot] = true;
                    end
                end
            end
            if not pPlot:IsImpassable() and not pPlot:IsMountain() then 
                if not pPlot:IsNaturalWonder() and not pPlot:IsLake() then 
                    if (l == 1) then 
                        n = #unit + 1;
                        unit[n] = pPlot;
                    elseif (l == 2 and not exclude[pPlot]) then 
                        if (pPlot:GetResourceType() == -1) then 
                            if IsValidPlotForImprovement(pPlot, g_iCampIndex) then 
                                n = #camp + 1;
                                camp[n] = pPlot;
                            end
                        end
                    end
                end
            end
        end
    end
    local t:table = {};
    t.X = x;
    t.Y = y;
    t.Exclude = exclude;
    t.Ring = ring;
    t.Camp = camp;
    t.Unit = unit;
    t.Index = i;
    t.Resources = resources;
    return t;
end

--[[ =========================================================================
	Hostile Rewards 
=========================================================================== ]]
print("Configuring Hostile 'Reward' hash lookup table . . .");
local HostileRewards:table = {};
for row in GameInfo.GoodyHutSubTypes() do 
    if (row.GoodyHut == "GOODYHUT_HOSTILES") then 
        local subtype:string = row.SubTypeGoodyHut;
        local hash:number = DB.MakeHash(subtype);
        HostileRewards[hash] = row;
        -- vprint(string.format("[%d] = ", hash), subtype);
    end
end

local HostileReward:table = {};
HostileReward.__index = HostileReward;
setmetatable(HostileReward, {
    __call = function (meta, hash, t) 
        local self:table = setmetatable({}, meta);
        self.__index = self;
        return self:New(hash, t);
    end, 
});

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:New( hash:number, t:table ) 
    local h:table = GameInfo.GoodyHutSubTypes_HGHR[t.SubTypeGoodyHut];
    for row in GameInfo.HostileRewardMembers() do 
        if t[row.Name] then 
            self[row.Name] = t[row.Name];
        elseif h[row.Name] then 
            self[row.Name] = h[row.Name];
        end
    end
    self.Hash = hash;
    return self;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:Copy() 
    local t:table = {};
    for row in GameInfo.HostileRewardMembers() do 
        t[row.Name] = self[row.Name];
    end
    return t;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:GetPromotionClass() 
    local class:string = self.PromotionClass;
    return class;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:GetEligibleUnit( class:string ) 
    class = class and class or self.PromotionClass and self.PromotionClass or "PROMOTION_CLASS_MELEE";
    print(class, self.Era);
    local pPlayer:object = Players[g_iBarbarianID];
    local pPlayerTechs:object = pPlayer:GetTechs();
    for e = self.Era, 0, -1 do 
        local kUnit:table = HostileVillagers[class][e];
        local unitType:string = kUnit.UnitType;
        local t:number = kUnit.Tech;
        local r:number = kUnit.Resource;
        if (t == -1) then 
            return unitType;
        elseif pPlayerTechs:HasTech(t) then 
            if (r == -1) then 
                return unitType;
            else 
                if self.NearbyResources[r] then 
                    return unitType;
                end
            end
        end
    end
    return nil;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:PlaceCamp( plots:table ) 
    local remove:table = {};
    local r:number = 0;
    vprint("Verifying", #plots, "identified plots . . .");
    for i, pPlot in ipairs(plots) do 
        if (pPlot:GetUnitCount() ~= 0) then 
            r = r + 1;
            remove[r] = i;
        else 
            if (pPlot:GetResourceType() ~= -1) then 
                r = r + 1;
                remove[r] = i;
            else 
                if not IsValidPlotForImprovement(pPlot, g_iCampIndex) then 
                    r = r + 1;
                    remove[r] = i;
                end
            end
        end
    end
    if (r > 0) then 
        for i = r, 1, -1 do 
            table.remove(plots, remove[i]);
        end
    end
    vprint(#plots, "valid plots remain for", g_sCampType);
    if (#plots < 1) then 
        vprint("Increasing hostile unit output");
        return 2;
    end
    local bCampPlaced:boolean = false;
    local numAttempts:number = 0;
    local cX:number = -1;
    local cY:number = -1;
    while (not bCampPlaced and #plots > 0) do 
        numAttempts = numAttempts + 1;
        local i:number = #plots;
        local pPlot:object = plots[i];
        plots[i] = nil;
        ImprovementBuilder.SetImprovementType(pPlot, g_iCampIndex, g_iBarbarianID);
        if (pPlot:GetImprovementType() == g_iCampIndex) then 
            cX = pPlot:GetX();
            cY = pPlot:GetY();
            bCampPlaced = true;
            vprint(cX, cY, g_sCampType, bCampPlaced, numAttempts);
        end
    end
    if not bCampPlaced then 
        vprint(self.X, self.Y, g_sCampType, bCampPlaced, numAttempts);
        vprint("Increasing hostile unit output");
        return 2;
    elseif bCampPlaced and Players[self.Player]:IsHuman() then 
        local message:string = g_sNotification;
        local summary:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_CAMP");
        NotificationManager.SendNotification(self.Player, NotificationTypes.NEW_BARBARIAN_CAMP, message, summary, cX, cY);
    end
    return 0;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:PlaceUnits( plots:table, num:number ) 
    local numLandPlots:number = 0;
    local numWaterPlots:number = 0;
    local remove:table = {};
    local r:number = 0;
    vprint("Verifying", #plots, "identified plots . . .");
    for i, pPlot in ipairs(plots) do 
        if (pPlot:GetUnitCount() == 0) then 
            if not pPlot:IsWater() then 
                numLandPlots = numLandPlots + 1;
            elseif pPlot:IsWater() then 
                numWaterPlots = numWaterPlots + 1;
            end
        else 
            r = r + 1;
            remove[r] = i;
        end
    end
    if (r > 0) then 
        for i = r, 1, -1 do 
            table.remove(plots, remove[i]);
        end
    end
    vprint(#plots, "valid plots remain for a unit");
    if (#plots < 1) then 
        return;
    end
    vprint(numLandPlots, "plots are valid for a land unit");
    vprint(numWaterPlots, "plots are valid for a naval unit");
    local class:string = self:GetPromotionClass();
    local unitType:string = "";
    for n = 1, self.NumUnits do 
        local newClass:string = "";
        local bUnitPlaced:boolean = false;
        local numAttempts:number = 0;
        local uX:number = -1;
        local uY:number = -1;
        while (not bUnitPlaced and #plots > 0) do 
            numAttempts = numAttempts + 1;
            local i:number = (#plots % 2 == 0) and #plots or 1;
            local pPlot:object = plots[i];
            table.remove(plots, i);
            uX = pPlot:GetX();
            uY = pPlot:GetY();
            if not pPlot:IsWater() then 
                unitType = self:GetEligibleUnit(class);
            elseif pPlot:IsWater() then 
                newClass = g_kNavalConversion[class];
                unitType = self:GetEligibleUnit(newClass);
            end
            if not unitType then 
                newClass = g_kFallbackClasses[class];
                unitType = self:GetEligibleUnit(newClass);
                if not unitType then 
                    return StrangeThings();
                end
            end
            UnitManager.InitUnit(g_iBarbarianID, unitType, uX, uY);
            if (pPlot:GetUnitCount() > 0) then 
                bUnitPlaced = true;
                vprint(uX, uY, n, self.NumUnits, unitType, bUnitPlaced, numAttempts);
            end
        end
        if not bUnitPlaced then 
            vprint(self.X, self.Y, n, self.NumUnits, unitType, bUnitPlaced, numAttempts);
        elseif bUnitPlaced and Players[self.Player]:IsHuman() then 
            local unitName:string = Locale.Lookup(GameInfo.Units[unitType].Name);
            local message:string = g_sNotification;
            local summary:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_UNIT", 1, unitName);
            NotificationManager.SendNotification(self.Player, NotificationTypes.BARBARIANS_SIGHTED, message, summary, uX, uY);
        end
    end
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function HostileReward:Activate() 
    print(self.Activate, self.SubTypeGoodyHut);
    self.Era = IsExpansionRuleset() and Game.GetEras():GetCurrentEra() or Players[g_iBarbarianID]:GetEras():GetEra();
    local pThisPlot:object = Map.GetPlot(self.X, self.Y);
    if pThisPlot and g_kGoodyPlots[pThisPlot] then 
        local t:table = g_kGoodyPlots[pThisPlot];
        vprint(self.X, self.Y, "is Index", t.Index, "in the global tracker");
        local bNearbyHorses:boolean = false;
        for _, r in ipairs(g_kStrategicResources) do 
            if #t.Resources[r] > 0 then 
                local resource:string = GameInfo.Resources[r].ResourceType;
                vprint(resource, "in", #t.Resources[r], "plots within", #t.Ring, "plots");
                if (resource == "RESOURCE_HORSES") then 
                    bNearbyHorses = true;
                end
            end
        end
        if self.Outpost then 
            vprint(#t.Camp, "identified plots are valid for", g_sCampType);
            if (#t.Camp < 1) then 
                vprint("Increasing hostile unit output");
                self.NumUnits = self.NumUnits + 2;
            else 
                self.NumUnits = self.NumUnits + self:PlaceCamp(t.Camp);
            end
        end
        vprint(#t.Unit, "identified plots are valid for a unit");
        if (#t.Unit < 1) then 
            return;
        end
        self:PlaceUnits(t.Unit);
    else 
        vprint(self.X, self.Y, " is 'NOT' in the global tracker");
    end
    return;
end

--[[ =========================================================================
	listener function OnGoodyHutReward() 
=========================================================================== ]]
function HostileVillagers_OnGoodyHutReward( player:number, unit:number, goodyhut:number, subtype:number ) 
    if not HostileRewards[subtype] then return; end
    print(player, unit, goodyhut, subtype);
    if (player == -1) then 
        return StrangeThings("player = -1");
    end
    if (unit == -1) then 
        return StrangeThings("unit = -1");
    end
    local pUnit:object = UnitManager.GetUnit(player, unit);
    if not pUnit then 
        return StrangeThings(string.format("unit %d for player %d is invalid", unit, player));
    end
    local plotX:number = pUnit:GetX();
    local plotY:number = pUnit:GetY();
    if (plotX < 0 or plotY < 0) then 
        return StrangeThings(string.format("plot (x %d, y %d) is invalid", plotX, plotY));
    end
    local reward:table = HostileReward(subtype, HostileRewards[subtype]);
    reward.Player = player;
    reward.Unit = unit;
    reward.X = plotX;
    reward.Y = plotY;
    return reward:Activate();
end

--[[ =========================================================================
	listener function OnImprovementActivated() 
=========================================================================== ]]
function HostileVillagers_OnImprovementActivated( x:number, y:number, player:number, unit:number, improvement:number, owner:number, activation:number ) 
    local bIsCamp:boolean = (improvement == g_iCampIndex);
    local bIsHut:boolean = (improvement == g_iHutIndex);
    if not bIsHut then return; end
    print(x, y, player, unit, improvement, owner, activation);
    return;
end

--[[ =========================================================================
	configure required components
=========================================================================== ]]
function HostileVillagers_Initialize() 
    print("Validating Hostile 'Reward' hash lookup table . . .");
    for row in GameInfo.GoodyHutSubTypes() do 
        if (row.GoodyHut == "GOODYHUT_HOSTILES") then 
            local subtype:string = row.SubTypeGoodyHut;
            local hash:number = DB.MakeHash(subtype);
            vprint(string.format("[%d] =", hash), subtype, HostileRewards[hash]);
        end
    end
    print("Validating Hostile Unit lookup table . . .");
    for row in GameInfo.HostileVillagerUnits() do 
        local class:string = row.PromotionClass;
        local era:number = GameInfo.Eras[row.EraType].Index;
        local kUnit:table = HostileVillagers[class][era];
        vprint(string.format("[%s][%d] = {%s, %d, %d}", class, era, kUnit.UnitType, kUnit.Tech, kUnit.Resource));
    end
    print("Configuring Hostile Unit Naval Conversion table . . .");
    for row in GameInfo.HostileNavalConversion() do 
        g_kNavalConversion[row.PromotionClass] = row.NewPromotionClass;
        vprint(string.format("[%s] --> %s", row.PromotionClass, row.NewPromotionClass));
    end
    print("Configuring Hostile Unit Fallback Class table . . .");
    for row in GameInfo.HostileUnitFallback() do 
        g_kFallbackClasses[row.PromotionClass] = row.NewPromotionClass;
        vprint(string.format("[%s] --> %s", row.PromotionClass, row.NewPromotionClass));
    end
    local i:number = 0;
    print("Configuring Strategic Resource lookup table . . .");
    for row in GameInfo.Resources() do 
        if row.ResourceClassType == "RESOURCECLASS_STRATEGIC" then 
            i = #g_kStrategicResources + 1;
            g_kStrategicResources[i] = row.Index;
            vprint(string.format("[%d] = %s (%d)", i, row.ResourceType, row.Index));
        end
    end
    -- print(g_sRowOfDashes);
    g_kGoodyHuts = GetPlotsWithGoodyHut();
    local numHuts:number = #g_kGoodyHuts;
    print(string.format("Identified %d Tribal Village%s at startup", numHuts, (numHuts ~= 1) and "s" or ""));
    for i, pPlot in ipairs(g_kGoodyHuts) do 
        g_kGoodyPlots[pPlot] = GetAdjacentPlotData(pPlot, i, 3);
    end
    -- print(g_sRowOfDashes);
    print("Configuring listener for Events.GoodyHutReward . . .");
    Events.GoodyHutReward.Add(HostileVillagers_OnGoodyHutReward);
    -- Events.ImprovementActivated.Add(HostileVillagers_OnImprovementActivated);
    print("Initialization complete");
    -- return;
end

--[[ =========================================================================
	defer execution of Initialize() to LoadScreenClose
=========================================================================== ]]
print(string.format("Deferring additional configuration for %s to LoadScreenClose", g_sRuleset));
Events.LoadScreenClose.Add(HostileVillagers_Initialize);

--[[ =========================================================================
	End HostileVillagers.lua gameplay script
=========================================================================== ]]
