--[[ =========================================================================
	Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin HostilityCheck.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script HostilityCheck.lua . . .");

--[[ =========================================================================
	
=========================================================================== ]]
local HostileVillagers:table = {};

--[[ =========================================================================
	listener function OnGoodyHutReward() 
=========================================================================== ]]
function HostilityCheck_OnGoodyHutReward(player, unit, typeHash, subtypeHash) 
    if HostileVillagers[subtypeHash] then return; end
    if (player == -1) then return; end
    if (unit == -1) then return; end
    local pUnit:object = UnitManager.GetUnit(player, unit);
    local plotX:number = pUnit:GetX();
    local plotY:number = pUnit:GetY();
    -- HostileVillagers[subtypeHash]:Grant(plotX, plotY);
    return;
end

--[[ =========================================================================
	listener function OnImprovementActivated() 
=========================================================================== ]]
function HostilityCheck_OnImprovementActivated(plotX, plotY, owner, unit, improvementIndex, improvementOwner, activationType) 
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
=========================================================================== ]]
function HostilityCheck_OnTurnEnd() 
    -- if (Goodies.iNumGoodyHuts < 1) then return; end
    -- local currentTurn:number = Game.GetCurrentGameTurn();
    -- local total:number = 0;
    -- for _, pPlayer in ipairs(Game.GetPlayers()) do 
    --     local count:number = pPlayer:GetProperty("HUTS_THIS_TURN") or 0;
    --     if (count > 0) then 
    --         total = total + count;
    --     end
    --     pPlayer:SetProperty("HUTS_THIS_TURN", 0);
    -- end
    -- print(string.format("Turn %d: %d total goody hut%s activated", currentTurn, total, (total ~= 1) and "s" or ""));
    -- Goodies.iNumGoodyHuts = Goodies:GetNumGoodyHuts();
    -- print(string.format("%d goody hut%s remain", Goodies.iNumGoodyHuts, (Goodies.iNumGoodyHuts ~= 1) and "s" or ""));
    -- return;
end

--[[ =========================================================================
	configure required components
=========================================================================== ]]
function HostilityCheck_Initialize() 
    print("Fetching required exposed members . . .");
    HostileVillagers = ExposedMembers.HostileVillagers;
    print("Configuring ingame Event listeners . . .");
    Events.GoodyHutReward.Add(HostilityCheck_OnGoodyHutReward);
    Events.ImprovementActivated.Add(HostilityCheck_OnImprovementActivated);
    Events.TurnEnd.Add(HostilityCheck_OnTurnEnd);
    print("Initialization complete");
    return;
end

--[[ =========================================================================
	defer execution of Initialize() to LoadScreenClose
=========================================================================== ]]
print("Deferring configuration of required components to LoadScreenClose");
Events.LoadScreenClose.Add(HostilityCheck_Initialize);

--[[ =========================================================================
	End HostilityCheck.lua gameplay script
=========================================================================== ]]
