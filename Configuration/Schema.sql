/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin frontend schema setup
=========================================================================== */

-- type picker items
-- CREATE TABLE IF NOT EXISTS 'TribalVillageTypes' (
--     'Domain' TEXT NOT NULL DEFAULT 'StandardGoodyHutTypes',
--     'GoodyHut' TEXT NOT NULL,
--     'Name' TEXT NOT NULL,
--     'Description' TEXT NOT NULL,
--     'ChangesXP1' TEXT DEFAULT NULL,
--     'ChangesXP2' TEXT DEFAULT NULL,
--     'Notice' TEXT DEFAULT NULL,
--     'NumRewards' INTEGER NOT NULL DEFAULT 0,
--     'Icon' TEXT NOT NULL,
--     'Weight' INTEGER NOT NULL DEFAULT 100,
--     'DefaultWeight' INTEGER NOT NULL DEFAULT 100,
--     PRIMARY KEY ('Domain', 'GoodyHut')
-- );

-- reward picker items
CREATE TABLE IF NOT EXISTS 'HostileVillagers' ( 
    'Domain' TEXT NOT NULL DEFAULT 'StandardHostileVillagers', 
    'GoodyHut' TEXT NOT NULL, 
    'SubTypeGoodyHut' TEXT NOT NULL, 
    'Name' TEXT NOT NULL, 
    'Description' TEXT NOT NULL,
    'Turn' INTEGER NOT NULL DEFAULT 0,
    'MinOneCity' BOOLEAN,
    'RequiresUnit' BOOLEAN,
    'Notice' TEXT DEFAULT NULL, 
    'Icon' TEXT NOT NULL, 
    'IconFG' TEXT DEFAULT NULL,
    'Weight' INTEGER NOT NULL DEFAULT 55, 
    'DefaultWeight' INTEGER NOT NULL DEFAULT 55, 
    PRIMARY KEY ('Domain', 'SubTypeGoodyHut')
);

-- localized text and GameConfiguration value lookup for type picker
-- CREATE TABLE IF NOT EXISTS 'EGHS_TypeWeights' ( 
--     'Tier' INTEGER NOT NULL, 
--     'Name' TEXT NOT NULL, 
--     'Description' TEXT NOT NULL, 
--     'Weight' INTEGER NOT NULL, 
--     PRIMARY KEY ('Tier')
-- );

-- localized text and GameConfiguration value lookup for reward picker
-- CREATE TABLE IF NOT EXISTS 'EGHS_RewardWeights' ( 
--     'Tier' INTEGER NOT NULL, 
--     'Name' TEXT NOT NULL, 
--     'Description' TEXT NOT NULL, 
--     'Weight' INTEGER NOT NULL, 
--     PRIMARY KEY ('Tier')
-- );

-- localized text lookup for picker sort-by pulldowns
-- CREATE TABLE IF NOT EXISTS 'EGHS_SortPulldownTags' (
--     'Name' TEXT NOT NULL, 
--     'Description' TEXT NOT NULL, 
--     PRIMARY KEY ('Name')
-- );

/* ===========================================================================
    End frontend schema setup
=========================================================================== */
