/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin frontend setup for Enhanced Goody Hut Setup integration

    Enhanced Goody Hut Setup (EGHS)
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.
=========================================================================== */

-- content flags for picker tooltips
REPLACE INTO ContentFlags 
    (Id, Name, Tooltip, Frontend, CityStates, GoodyHuts, Leaders, NaturalWonders, RULESET_STANDARD, RULESET_EXPANSION_1, RULESET_EXPANSION_2)
VALUES 
    ('eccf6466-03f4-46de-96ba-98fcd1e10b90', 'HGHR', 'LOC_HGHR_TT', 1, 0, 1, 0, 0, 1, 1, 1);

-- configure types for Standard
-- if WGH is enabled, these will be configured for other rulesets by the main frontend configuration
REPLACE INTO TribalVillageTypes (GoodyHut, NumRewards, Name, Description, Icon)
VALUES 
    ('GOODYHUT_HOSTILE_MELEE', 3, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN');

-- configure rewards for Standard
-- if WGH is enabled, these will be configured for other rulesets by the main frontend configuration
REPLACE INTO TribalVillageRewards (GoodyHut, SubTypeGoodyHut, Turn, MinOneCity, RequiresUnit, Name, Description, Icon, IconFG, Weight, DefaultWeight)
VALUES 
    ('GOODYHUT_HOSTILE_MELEE', 'GOODYHUT_HOSTILE_MELEE_1', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILE_MELEE', 'GOODYHUT_HOSTILE_MELEE_2', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILE_MELEE', 'GOODYHUT_HOSTILE_MELEE_3', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15); 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_RANDOMIMPROVEMENT', 0, 1, 0, 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMIMPROVEMENT_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMIMPROVEMENT_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', 'ICON_UNITOPERATION_BUILD_IMPROVEMENT', 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_RANDOMPOLICY', 0, 1, 0, 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMPOLICY_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMPOLICY_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', 'ICON_POLICY_WILDCARD', 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_RANDOMRESOURCE', 0, 1, 0, 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMRESOURCE_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMRESOURCE_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', NULL, 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_RANDOMUNIT', 0, 0, 0, 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMUNIT_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_RANDOMUNIT_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', NULL, 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_SIGHTBOMB', 0, 0, 0, 'LOC_EGHS_GOODYHUT_SAILOR_SIGHTBOMB_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_SIGHTBOMB_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', NULL, 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_SPY', 0, 1, 0, 'LOC_EGHS_GOODYHUT_SAILOR_SPY_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_SPY_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', 'ICON_UNIT_SPY', 100, 100), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_TELEPORT', 0, 0, 1, 'LOC_EGHS_GOODYHUT_SAILOR_TELEPORT_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_TELEPORT_DESCRIPTION', NULL, 'ICON_DISTRICT_WONDER', 'ICON_UNITOPERATION_MOVE_TO', 0, 0), 
    -- ('GOODYHUT_SAILOR_WONDROUS', 'GOODYHUT_SAILOR_WONDER', 0, 0, 0, 'LOC_EGHS_GOODYHUT_SAILOR_WONDER_NAME', 'LOC_EGHS_GOODYHUT_SAILOR_WONDER_DESCRIPTION', 'LOC_EGHS_WONDROUS_REWARD_WARNING', 'ICON_DISTRICT_WONDER', 'ICON_NOTIFICATION_DISCOVER_NATURAL_WONDER', 100, 100);

-- remove WGH types if WGH is NOT enabled
-- this works because WGH adds a custom table to the configuration database
-- it's also a little cleaner than one or more conditional replace transactions
-- DELETE FROM TribalVillageTypes 
-- WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS' 
-- AND NOT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

-- remove WGH rewards if WGH is NOT enabled
-- this works because WGH adds a custom table to the configuration database
-- it's also a little cleaner than one or more conditional replace transactions
-- DELETE FROM TribalVillageRewards 
-- WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS' 
-- AND NOT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = 'SailorGoodyOptions');

/* ===========================================================================
    End frontend setup
=========================================================================== */
