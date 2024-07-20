if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
  return {
    name      = "Cluster Weapons",
    desc      = "Projectiles can spawn other projectiles",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

local clusterProjectiles = {}
local clusterLasers = {}

local function getWeaponIdIdx(unitID, weaponDefID)
  local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
  for i,weapon in ipairs(unitDef.weapons) do
    if weapon.weaponDef == weaponDefID then
      return i
    end
  end
end

local function getCount(tbl)
  local n = 0
  for _,_ in pairs(tbl) do
    n = n + 1
  end

  return n
end

local function filterLaserTargets(attackerID, unitID, weaponDefID, tbl)
  local weaponIdx = getWeaponIdIdx(attackerID, weaponDefID)
  if tbl[attackerID] and tbl[attackerID][weaponIdx] then
    local cl = tbl[attackerID][weaponIdx]
    if cl[unitID] or getCount(cl) >= 3 then
      return true
    end
  end

  return false
end

-- spawnInfo params:
-- x,y,z = projectile spawn position
-- damageMult = damage multiplier for cluster
-- velocity = projectile velocity (direction for beamlasers)
-- owner = projectile owner (optional if not beamlaser)
-- weaponDefID = ... (optional if not beamlaser)
-- targetUnit or tx, ty, tz = target unit or target position (one or other is required)
local function spawnClusterProjectile(spawnInfo)
  local fromProjectile = spawnInfo.from
  local weaponDefID = spawnInfo.weaponDefID or Spring.GetProjectileDefID(fromProjectile)
  if fromProjectile and clusterProjectiles[fromProjectile] then return false end
  if (not fromProjectile) then
    local filt = filterLaserTargets(spawnInfo.owner, spawnInfo.targetUnit, weaponDefID, clusterLasers)
    if filt then
      return false
    end
  end

  local spawnPosX = spawnInfo.x
  local spawnPosY = spawnInfo.y
  local spawnPosZ = spawnInfo.z
  local damageMult = spawnInfo.damageMult

  local owner = spawnInfo.owner or Spring.GetProjectileOwnerID(fromProjectile)
  local wd = WeaponDefs[weaponDefID]
  local targetUnit = spawnInfo.targetUnit
  local targetPosX,targetPosY,targetPosZ
  if not targetUnit then
    targetPosX = spawnInfo.tx
    targetPosY = spawnInfo.ty
    targetPosZ = spawnInfo.tz
  end

  local isBeamlaser = wd.type == [[BeamLaser]] or wd.type == [[LightningCannon]]
  local vx = spawnInfo.velocityX
  local vy = spawnInfo.velocityY
  local vz = spawnInfo.velocityZ

  if isBeamlaser then
    local weaponIdx = getWeaponIdIdx(owner, weaponDefID)
    local dirX = vx / math.sqrt(vx * vx + vy * vy + vz * vz)
    local dirY = vy / math.sqrt(vx * vx + vy * vy + vz * vz)
    local dirZ = vz / math.sqrt(vx * vx + vy * vy + vz * vz)
    local estX,estY,estZ

    if targetUnit then
      targetPosX,targetPosY,targetPosZ = Spring.GetUnitPosition(targetUnit)
    end

    local t = {
      clusterDepth = 1,
      damageMult = damageMult
    }

    clusterLasers[owner] = clusterLasers[owner] or {}
    clusterLasers[owner][weaponIdx] = clusterLasers[owner][weaponIdx] or {}
    clusterLasers[owner][weaponIdx][targetUnit] = t

    Spring.SpawnSFX(spawnInfo.owner, 2047 + weaponIdx, spawnPosX, spawnPosY, spawnPosZ, dirX, dirY, dirZ, true)
    return nil
  elseif fromProjectile and fromProjectile > 0 then
    local projectileID = Spring.SpawnProjectile(weaponDefID, {
      pos = {spawnPosX, spawnPosY, spawnPosZ},
      speed = {vx, vy, vz},
      owner = owner,
      team = Spring.GetUnitTeam(owner),
      gravity = spawnInfo.gravity,
      tracking = wd.tracks,
      maxRange = wd.flightTime and wd.weaponVelocity and (wd.flightTime * wd.weaponVelocity)
    })

    clusterProjectiles[projectileID] = {
      clusterDepth = 1,
      damageMult = damageMult,
    }

    if targetUnit ~= nil then
      Spring.SetProjectileTarget(projectileID, targetUnit, string.byte('u'))
    else
      Spring.SetProjectileTarget(projectileID, targetPosX, targetPosY, targetPosZ)
    end

    return projectileID
  end
end

local function prepareUnitClusterWeapons(unitID)
  local unitDef = UnitDefs[Spring.GetUnitDefID(unitID)]
  for _,wd in ipairs(unitDef.weapons) do
    local wdID = wd.weaponDef
    
    if not (WeaponDefs[wdID].type == [[BeamLaser]] or WeaponDefs[wdID].type == [[LightningCannon]]) then
      Script.SetWatchWeapon(wdID, true)
    end
  end
end

GG.ClusterProjectiles = clusterProjectiles
GG.SpawnClusterProjectile = spawnClusterProjectile
GG.PrepareUnitClusterWeapons = prepareUnitClusterWeapons

function gadget:ProjectileCreated(projectileID, projOwnerID, weaponDefID)
  clusterProjectiles[projectileID] = nil
end

local function tblLength(tbl)
  local n = 0
  for k,v in pairs(tbl) do
    n = n + 1
  end

  return n
end

function gadget:GameFrame(frame)
  clusterLasers = {}
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam, projectileID)
  if clusterProjectiles[projectileID] then
    local dm = clusterProjectiles[projectileID].damageMult or 0.33
    local c = clusterProjectiles[projectileID].clusterDepth or 1
    return damage * math.pow(dm, c)
  end

  if Spring.ValidUnitID(attackerID) then
    local weaponIdx = getWeaponIdIdx(attackerID, weaponID)
    if clusterLasers[attackerID] and clusterLasers[attackerID][weaponIdx] and clusterLasers[attackerID][weaponIdx][unitID] then
      local cl = clusterLasers[attackerID][weaponIdx][unitID]
      local dm = cl.damageMult or 0.33
      local c = cl.clusterDepth or 1
      return damage * math.pow(dm, c)
    end
  end

  return damage
end