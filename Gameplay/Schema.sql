/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin ingame schema setup
=========================================================================== */

-- hostile subtype parameters
CREATE TABLE IF NOT EXISTS GoodyHutSubTypes_HGHR ( 
    'SubTypeGoodyHut' TEXT NOT NULL UNIQUE, 
    'NumUnits' INTEGER NOT NULL DEFAULT 0,  
    'Adverb' TEXT NOT NULL, 
    PRIMARY KEY (SubTypeGoodyHut)
);

-- type modifiers for hostility check
CREATE TABLE IF NOT EXISTS HostileVillagers_GoodyHuts ( 
	'GoodyHutType' TEXT NOT NULL UNIQUE, 
	'TotalWeight' INTEGER NOT NULL DEFAULT 100, 
	PRIMARY KEY (GoodyHutType) 
);

-- subtype modifiers for hostility check
CREATE TABLE IF NOT EXISTS HostileVillagers_GoodyHutSubTypes ( 
	'SubTypeGoodyHut' TEXT NOT NULL UNIQUE, 
	'Modifier' INTEGER NOT NULL DEFAULT 0, 
	'Threshold' INTEGER NOT NULL DEFAULT 100, 
	PRIMARY KEY (SubTypeGoodyHut) 
);

-- unit pool for hostility check average/maximum combat values
CREATE TABLE IF NOT EXISTS HostileVillagers_Units ( 
    'UnitType' TEXT UNIQUE NOT NULL, 
    'PromotionClass' TEXT NOT NULL, 
    'PrereqTech' TEXT, 
    'PrereqCivic' TEXT, 
    'StrategicResource' TEXT, 
    PRIMARY KEY (UnitType) 
);

/* ===========================================================================
    End ingame schema setup
=========================================================================== */
