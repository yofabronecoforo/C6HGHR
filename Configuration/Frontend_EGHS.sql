/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin frontend setup for Enhanced Goody Hut Setup integration

    Enhanced Goody Hut Setup (EGHS)
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.
=========================================================================== */

-- content flags for picker tooltips
-- this transaction will throw an error when EGHS is not present and enabled
-- when this happens, the other transactions below will not be executed
-- this is expected behavior
REPLACE INTO ContentFlags 
    (Id, Name, Tooltip, Frontend, CityStates, GoodyHuts, Leaders, NaturalWonders, RULESET_STANDARD, RULESET_EXPANSION_1, RULESET_EXPANSION_2)
VALUES 
    ('eccf6466-03f4-46de-96ba-98fcd1e10b90', 'HGHR', 'LOC_HGHR_TT', 1, 0, 1, 0, 0, 1, 1, 1);

-- configure types for Standard
-- if EGHS is enabled, these will be configured for other rulesets by its frontend configuration
REPLACE INTO TribalVillageTypes (GoodyHut, NumRewards, Name, Description, Icon)
VALUES 
    ('GOODYHUT_HOSTILES', 15, 'LOC_EGHS_GOODYHUT_HOSTILES_NAME', 'LOC_EGHS_GOODYHUT_HOSTILES_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN');

-- configure rewards for Standard
-- if EGHS is enabled, these will be configured for other rulesets by its frontend configuration
REPLACE INTO TribalVillageRewards (GoodyHut, SubTypeGoodyHut, Turn, MinOneCity, RequiresUnit, Name, Description, Icon, IconFG, Weight, DefaultWeight)
VALUES 
    -- ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RECON_1', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    -- ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RECON_2', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    -- ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RECON_3', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RECON_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_1', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_2', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_3', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_MELEE_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RANGED_1', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RANGED_2', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_RANGED_3', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_RANGED_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_ANTI_CAVALRY_1', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_ANTI_CAVALRY_2', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_ANTI_CAVALRY_3', 2, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_ANTI_CAVALRY_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_HEAVY_CAVALRY_1', 30, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_HEAVY_CAVALRY_2', 30, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_HEAVY_CAVALRY_3', 30, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_HEAVY_CAVALRY_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_LIGHT_CAVALRY_1', 60, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_1_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_1_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 55, 55), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_LIGHT_CAVALRY_2', 60, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_2_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_2_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 30, 30), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_LIGHT_CAVALRY_3', 60, 0, 1, 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_3_NAME', 'LOC_EGHS_GOODYHUT_HOSTILE_LIGHT_CAVALRY_3_DESCRIPTION', 'ICON_CIVILIZATION_BARBARIAN', NULL, 15, 15);

/* ===========================================================================
    End frontend setup
=========================================================================== */
