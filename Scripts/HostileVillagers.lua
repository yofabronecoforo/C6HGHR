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
function HostileVillagers_OnGoodyHutReward( player:number, unit:number, goodyhut:number, subtype:number ) 
    local event:string = "Events.GoodyHutReward:";
    local bIsHostile:boolean = (GameInfo.GoodyHuts[goodyhut].GoodyHutType == "GOODYHUT_HOSTILES");
    print(event, player, unit, goodyhut, subtype, bIsHostile);
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_InitEventHandlers() 
    print("Configuring handler for Events.GoodyHutReward . . .");
    Events.GoodyHutReward.Add(HostileVillagers_OnGoodyHutReward);
    return;
end

--[[ =========================================================================
	
=========================================================================== ]]
function HostileVillagers_Initialize() 
    print(string.format("Finalizing configuration for %s . . .", g_sRuleset));
    HostileVillagers_InitEventHandlers();
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
