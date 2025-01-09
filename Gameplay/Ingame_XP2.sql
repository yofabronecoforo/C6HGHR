/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin ingame setup for Gathering Storm
=========================================================================== */

-- 
REPLACE INTO HostileVillagerUnits 
    (EraType, PromotionClass, UnitType) 
VALUES 
    -- ('ERA_FUTURE', 'PROMOTION_CLASS_RECON', 'UNIT_SPEC_OPS'), 
    ('ERA_FUTURE', 'PROMOTION_CLASS_MELEE', 'UNIT_MECHANIZED_INFANTRY'), 
    ('ERA_FUTURE', 'PROMOTION_CLASS_RANGED', 'UNIT_MACHINE_GUN'), 
    ('ERA_FUTURE', 'PROMOTION_CLASS_ANTI_CAVALRY', 'UNIT_MODERN_AT'), 
    ('ERA_FUTURE', 'PROMOTION_CLASS_HEAVY_CAVALRY', 'UNIT_MODERN_ARMOR'), 
    ('ERA_FUTURE', 'PROMOTION_CLASS_LIGHT_CAVALRY', 'UNIT_HELICOPTER');

-- replace UNIT_SCOUT in Eras 2-3
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_SKIRMISHER' 
WHERE PromotionClass = 'PROMOTION_CLASS_RECON' 
AND (EraType = 'ERA_MEDIEVAL' 
  OR EraType = 'ERA_RENAISSANCE');

-- replace UNIT_HORSEMAN in Eras 2-3
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_COURSER' 
WHERE PromotionClass = 'PROMOTION_CLASS_LIGHT_CAVALRY' 
AND (EraType = 'ERA_MEDIEVAL' 
  OR EraType = 'ERA_RENAISSANCE');

-- replace UNIT_KNIGHT in Era 4
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_CUIRASSIER' 
WHERE PromotionClass = 'PROMOTION_CLASS_HEAVY_CAVALRY' 
AND EraType = 'ERA_INDUSTRIAL';

/* ===========================================================================
    End ingame setup
=========================================================================== */
