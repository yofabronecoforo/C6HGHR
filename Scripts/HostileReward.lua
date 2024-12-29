--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin HostileReward.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script HostileReward.lua . . .");

--[[ =========================================================================
	table HostileVillagers will be an exposed HGHR object
    there is certainly a smarter way of doing this, but it ain't broke
=========================================================================== ]]
local HostileVillagers:table = {};
local HGHR:table = {};
HGHR.__index = HGHR;
setmetatable(HGHR, {
    __call = function (class, t) 
        local self = setmetatable({}, class);
        return self:New(t);
    end, 
});

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetHostileRewardData( hash:number, t:table ) 
    t.Hash = hash;
    t.UnitType = "UNIT_WARRIOR";
    t.NumUnits = 2;
    t.Grant = GrantHostileReward;
    print(string.format("[%d] = %s (%s | %d)", hash, tostring(t.Grant), t.SubTypeGoodyHut, t.Weight));
    return t;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function GrantHostileReward( self:table, plotX:number, plotY:number ) 
    print(self.Hash, self.SubTypeGoodyHut, self.UnitType, self.NumUnits);
    for i = 1, self.NumUnits do 
        UnitManager.InitUnitValidAdjacentHex(63, self.UnitType, plotX, plotY, 1);
    end
    return;
end

--[[ =========================================================================
	creates a new HGHR object with the necessary members
    logs object member details
=========================================================================== ]]
function HGHR:New( t:table ) 
    -- this probably isn't necessary
    t = t or {};
    -- functions
    -- self.GetNumPlotsWithImprovement = GetNumPlotsWithImprovement;
    -- self.GetNumGoodyHuts = GetNumGoodyHuts;
    -- self.GetGoodyHutsByHash = GetGoodyHutsByHash;
    -- self.GetHostileRewards = GetHostileRewards;
    -- strings
    self.sRowOfDashes = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";
    self.sRulesetInUse = GameConfiguration.GetValue("RULESET");
    -- booleans
    self.bNoBarbarians = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
    self.bNoGoodyHuts = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
    -- self.bEqualizeTypes = GameConfiguration.GetValue("GAME_EQUALIZE_GOODYHUT_TYPES");
    -- self.bEqualizeRewards = GameConfiguration.GetValue("GAME_EQUALIZE_GOODYHUT_REWARDS");
    -- self.bRemoveMinTurn = GameConfiguration.GetValue("GAME_REMOVE_MINTURN");
    -- self.bDisableMeteorStrike = GameConfiguration.GetValue("GAME_DISABLE_METEOR_STRIKE");
    -- integers
    self.iBarbCampIndex = GameInfo.Improvements["IMPROVEMENT_BARBARIAN_CAMP"].Index;
    self.iGoodyHutIndex = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
    -- self.iGoodyHutFrequency = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");
    -- self.iNumGoodyHuts = 0;
    -- tables
    -- self.tEventLogQueue = {};
    -- self.tEventLogQueue[-1] = { GoodyHutReward = {}, ImprovementActivated = {} };
    -- additional init and logging
    print(string.format("Selected ruleset: %s", self.sRulesetInUse));
    print(string.format("'No Barbarians': %s", tostring(self.bNoBarbarians)));
    if not self.bNoBarbarians then 
        print(string.format("Database index of Barbarian Camp: %d", self.iBarbCampIndex));
    end
    print(string.format("'No Tribal Villages': %s", tostring(self.bNoGoodyHuts)));
    if not self.bNoGoodyHuts then 
        print(string.format("Database index of Tribal Village: %d", self.iGoodyHutIndex));
        -- print(string.format("Tribal Village distribution: %d", (self.iGoodyHutFrequency * 25)) .. "%% of baseline");
        -- print("Identifying goody hut plots . . .");
        -- self.iNumGoodyHuts = self:GetNumGoodyHuts();
        -- print(string.format("There %s %d goody hut%s on the map at startup", (self.iNumGoodyHuts ~= 1) and "are" or "is", self.iNumGoodyHuts, (self.iNumGoodyHuts ~= 1) and "s" or ""));
        -- print(string.format("Equalize active Tribal Village Type Weights: %s", tostring(self.bEqualizeTypes)));
        -- print("Configuring Tribal Village Type hash lookup table . . .");
        -- self.tGoodyHutTypesByHash = self:GetGoodyHutsByHash("type");
        -- print(string.format("Equalize active Tribal Village Reward Weights: %s", tostring(self.bEqualizeRewards)));
        print("Configuring Hostile Villager hash lookup table . . .");
        local query:string = "SELECT * FROM GoodyHutSubTypes WHERE Weight > 0 AND GoodyHut = 'GOODYHUT_HOSTILES'";
        local hostiles:table = DB.Query(query);
        if (hostiles and #hostiles > 0) then 
            for _, row in ipairs(hostiles) do 
                -- local subtype:string = row.SubTypeGoodyHut;
                local hash:number = DB.MakeHash(row.SubTypeGoodyHut);
                -- print(hash, subtype);
                self[hash] = GetHostileRewardData(hash, row);
            end
        end
        -- self.Grant = self:GetHostileRewards("reward");
        -- print(string.format("Remove minimum turn requirements for active Rewards: %s", tostring(self.bRemoveMinTurn)));
        -- if (self.sRulesetInUse == "RULESET_EXPANSION_2") then 
        --     print(string.format("Disable Meteor Strike Goodies: %s", tostring(self.bDisableMeteorStrike)));
        -- end
        -- local players:table = Game.GetPlayers();
        -- print(string.format("There are %d Players at startup", #players));
        -- print("Configuring Event log queues . . .");
        -- for _, pPlayer in ipairs(players) do 
        --     local p:number = pPlayer:GetID();
        --     self.tEventLogQueue[p] = { GoodyHutReward = {}, ImprovementActivated = {} };
        -- end
    end
    return self;
end

--[[ =========================================================================
	function 
=========================================================================== ]]
function GetHostileRewards( self:table, item:string ) 
    if (item ~= "type" and item ~= "reward") then return; end
    local t:table = {};
    local dbColumn:string = (item == "type") and "GoodyHutType" or "SubTypeGoodyHut";
    local dbTable:string = (item == "type") and "GoodyHuts" or "GoodyHutSubTypes";
    local dbExclude:string = (item == "type") and "GoodyHutType" or "GoodyHut";
    local totalQuery:string = string.format("SELECT %s AS Value FROM %s WHERE %s = 'GOODYHUT_HOSTILES'", dbColumn, dbTable, dbExclude);
    local total:table = DB.Query(totalQuery);
    local activeQuery:string = string.format("SELECT %s AS Value, Weight FROM %s WHERE Weight > 0 AND %s = 'GOODYHUT_HOSTILES'", dbColumn, dbTable, dbExclude);
    local active:table = DB.Query(activeQuery);
    for _, row in ipairs(active) do 
        local v:string = row.Value;
        local hash:number = DB.MakeHash(v);
        -- self[hash] = v;
        -- t[hash] = v;
        t[hash] = GrantHostileReward;
        print(string.format("[%d] = %s (%s | %d)", hash, tostring(t[hash]), v, row.Weight));
    end
    print(string.format("There %s %d enabled of %d total '%s%s'", (#active ~= 1) and "are" or "is", #active, #total, item, (#total ~= 1) and "s" or ""));
    return t;
end

--[[ =========================================================================
	function GetNumPlotsWithImprovement() 
    calculates and returns the count of all plots which contain the specified Improvement
=========================================================================== ]]
function GetNumPlotsWithImprovement( improvementIndex: number ) 
    local gridWidth:number = 0;
    local gridHeight:number = 0;
    gridWidth, gridHeight = Map.GetGridSize();
    local numMapPlots:number = gridWidth * gridHeight;
    local numPlots:number = 0;
    for i = 0, (numMapPlots - 1), 1 do 
        if (Map.GetPlotByIndex(i):GetImprovementType() == improvementIndex) then 
            numPlots = numPlots + 1;
        end
    end
    return numPlots;
end

--[[ =========================================================================
	function GetNumGoodyHuts() 
    this just calls GetNumPlotsWithImprovement() with iGoodyHutIndex as its parameter
=========================================================================== ]]
function GetNumGoodyHuts( self:table ) 
    return self.GetNumPlotsWithImprovement(self.iGoodyHutIndex);
end

--[[ =========================================================================
	listener function OnGoodyHutReward() 
    aborts if the supplied (sub)type hash value is not a key in either the Types or Rewards hash tables
        currently this applies to the meteor strike event
    when the ImprovementActivated Event queue is empty:
        creates a coroutine which returns this Event's arguments when resumed
        adds this coroutine to the GoodyHutReward Event queue
    when the ImprovementActivated Event queue is NOT empty:
        retrieves the coroutine in the [1] index and removes it from the queue
        resumes this coroutine and captures its arguments
        sends consolidated Event arguments to ValidateReward() for logging
=========================================================================== ]]
function HGHR_OnGoodyHutReward(player, unit, typeHash, subtypeHash) 
    if (player == -1) then return; end
    if (unit == -1) then return; end
    if not HostileVillagers[subtypeHash] then return; end
    local pUnit:object = UnitManager.GetUnit(player, unit);
    local plotX:number = pUnit:GetX();
    local plotY:number = pUnit:GetY();
    HostileVillagers[subtypeHash]:Grant(plotX, plotY);
    -- local hutType:string = Goodies.tGoodyHutTypesByHash[typeHash];
    -- local hutReward:string = Goodies.tGoodyHutRewardsByHash[subtypeHash];
    -- if not hutType or not hutReward then return; end
    -- if (#Goodies.tEventLogQueue[player].ImprovementActivated == 0) then 
    --     local co = coroutine.create( function () 
    --         local player = player;
    --         local typeHash = typeHash;
    --         local hutType = hutType;
    --         local subtypeHash = subtypeHash;
    --         local hutReward = hutReward;
    --         return player, typeHash, hutType, subtypeHash, hutReward;
    --     end);
    --     print(co, coroutine.status(co));
    --     table.insert(Goodies.tEventLogQueue[player].GoodyHutReward, co);
    -- elseif (#Goodies.tEventLogQueue[player].ImprovementActivated > 0) then 
    --     local co = Goodies.tEventLogQueue[player].ImprovementActivated[1];
    --     table.remove(Goodies.tEventLogQueue[player].ImprovementActivated, 1);
    --     local success, plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType, civTypeName = coroutine.resume(co);
    --     print(co, coroutine.status(co));
    --     return ValidateReward(player, typeHash, hutType, subtypeHash, hutReward, plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType, civTypeName);
    -- else 
    --     print("Strange things are afoot at the Circle K");
    -- end
    -- print(player, unit, typeHash, subtypeHash);
    -- return;
end

--[[ =========================================================================
	listener function OnImprovementActivated() 
    immediately aborts when the the activated Improvement is NOT a Barbarian Camp and is NOT a Goody Hut
    aborts when it IS a Barbarian Camp and the activating Player is NOT Sumeria
    when the GoodyHutReward Event queue is empty:
        creates a coroutine which returns this Event's arguments when resumed
        adds this coroutine to the ImprovementActivated Event queue
    when the GoodyHutReward Event queue is NOT empty:
        retrieves the coroutine in the [1] index and removes it from the queue
        resumes this coroutine and captures its arguments
        sends consolidated Event arguments to ValidateReward() for logging
=========================================================================== ]]
function EGHS_OnImprovementActivated(plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType) 
    -- local isBarbCamp:boolean = (improvementIndex == Goodies.iBarbCampIndex);
	-- local isGoodyHut:boolean = (improvementIndex == Goodies.iGoodyHutIndex);
	-- if not isBarbCamp and not isGoodyHut then return; end
    -- local player:number = (owner > -1) and owner or improvementOwner;
    -- local pPlayerConfig:object = PlayerConfigurations[player];
    -- local civTypeName:string = pPlayerConfig:GetCivilizationTypeName();
    -- if (isBarbCamp and civTypeName ~= "CIVILIZATION_SUMERIA") then return; end
    -- if (#Goodies.tEventLogQueue[owner].GoodyHutReward == 0) then 
    --     local co = coroutine.create( function () 
    --         local plotX = plotX;
    --         local plotY = plotY;
    --         local owner = owner;
    --         local unit = unit;
    --         local improvementIndex = improvementIndex;
    --         local improvementOwner = improvementOwner;
    --         local activationType = activationType;
    --         local civTypeName = civTypeName;
    --         return plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType, civTypeName;
    --     end);
    --     print(co, coroutine.status(co));
    --     table.insert(Goodies.tEventLogQueue[owner].ImprovementActivated, co);
    -- elseif (#Goodies.tEventLogQueue[owner].GoodyHutReward > 0) then 
    --     local co = Goodies.tEventLogQueue[owner].GoodyHutReward[1];
    --     table.remove(Goodies.tEventLogQueue[owner].GoodyHutReward, 1);
    --     local success, player, typeHash, hutType, subtypeHash, hutReward = coroutine.resume(co);
    --     print(co, coroutine.status(co));
    --     return ValidateReward(player, typeHash, hutType, subtypeHash, hutReward, plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType, civTypeName);
    -- else 
    --     print("Strange things are afoot at the Circle K");
    -- end
    -- print(plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType);
    -- return;
end

--[[ =========================================================================
	listener function OnTurnEnd() 
    when iNumGoodyHuts is zero or less, does nothing
	otherwise:
        calculates the total number of activated goody huts this turn
        resets each Player's HUTS_THIS_TURN Property to 0
        calls GetNumGoodyHuts() to reset iNumGoodyHuts
=========================================================================== ]]
function EGHS_OnTurnEnd() 
    if (Goodies.iNumGoodyHuts < 1) then return; end
    local currentTurn:number = Game.GetCurrentGameTurn();
    local total:number = 0;
    for _, pPlayer in ipairs(Game.GetPlayers()) do 
        local count:number = pPlayer:GetProperty("HUTS_THIS_TURN") or 0;
        if (count > 0) then 
            total = total + count;
        end
        pPlayer:SetProperty("HUTS_THIS_TURN", 0);
    end
    print(string.format("Turn %d: %d total goody hut%s activated", currentTurn, total, (total ~= 1) and "s" or ""));
    Goodies.iNumGoodyHuts = Goodies:GetNumGoodyHuts();
    print(string.format("%d goody hut%s remain", Goodies.iNumGoodyHuts, (Goodies.iNumGoodyHuts ~= 1) and "s" or ""));
    return;
end

--[[ =========================================================================
	configure required components
=========================================================================== ]]
function HGHR_Initialize() 
    print("Initializing . . .");
    HostileVillagers = HGHR();
    print("Exposing members . . .");
    ExposedMembers.HostileVillagers = HostileVillagers;
    print("Configuring ingame Event listeners . . .");
    Events.GoodyHutReward.Add(HGHR_OnGoodyHutReward);
    -- Events.ImprovementActivated.Add(EGHS_OnImprovementActivated);
    -- Events.TurnEnd.Add(EGHS_OnTurnEnd);
    print("Initialization complete");
    return;
end

--[[ =========================================================================
	defer execution of Initialize() to LoadScreenClose
=========================================================================== ]]
print("Deferring configuration of required components to LoadScreenClose");
Events.LoadScreenClose.Add(HGHR_Initialize);

--[[ =========================================================================
	End HostileReward.lua gameplay script
=========================================================================== ]]
