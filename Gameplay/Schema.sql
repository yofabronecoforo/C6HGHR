/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin ingame schema setup
=========================================================================== */

-- additional hostile "reward" data
CREATE TABLE IF NOT EXISTS GoodyHutSubTypes_HGHR (
    'SubTypeGoodyHut' TEXT NOT NULL UNIQUE, 
    'PromotionClass' TEXT NOT NULL, 
    'NumUnits' INTEGER NOT NULL DEFAULT 1, 
    'Outpost' BOOLEAN NOT NULL CHECK (Outpost IN (0,1)) DEFAULT 0, 
    PRIMARY KEY('SubTypeGoodyHut')
);

-- hostile unit data
CREATE TABLE IF NOT EXISTS HostileVillagerUnits (
    'EraType' TEXT, 
    'PromotionClass' TEXT, 
    'UnitType' TEXT, 
    PRIMARY KEY('EraType', 'PromotionClass')
);

/* ===========================================================================
    End ingame schema setup
=========================================================================== */
