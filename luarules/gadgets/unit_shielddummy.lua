function gadget:GetInfo()
  return {
    name      = "Shield dummy units",
    desc      = "Shields for dummy units",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true
 }
end

if (gadgetHandler:IsSyncedCode()) then
  local shieldDummies = {}

  function createShieldDummy(unitOrProjID, shieldType, dontRegen)
    local unitID = GG.CreateDummyUnit(unitOrProjID, "shielddummy" .. shieldType)
    Spring.SetUnitRulesParam(unitID, "shieldChargeDisabled", 1) -- we handle this ourselves
    Spring.SetUnitShieldState(unitID, 1, true, 1000)

    if not dontRegen then
      shieldDummies[unitID] = true
    end

    return unitID
  end

  function gadget:Initialize()
    GG.CreateShieldDummy = createShieldDummy
  end

  function gadget:GameFrame(frame)
    if frame % 30 > 0.1 then
      return
    end

    for dummyID,_ in pairs(shieldDummies) do
      local shieldEnabled,shieldChargeOld = Spring.GetUnitShieldState(dummyID)
      if shieldEnabled and GG.DummyUnitMasters[dummyID] then
        local _,maxHP = Spring.GetUnitHealth(GG.DummyUnitMasters[dummyID])
        local shieldChargeGain = maxHP * 0.002
        Spring.SetUnitShieldState(dummyID, 1, true, math.min(maxHP * 0.2, shieldChargeOld + shieldChargeGain))
      end
    end
  end

  function gadget:UnitDestroyed(unitID)
    shieldDummies[unitID] = nil
  end
end