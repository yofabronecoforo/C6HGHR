/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin frontend schema setup
=========================================================================== */

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

/* ===========================================================================
    End frontend schema setup
=========================================================================== */
