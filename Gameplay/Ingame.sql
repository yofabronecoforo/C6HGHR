/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup
=========================================================================== */

-- experience cap from killing barbarian units; default Value = 1
UPDATE GlobalParameters SET Value = 3 WHERE Name = 'EXPERIENCE_BARB_SOFT_CAP';

-- no experience from killing barbarian units at this level; default Value = 2
UPDATE GlobalParameters SET Value = 5 WHERE Name = 'EXPERIENCE_MAX_BARB_LEVEL';

-- experience earned from activating a goody hut; default Value = 10 (Pre XP2) | 8 (XP2 and beyond) [maybe now a hard 5 by default? fuck it]
UPDATE GlobalParameters SET Value = 3 WHERE Name = 'EXPERIENCE_ACTIVATE_GOODY_HUT';

-- 
REPLACE INTO Types
    (Type, Kind)
VALUES
    -- Hostile Villagers "rewards"
    ('GOODYHUT_HOSTILES', 'KIND_GOODY_HUT');

-- 
REPLACE INTO GoodyHuts
    (GoodyHutType, Weight)
VALUES
    -- Hostile Villagers "rewards"
    ('GOODYHUT_HOSTILES', 100);

-- new GoodyHutSubTypes
REPLACE INTO GoodyHutSubTypes
    (GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, MinOneCity, RequiresUnit, ModifierID)
VALUES
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_1', 'LOC_GOODYHUT_HOSTILE_MELEE_1_DESCRIPTION', 55, 2, 0, 1, 'GOODY_HGHR_DUMMY_REWARD'),
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_2', 'LOC_GOODYHUT_HOSTILE_MELEE_2_DESCRIPTION', 30, 2, 0, 1, 'GOODY_HGHR_DUMMY_REWARD'),
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_MELEE_3', 'LOC_GOODYHUT_HOSTILE_MELEE_3_DESCRIPTION', 15, 2, 0, 1, 'GOODY_HGHR_DUMMY_REWARD');

-- new Modifiers
REPLACE INTO Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES
    -- dummy modifier - for use by rewards implemented via lua
    ('GOODY_HGHR_DUMMY_REWARD', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE', 1, 1, NULL);
    
-- new ModifierArguments
REPLACE INTO ModifierArguments
    (ModifierId, Name, Value, Extra)
VALUES
    -- dummy modifier - for use by rewards implemented via lua
    ('GOODY_HGHR_DUMMY_REWARD', 'Amount', 0, NULL),
    ('GOODY_HGHR_DUMMY_REWARD', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_HGHR_DUMMY_REWARD', 'Scale', 0, NULL);
    
-- unit rewards by game Era
-- REPLACE INTO UnitRewards
--     (Era, Recon, Melee, Ranged, AntiCavalry, HeavyCavalry, LightCavalry, Siege, Support, NavalMelee, NavalRanged)
-- VALUES
--     -- 
--     (0, 'UNIT_SCOUT', 'UNIT_WARRIOR', 'UNIT_SLINGER', 'UNIT_SPEARMAN', 'UNIT_HEAVY_CHARIOT', 'UNIT_HORSEMAN', 'UNIT_CATAPULT', 'UNIT_BATTERING_RAM', 'UNIT_GALLEY', 'UNIT_QUADRIREME'),
--     (1, 'UNIT_SCOUT', 'UNIT_SWORDSMAN', 'UNIT_ARCHER', 'UNIT_SPEARMAN', 'UNIT_HEAVY_CHARIOT', 'UNIT_HORSEMAN', 'UNIT_CATAPULT', 'UNIT_BATTERING_RAM', 'UNIT_GALLEY', 'UNIT_QUADRIREME'),
--     (2, 'UNIT_SCOUT', 'UNIT_MAN_AT_ARMS', 'UNIT_CROSSBOWMAN', 'UNIT_PIKEMAN', 'UNIT_KNIGHT', 'UNIT_HORSEMAN', 'UNIT_TREBUCHET', 'UNIT_SIEGE_TOWER', 'UNIT_GALLEY', 'UNIT_QUADRIREME'),
--     (3, 'UNIT_SCOUT', 'UNIT_MUSKETMAN', 'UNIT_CROSSBOWMAN', 'UNIT_PIKEMAN', 'UNIT_KNIGHT', 'UNIT_HORSEMAN', 'UNIT_BOMBARD', 'UNIT_SIEGE_TOWER', 'UNIT_CARAVEL', 'UNIT_FRIGATE'),
--     (4, 'UNIT_RANGER', 'UNIT_LINE_INFANTRY', 'UNIT_FIELD_CANNON', 'UNIT_PIKEMAN', 'UNIT_KNIGHT', 'UNIT_CAVALRY', 'UNIT_BOMBARD', 'UNIT_MEDIC', 'UNIT_IRONCLAD', 'UNIT_FRIGATE'),
--     (5, 'UNIT_RANGER', 'UNIT_INFANTRY', 'UNIT_FIELD_CANNON', 'UNIT_AT_CREW', 'UNIT_TANK', 'UNIT_CAVALRY', 'UNIT_ARTILLERY', 'UNIT_MEDIC', 'UNIT_IRONCLAD', 'UNIT_BATTLESHIP'),
--     (6, 'UNIT_RANGER', 'UNIT_INFANTRY', 'UNIT_MACHINE_GUN', 'UNIT_AT_CREW', 'UNIT_TANK', 'UNIT_HELICOPTER', 'UNIT_ARTILLERY', 'UNIT_MEDIC', 'UNIT_DESTROYER', 'UNIT_BATTLESHIP'),
--     (7, 'UNIT_RANGER', 'UNIT_MECHANIZED_INFANTRY', 'UNIT_MACHINE_GUN', 'UNIT_MODERN_AT', 'UNIT_MODERN_ARMOR', 'UNIT_HELICOPTER', 'UNIT_ROCKET_ARTILLERY', 'UNIT_MEDIC', 'UNIT_DESTROYER', 'UNIT_MISSILE_CRUISER'),
--     (8, 'UNIT_RANGER', 'UNIT_MECHANIZED_INFANTRY', 'UNIT_MACHINE_GUN', 'UNIT_MODERN_AT', 'UNIT_MODERN_ARMOR', 'UNIT_HELICOPTER', 'UNIT_ROCKET_ARTILLERY', 'UNIT_MEDIC', 'UNIT_DESTROYER', 'UNIT_MISSILE_CRUISER');

/* ===========================================================================
    End ingame setup
=========================================================================== */
