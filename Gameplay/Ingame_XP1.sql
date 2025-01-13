/* ===========================================================================
    Hostile Goody Hut Rewards (HGHR) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin ingame setup for Rise and Fall
=========================================================================== */

-- replace UNIT_RANGER in Eras 6-7
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_SPEC_OPS' 
WHERE PromotionClass = 'PROMOTION_CLASS_RECON' 
AND (EraType = 'ERA_ATOMIC' 
  OR EraType = 'ERA_INFORMATION');

-- replace UNIT_PIKEMAN in Eras 3-4
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_PIKE_AND_SHOT' 
WHERE PromotionClass = 'PROMOTION_CLASS_ANTI_CAVALRY' 
AND (EraType = 'ERA_RENAISSANCE' 
  OR EraType = 'ERA_INDUSTRIAL');

-- replace UNIT_MEDIC in Eras 5-7
UPDATE HostileVillagerUnits 
SET UnitType = 'UNIT_SUPPLY_CONVOY' 
WHERE PromotionClass = 'PROMOTION_CLASS_SUPPORT' 
AND (EraType = 'ERA_MODERN' 
  OR EraType = 'ERA_ATOMIC' 
  OR EraType = 'ERA_INFORMATION');

/* ===========================================================================
    End ingame setup
=========================================================================== */
