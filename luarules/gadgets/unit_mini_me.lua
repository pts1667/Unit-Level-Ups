if not gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GetInfo()
  return {
    name      = "Mini Me",
    desc      = "Give units little versions of themselves as drones",
    author    = "Presstabstart, TheFatConroller, KingRaptor",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

include("LuaRules/Configs/customcmds.h.lua")

local AddUnitDamage       = Spring.AddUnitDamage
local CreateUnit          = Spring.CreateUnit
local DestroyUnit         = Spring.DestroyUnit
local GetCommandQueue     = Spring.GetCommandQueue
local spGetUnitDirection  = Spring.GetUnitDirection
local GetUnitIsStunned    = Spring.GetUnitIsStunned
local GetUnitPieceMap     = Spring.GetUnitPieceMap
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetUnitPosition   = Spring.GetUnitPosition
local GiveOrderToUnit     = Spring.GiveOrderToUnit
local SetUnitPosition     = Spring.SetUnitPosition
local SetUnitNoSelect     = Spring.SetUnitNoSelect
local spGetUnitHealth     = Spring.GetUnitHealth
local spSetUnitHealth     = Spring.SetUnitHealth
local TransferUnit        = Spring.TransferUnit
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetGameFrame      = Spring.GetGameFrame
local spGetUnitVelocity   = Spring.GetUnitVelocity
local spGetUnitSeparation = Spring.GetUnitSeparation
local spGetUnitsInCylinder = Spring.GetUnitsInCylinder
local random              = math.random
local CMD_ATTACK          = CMD.ATTACK

local GiveClampedOrderToUnit = Spring.Utilities.GiveClampedOrderToUnit
local miniMeList = {}
local miniMeRespawnList = {}
local miniMeMasters = {}
local miniMeMasterTables = {}
local miniMeCreateOrders = {} -- NewMiniMe could be called in CreateUnit, so we defer to next frame

local function RandomPointInCircle(radius)
  local angle = random() * 2 * math.pi
  local distance = random()
  return math.cos(angle)*distance*radius, math.sin(angle)*distance*radius
end

local function RandomPointInCircleSegment(radiusMin, radiusMax)
  local angle = random() * 2 * math.pi
  local distance = random()
  local rDiff = radiusMax - radiusMin
  local dist = radiusMin + distance*rDiff
  return math.cos(angle)*dist, math.sin(angle)*dist
end

local function updateMiniMeOrders(unitID)
  local firestate = Spring.Utilities.GetUnitFireState(unitID)
  local num_cmds = Spring.GetUnitCommands(unitID, 0)

  Spring.GiveOrderToUnitMap(miniMeMasterTables[unitID], CMD.MOVE_STATE, { 2 }, 0)
  Spring.GiveOrderToUnitMap(miniMeMasterTables[unitID], CMD.FIRE_STATE, { firestate }, 0)
  Spring.GiveOrderToUnitMap(miniMeMasterTables[unitID], CMD.IDLEMODE, { 0 }, 0)

  if num_cmds > 0 then
    local unit_cmd = Spring.GetUnitCommands(unitID, 1)[1]
    Spring.GiveOrderToUnitMap(miniMeMasterTables[unitID], unit_cmd.id, unit_cmd.params, unit_cmd.options)
  else
    local exp = Spring.GetUnitExperience(unitID)
    local dist = 200.0 + math.floor(exp) * 10.0
    local x, y, z = spGetUnitPosition(unitID, true)

    for miniMeID,_ in pairs(miniMeMasterTables[unitID]) do
      local rx, rz = RandomPointInCircle(dist)
      GiveClampedOrderToUnit(miniMeID, CMD.MOVE, {x + rx, y, z + rz}, 0, false, true)
    end

    Spring.GiveOrderToUnitMap(miniMeMasterTables[unitID], CMD.GUARD, {unitID}, CMD.OPT_SHIFT)
  end
end

local function NewMiniMe(unitID, unitName, teamID)
  if (not Spring.ValidUnitID(unitID)) or Spring.GetUnitIsDead(unitID) then
    return
  end

  local exp = Spring.GetUnitExperience(unitID)
  local dist = 200.0 + math.floor(exp) * 10.0
  local x, y, z = spGetUnitPosition(unitID, true)
  local spawnCircleX, spawnCricleZ = RandomPointInCircleSegment(100.0, dist);
  local spawnX = spawnCircleX + x
  local spawnZ = spawnCricleZ + z
  local spawnY = Spring.GetGroundHeight(spawnX, spawnZ)
  local miniMeID = GG.DropUnit(unitName, spawnX, spawnY, spawnZ, 1, teamID, true)

  if miniMeID then
    -- this doesn't really do much since xp don't account for drones anymore
    Spring.SetUnitRulesParam(miniMeID, "parent_unit_id", unitID)
    Spring.SetUnitRulesParam(miniMeID, "noWreck", 1)
    SetUnitNoSelect(miniMeID, true)

    miniMeList[miniMeID] = unitID
    miniMeMasters[unitID] = 200.0 + math.floor(exp) * 10.0 -- guard radius for mini mes
    miniMeMasterTables[unitID] = miniMeMasterTables[unitID] or {}
    miniMeMasterTables[unitID][miniMeID] = true

    GG.AddDronePerks(unitID, miniMeID)
  end
end

local function QueueMiniMe(unitID, unitName, teamID, count)
  miniMeCreateOrders[unitID] = {
    unitName = unitName,
    teamID = teamID,
    count = count
  }
end

local function MiniMeRandomMove(miniMe, master)
  local radius = miniMeMasters[master]
  local rx, rz = RandomPointInCircle(radius)
  local _, _, _, x, y, z = spGetUnitPosition(master, true)
  GiveClampedOrderToUnit(miniMe, CMD.MOVE, {x + rx, y, z + rz}, 0, false, true)
end

local function SetMiniMeGuardRadius(masterID, radius)
  miniMeMasters[masterID] = radius
end

GG.NewMiniMe = NewMiniMe
GG.QueueMiniMe = QueueMiniMe
GG.SetMiniMeGuardRadius = SetMiniMeGuardRadius
GG.MiniMeList = miniMeList
GG.MiniMeMasters = miniMeMasters
GG.MiniMeMasterTables = miniMeMasterTables

function gadget:GameFrame(n)
  for master,respawnInfo in pairs(miniMeRespawnList) do
    miniMeRespawnList[master].time = respawnInfo.time - 1
    if (respawnInfo.time - 1) < 0.1 then
      if respawnInfo.count == 1 then
        miniMeRespawnList[master] = nil
      else
        miniMeRespawnList[master].count = respawnInfo.count - 1
      end

      if miniMeMasters[master] then
        NewMiniMe(master, respawnInfo.unitName, respawnInfo.teamID)
      end
    end
  end

  for master,createOrder in pairs(miniMeCreateOrders) do
    for i=1,createOrder.count do
      NewMiniMe(master, createOrder.unitName, createOrder.teamID)
    end
    miniMeCreateOrders[master] = nil
  end

  if ((n % 10) > 0.1) then
    return
  end

  for unitID,_ in pairs(miniMeMasterTables) do
    updateMiniMeOrders(unitID)
  end

  for miniMe,master in pairs(miniMeList) do
    if (not miniMeMasters[master]) then
      DestroyUnit(miniMe)
    end
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  if miniMeList[unitID] then
    local master = miniMeList[unitID]
    if ((not miniMeRespawnList[master]) and miniMeMasters[master]) then
      miniMeRespawnList[master] = {
        time = 600, -- 20 seconds
        unitName = UnitDefs[unitDefID].name,
        teamID = unitTeam,
        count = 1
      }
    elseif miniMeRespawnList[master] then
      miniMeRespawnList[master].count = miniMeRespawnList[master].count + 1
    end
  end

  if miniMeList[unitID] and miniMeMasterTables[miniMeList[unitID]] then
    miniMeMasterTables[miniMeList[unitID]][unitID] = nil
  end

  miniMeList[unitID] = nil
  miniMeMasters[unitID] = nil
  miniMeCreateOrders[unitID] = nil
  miniMeRespawnList[unitID] = nil
  miniMeMasterTables[unitID] = nil
end

function gadget:UnitExperience(unitID, unitDefID, unitTeam, experience, oldExperience)
  if not miniMeMasterTables[unitID] then
    return
  end

  miniMeMasters[unitID] = 200.0 + math.floor(experience) * 10.0
end

function gadget:StockpileChanged(unitID, unitDefID, unitTeam, weaponNum, oldCount, newCount)
  if oldCount > newCount then
    return
  end

  if miniMeMasters[unitID] then
    for miniMeID,_ in pairs(miniMeMasterTables[unitID]) do
      Spring.SetUnitStockpile(miniMeID, Spring.GetUnitStockpile(miniMeID) + (newCount - oldCount), 0)
    end
  end
end