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

-- hostile subtypes
REPLACE INTO GoodyHutSubTypes 
	(GoodyHut, SubTypeGoodyHut, Description, Weight, Turn, ModifierID, RequiresUnit) 
VALUES 
    ('GOODYHUT_HOSTILES', 'GOODYHUT_HOSTILE_VILLAGERS', 'LOC_GOODYHUT_HOSTILES_DESCRIPTION', 60, 0, 'GOODY_HGHR_DUMMY_REWARD', 1);

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

/* ===========================================================================
    End ingame setup
=========================================================================== */
