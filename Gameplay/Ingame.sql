/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin ingame setup
=========================================================================== */

-- goody hut subtype Kind; enables automatic hash generation in GameInfo
REPLACE INTO Kinds 
    (Kind) 
VALUES 
    ('KIND_GOODY_HUT_SUBTYPE');

-- hostiles type
REPLACE INTO GoodyHuts 
    (GoodyHutType, Weight) 
VALUES 
    ('GOODYHUT_HOSTILES', 100);

-- hostiles type --> Kind mapping to generate automatic hash
REPLACE INTO Types 
    (Type, Kind) 
VALUES 
    ('GOODYHUT_HOSTILES', 'KIND_GOODY_HUT');

-- hostile subtype parameters
REPLACE INTO GoodyHutSubTypes_HGHR 
	(SubTypeGoodyHut, NumUnits, Adverb) 
VALUES 
    ('GOODYHUT_LOW_HOSTILITY_VILLAGERS', 1, 'SLIGHTLY'), 
    ('GOODYHUT_MEDIUM_HOSTILITY_VILLAGERS', 2, '* MODERATELY *'), 
    ('GOODYHUT_HIGH_HOSTILITY_VILLAGERS', 3, '** VERY **'), 
    ('GOODYHUT_MAXIMUM_HOSTILITY_VILLAGERS', 4, '*** EXTREMELY ***');

-- hostile subtypes
REPLACE INTO GoodyHutSubTypes 
	(GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, ModifierID, RequiresUnit) 
VALUES 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_LOW_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILES_DESCRIPTION', 55, 0, 'GOODY_HGHR_DUMMY_REWARD', 1), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_MEDIUM_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILES_DESCRIPTION', 30, 0, 'GOODY_HGHR_DUMMY_REWARD', 1), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HIGH_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILES_DESCRIPTION', 15, 0, 'GOODY_HGHR_DUMMY_REWARD', 1), 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_MAXIMUM_HOSTILITY_VILLAGERS', 'LOC_GOODYHUT_HOSTILES_DESCRIPTION', 5, 0, 'GOODY_HGHR_DUMMY_REWARD', 1);

-- all goody hut subtype --> Kind mappings, generates automatic hashes
REPLACE INTO Types (Type, Kind) 
SELECT SubTypeGoodyHut, 'KIND_GOODY_HUT_SUBTYPE' 
FROM GoodyHutSubTypes;

-- dummy modifier for use by rewards implemented via lua; it does nothing
REPLACE INTO Modifiers 
    (ModifierId, ModifierType, RunOnce, Permanent, SubjectRequirementSetId)
VALUES 
    ('GOODY_HGHR_DUMMY_REWARD', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE', 1, 1, NULL);

-- required arguments for the dummy modifier
REPLACE INTO ModifierArguments 
    (ModifierId, Name, Value, Extra) 
VALUES 
    ('GOODY_HGHR_DUMMY_REWARD', 'Amount', 0, NULL),
    ('GOODY_HGHR_DUMMY_REWARD', 'YieldType', 'YIELD_FOOD', NULL),
    ('GOODY_HGHR_DUMMY_REWARD', 'Scale', 0, NULL);

-- type modifiers for hostility check
REPLACE INTO HostileVillagers_GoodyHuts 
	(GoodyHutType, TotalWeight) 
SELECT g.GoodyHutType, (SELECT SUM(s.Weight) FROM GoodyHutSubTypes s WHERE s.GoodyHut = g.GoodyHutType) TotalWeight 
FROM GoodyHuts g 
WHERE NOT g.GoodyHutType IN ('GOODYHUT_HOSTILES', 'METEOR_GOODIES');

-- subtype modifiers for hostility check
REPLACE INTO HostileVillagers_GoodyHutSubTypes 
    (SubTypeGoodyHut, Modifier, Threshold) 
SELECT s.SubTypeGoodyHut, 
	((h.TotalWeight - s.Weight) / 10) Modifier, 
	(((h.TotalWeight + s.Weight) / 10) + g.Weight) Threshold 
FROM GoodyHutSubTypes s, HostileVillagers_GoodyHuts h, GoodyHuts g 
WHERE s.Weight > 0 AND s.GoodyHut = h.GoodyHutType 
GROUP BY s.SubTypeGoodyHut;

-- unit pool for hostility check average/maximum combat modifiers
REPLACE INTO HostileVillagers_Units 
   (UnitType, PromotionClass, PrereqTech, PrereqCivic, StrategicResource) 
SELECT u.UnitType, u.PromotionClass, u.PrereqTech, u.PrereqCivic, u.StrategicResource 
FROM Units u 
WHERE NOT PromotionClass IS NULL 
	AND NOT PromotionClass LIKE '%AIR%' 
	AND u.Combat > 0 
	AND (TraitType IS NULL OR TraitType = 'TRAIT_BARBARIAN_BUT_SHOWS_UP_IN_PEDIA') 
ORDER BY (SELECT RowId FROM Technologies t WHERE u.PrereqTech = t.TechnologyType) DESC;

/* ===========================================================================
    End ingame setup
=========================================================================== */
