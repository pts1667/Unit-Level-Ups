function gadget:GetInfo()
  return {
    name      = "Unit Class",
    desc      = "Unit class stuff",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local blacklist = VFS.Include("luarules/configs/blacklistdefs.lua")
local perkInfo, perkIDTable = VFS.Include("LuaRules/configs/perkdefs.lua")
local perkFuncs = VFS.Include("LuaRules/configs/perkfuncs/list.lua")

local CMD_PERK_SELECT = 51518
local unitPerks = {}
local unitPerkPoints = {}
local unitTickRegistered = {}

local function onPerkFnNoRet(fnName, cond, ...)
  local lastFns = {}
  for perkName,perkFuncTable in pairs(perkFuncs) do
    if perkFuncTable[fnName] and cond(perkName) then
      if perkInfo[perkName].activateLast then
        lastFns[#lastFns+1] = perkFuncTable[fnName]
      else
        perkFuncTable[fnName](...)
      end
    end
  end

  for i,fn in ipairs(lastFns) do
    fn(...)
  end
end

local function onPerkFnMulRet(fnName, cond, ...)
  local res = 1.0
  local lastFns = {}
  for perkName,perkFuncTable in pairs(perkFuncs) do
    if perkFuncTable[fnName] and cond(perkName) then
      if perkInfo[perkName].activateLast then
        lastFns[#lastFns+1] = perkFuncTable[fnName]
      else
        res = res * perkFuncTable[fnName](...)
      end
    end
  end

  for i,fn in ipairs(lastFns) do
    res = res * fn(...)
  end

  return res
end

local function onProjectileDeath(projectileID)
  return onPerkFnNoRet("onProjectileDeath", function (perkName)
    return true
  end, projectileID)
end

local function onStatChange(unitID)
  return onPerkFnNoRet("onStatChange", function (perkName)
    return unitPerks[unitID] and unitPerks[unitID][perkName]
  end, unitID)
end

local function onDamage(unitID, ...)
  local attackerID = select(7, ...)
  return onPerkFnNoRet("onDamage", function (perkName)
    return (unitPerks[attackerID][perkName] and true) or false
  end, unitID, ...)
end

local function onExplosion(weaponDefID, px, py, pz, attackerID, projectileID)
  return onPerkFnNoRet("onExplosion", function (perkName)
    return (unitPerks[attackerID] and unitPerks[attackerID][perkName] and true) or false
  end, weaponDefID, px, py, pz, attackerID, projectileID)
end

local function onTick(unitID, ...)
  if (not unitPerks[unitID]) or (not unitTickRegistered[unitID]) then
    return
  end

  return onPerkFnNoRet("onTick", function (perkName)
    return (unitPerks[unitID][perkName] and unitTickRegistered[unitID][perkName] and true) or false
  end, unitID, ...)
end

local function onDamaged(unitID, ...)
  local attackerID = select(7, ...)
  return onPerkFnNoRet("onDamaged", function (perkName)
    return (unitPerks[unitID][perkName] and true) or false
  end, unitID, ...)
end

local function onInvolvedDamage(unitID, ...)
  local attackerID = select(7, ...)
  if unitPerks[attackerID] then
    onDamage(unitID, ...)
  end

  if unitPerks[unitID] then
    onDamaged(unitID, ...)
  end
end

local function onPreDamage(unitID, ...)
  local attackerID = select(6, ...)
  if not unitPerks[attackerID] then
    return
  end

  local cond = function (perkName)
    return (unitPerks[attackerID][perkName] and true) or false
  end

  return onPerkFnMulRet("onPreDamage", cond, unitID, ...)
end

local function onPreDamaged(unitID, ...)
  local attackerID = select(6, ...)
  if not unitPerks[unitID] then
    return
  end

  local cond = function (perkName)
    return (unitPerks[unitID][perkName] and true) or false
  end
  return onPerkFnMulRet("onPreDamaged", cond, unitID, ...)
end

local function onInvolvedPreDamage(unitID, ...)
  local r1 = onPreDamage(unitID, ...)
  local r2 = onPreDamaged(unitID, ...)

  return r1 or r2 or 1.0
end

local function onDeath(unitID, ...)
  if not unitPerks[unitID] then
    return
  end

  local cond = function (perkName)
    return (unitPerks[unitID][perkName] and true) or false
  end

  return onPerkFnNoRet("onDeath", cond, unitID, ...)
end

local function onProjectileCreated(projectileID, projOwnerID, weaponDefID)
  if not unitPerks[projOwnerID] then
    return
  end

  if not weaponDefID then
    weaponDefID = Spring.GetProjectileDefID(projectileID)
  end

  local cond = function (perkName)
    return (unitPerks[projOwnerID][perkName] and true) or false
  end

  return onPerkFnNoRet("onProjectileCreated", cond, projectileID, projOwnerID, weaponDefID)
end

local function onProjectileDeath(projectileID)
  local ownerID = Spring.GetProjectileOwnerID(projectileID)

  if not unitPerks[ownerID] then
    return
  end

  local cond = function (perkName)
    return (unitPerks[ownerID][perkName] and true) or false
  end

  return onPerkFnNoRet("onProjectileDeath", cond, projectileID)
end

local function onUnitExperience(unitID, ...)
  if not unitPerks[unitID] then
    return
  end

  local cond = function (perkName)
    return (unitPerks[unitID][perkName] and true) or false
  end

  return onPerkFnNoRet("onUnitExperience", cond, unitID, ...)
end

local function checkPrereqs(unitID, prereqs)
  for i,perkReq in ipairs(prereqs) do
    if not unitPerks[unitID][perkReq] then
      return false
    end
  end

  return true
end

local function updateUnitRules(unitID, perkName)
  local perkExistsNum = (unitPerks[unitID][perkName] and 1) or 0
  Spring.SetUnitRulesParam(unitID, "perk_"..perkName, perkExistsNum, {allied=true})
end

local function updatePerkPoints(unitID)
  Spring.SetUnitRulesParam(unitID, "perk_points", unitPerkPoints[unitID], {allied=true})
end

local function addDronePerk(droneID, perkName)
  if perkInfo[perkName].affectsDrones then
    unitPerks[droneID] = unitPerks[droneID] or {}
    unitPerks[droneID][perkName] = true
    if perkFuncs[perkName] and perkFuncs[perkName].onPick then
      perkFuncs[perkName].onPick(droneID)
    end
  end
end

local function addDronePerks(masterID, droneID)
  if not Spring.ValidUnitID(droneID) or Spring.GetUnitIsDead(droneID) then
    return
  end

  if not unitPerks[masterID] then
    return
  end

  for perkName,perk in pairs(perkInfo) do
    if unitPerks[masterID][perkName] then
      addDronePerk(droneID, perkName)
    end
  end
end

GG.AddDronePerks = addDronePerks

local function addPerk(unitID, perkName)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    return
  end

  local perk = perkInfo[perkName]
  if (perk.prerequisites and (not checkPrereqs(unitID, perk.prerequisites))) or (unitPerks[unitID][perkName]) then
    return
  end

  local unitDefID = Spring.GetUnitDefID(unitID)
  local unitDef = UnitDefs[unitDefID]

  if unitPerkPoints[unitID] and unitPerkPoints[unitID] > 0 then
    unitPerks[unitID][perkName] = true
    unitPerkPoints[unitID] = unitPerkPoints[unitID] - 1
    updateUnitRules(unitID, perkName)
    updatePerkPoints(unitID)

    if perkFuncs[perkName] and perkFuncs[perkName].onPick then
      perkFuncs[perkName].onPick(unitID)
    end

    if GG.MiniMeMasterTables[unitID] then
      for droneID,_ in pairs(GG.MiniMeMasterTables[unitID]) do
        addDronePerk(droneID, perkName)
      end
    end
  end
end

local function setPerkPoints(unitID, numPerks)
  if not unitPerks[unitID] then
    unitPerks[unitID] = {}
    GG.PASAddUnit(unitID)
  end
  
  local numSpentPerks = 0
  for _,_ in pairs(unitPerks[unitID]) do
    numSpentPerks = numSpentPerks + 1
  end

  if numPerks >= #unitPerks[unitID] then
    unitPerkPoints[unitID] = numPerks - numSpentPerks
    updatePerkPoints(unitID)
  end
end

local function getPerkPoints(unitID)
  return unitPerkPoints[unitID] or 0
end

local function currentPerks(unitID)
  local availablePerks = {}
  local perkPoints = unitPerkPoints[unitID]
  unitPerks[unitID] = unitPerks[unitID] or {} -- bad but oh well
  local perks = unitPerks[unitID]
  for perkName,perk in pairs(perkInfo) do
    if ((not perk.prerequisites) or checkPrereqs(unitID, perk.prerequisites)) and (not perks[perkName]) then
      availablePerks[#availablePerks+1] = perkName
    end
  end

  return {
    perks = perks,
    availablePerks = availablePerks,
    perkPoints = perkPoints
  }
end

local function hasPerk(unitID, perkName)
  return (unitPerks[unitID] and unitPerks[unitID][perkName]) or false
end

local function perkRegisterOnTick(unitID, perkName)
  unitTickRegistered[unitID] = unitTickRegistered[unitID] or {}
  unitTickRegistered[unitID][perkName] = true
end

local function perkDelistOnTick(unitID, perkName)
  if unitTickRegistered[unitID] then
    unitTickRegistered[unitID][perkName] = nil
  end
end

function gadget:Initialize()
  GG.SetPerkPoints = setPerkPoints
  GG.GetPerkPoints = getPerkPoints
  GG.CurrentPerks = currentPerks
  GG.HasPerk = hasPerk
  GG.AddPerk = addPerk
  GG.PerkOnStatChange = onStatChange
  GG.PerkRegisterOnTick = perkRegisterOnTick
  GG.PerkDelistOnTick = perkDelistOnTick
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  onDeath(unitID, unitDefID, unitTeam)
  
  unitPerks[unitID] = nil
  unitPerkPoints[unitID] = nil
  unitTickRegistered[unitID] = nil
end

function gadget:ProjectileDestroyed(projectileID)
  onProjectileDeath(projectileID)
end

function gadget:ProjectileCreated(projectileID, projOwnerID, weaponDefID)
  onProjectileCreated(projectileID, projOwnerID, weaponDefID)
end

function gadget:UnitDamagedFIXED(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
  return onInvolvedDamage(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, projectileID, attackerID, attackerDefID, attackerTeam)
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  return damage * onInvolvedPreDamage(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
end

function gadget:UnitExperience(unitID, unitDefID, unitTeam, experience, oldExperience)
  onUnitExperience(unitID, unitDefID, unitTeam, experience, oldExperience)
end

function gadget:Explosion(weaponID, px, py, pz, attackerID, projectileID)
  onExplosion(weaponID, px, py, pz, attackerID, projectileID)
end

function gadget:GameFrame()
  for unitID,_ in pairs(unitPerks) do
    onTick(unitID)
  end

  for _,perkFuncTable in pairs(perkFuncs) do
    local _ = perkFuncTable["globalTick"] and perkFuncTable["globalTick"]()
  end
end

function gadget:UnitCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag)
  if Spring.GetUnitIsDead(unitID) then
    return
  end

  if cmdID == 1 then
    cmdID = cmdParams[2]
    cmdParams = {cmdParams[4]}
  end

  if cmdID == CMD_PERK_SELECT then
    local perkName = perkIDTable[cmdParams[1]]
    addPerk(unitID, perkName)
  end
end