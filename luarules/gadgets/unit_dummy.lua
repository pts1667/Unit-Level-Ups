function gadget:GetInfo()
  return {
    name      = "Dummy units",
    desc      = "Attachable dummy units",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true
 }
end

if (gadgetHandler:IsSyncedCode()) then

local dummyUnitTable = {}
local dummyProjTable = {}
local dummyUnitMasters = {}
local dummyProjMasters = {}
local dummyUnits = {}
local dummyProjs = {}
local DestroyDummiesNextFrame = {}

function createDummyUnit(unitOrProjID, defName)
  local unitID = -1
  local x, y, z = 0,0,0
  local team = -1
  if unitOrProjID.unit then
    local forUnitID = unitOrProjID.unit
    x, y, z = Spring.GetUnitPosition(forUnitID)
    team = Spring.GetUnitTeam(forUnitID)
    unitID = Spring.CreateUnit(defName, x, y, z, 0, team)

    dummyUnitTable[forUnitID] = dummyUnitTable[forUnitID] or {}
    dummyUnitTable[forUnitID][unitID] = true
    dummyUnits[unitID] = true
    dummyUnitMasters[unitID] = forUnitID
  elseif unitOrProjID.proj then
    local forProjID = unitOrProjID.proj
    local projOwner = Spring.GetProjectileOwnerID(forProjID)
    x, y, z = Spring.GetProjectilePosition(forProjID)
    team = Spring.GetUnitTeam(projOwner)
    unitID = Spring.CreateUnit(defName, x, y + 40, z, 0, team)

    dummyProjTable[forProjID] = dummyProjTable[forProjID] or {}
    dummyProjTable[forProjID][unitID] = true
    dummyProjs[unitID] = true
    dummyProjMasters[unitID] = forProjID
  elseif unitOrProjID.pos then
    x, y, z, team = unpack(unitOrProjID.pos)
    unitID = Spring.CreateUnit(defName, x, y, z, 0, team)
    dummyUnits[unitID] = true
  end

	Spring.SetUnitRulesParam(unitID,'untargetable',1)
  Spring.SetUnitPosition(unitID, x, y + 40, z)
  return unitID
end

function gadget:Initialize()
  GG.CreateDummyUnit = createDummyUnit
  GG.DummyUnitTable = dummyUnitTable
  GG.DummyUnitMasters = dummyUnitMasters
  GG.DummyUnits = dummyUnits
  GG.DummyProjTable = dummyProjTable
  GG.DummyProjMaster = dummyProjMasters
  GG.DummyProjs = dummyProjs
end

function gadget:UnitDestroyed(unitID)
  if dummyUnitTable[unitID] then
    for dummyID,_ in pairs(dummyUnitTable[unitID]) do
      DestroyDummiesNextFrame[dummyID] = true
    end
  end

  dummyUnits[unitID] = nil
  dummyUnitMasters[unitID] = nil
  dummyUnitTable[unitID] = nil
  dummyProjMasters[unitID] = nil
end

function gadget:ProjectileDestroyed(projectileID)
  if dummyProjTable[projectileID] then
    for dummyID,_ in pairs(dummyProjTable[projectileID]) do
      DestroyDummiesNextFrame[dummyID] = true
    end
  end

  dummyProjs[projectileID] = nil
  dummyProjTable[projectileID] = nil
end

function gadget:UnitPreDamaged(unitID)
  if dummyUnits[unitID] then
    return 0, 0
  end
end

function gadget:GameFrame()
  for dummyID,_ in pairs(DestroyDummiesNextFrame) do
    Spring.DestroyUnit(dummyID)
  end

  for unitID,dummyTable in pairs(dummyUnitTable) do
    if not Spring.GetUnitIsDead(unitID) then
      local x, y, z = Spring.GetUnitPosition(unitID)
      for dummyID,_ in pairs(dummyTable) do
        Spring.SetUnitPosition(dummyID, x, y + 40, z)
      end
    end
  end

  for projID,dummyTable in pairs(dummyProjTable) do
    local x, y, z = Spring.GetProjectilePosition(projID)
    for dummyID,_ in pairs(dummyTable) do
      Spring.SetUnitPosition(dummyID, x, y + 40, z)
    end
  end
end

end