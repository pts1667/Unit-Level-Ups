VFS.Include("LuaRules/Configs/constants.lua")

Spring.Utilities = Spring.Utilities or {}
VFS.Include("LuaRules/Utilities/base64.lua")
local levelWeaponList = VFS.Include("LuaRules/Configs/levelweapondefs.lua").list
local blacklist = VFS.Include("LuaRules/Configs/blacklistdefs.lua")
local autoxpDefs = VFS.Include("LuaRules/Configs/autoxp.lua")
local growthSettings = VFS.Include("LuaRules/Configs/levelupsettings.lua")

function gadget:GetInfo()
  return {
    name      = "Unit Growth",
    desc      = "Units grow with XP",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

include("LuaRules/Configs/customcmds.h.lua")

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local CMD_FIGHT = CMD.FIGHT

local spGetUnitHealth		= Spring.GetUnitHealth
local spSetUnitHealth = Spring.SetUnitHealth
local spSetUnitMaxHealth = Spring.SetUnitMaxHealth
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetUnitPosition = Spring.GetUnitPosition
local spSetUnitPosition = Spring.SetUnitPosition
local spGetUnitTeam = Spring.GetUnitTeam
local spGetAllUnits = Spring.GetAllUnits
local spGetCommandQueue = Spring.GetCommandQueue
local spGiveOrderToUnit = Spring.GiveOrderToUnit
local spGiveOrderArrayToUnitArray = Spring.GiveOrderArrayToUnitArray
local spValidUnitID = Spring.ValidUnitID
local spGetUnitHeading = Spring.GetUnitHeading
local spSetUnitBlocking = Spring.SetUnitBlocking
local spCreateUnit = Spring.CreateUnit
local spGetUnitStates = Spring.GetUnitStates
local suGetUnitCost = Spring.Utilities.GetUnitCost
local spGetUnitVelocity = Spring.GetUnitVelocity
local spDestroyUnit = Spring.DestroyUnit
local spGetGroundHeight = Spring.GetGroundHeight
local spGetUnitShieldState = Spring.GetUnitShieldState
local spSetUnitShieldState = Spring.SetUnitShieldState
local spAddUnitImpulse = Spring.AddUnitImpulse
local spGetUnitsInRectangle = Spring.GetUnitsInRectangle
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spSetUnitRotation = Spring.SetUnitRotation
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitExperience = Spring.GetUnitExperience
local spSetUnitExperience = Spring.SetUnitExperience
local spSetUnitCosts = Spring.SetUnitCosts
local spGetUnitDefID = Spring.GetUnitDefID
local getCost = Spring.Utilities.GetUnitCost
local spEcho = Spring.Echo

GG.unitWeapons = {}
local function GetLevelWeapon(unitID, UnitDef)
  if GG.unitWeapons[unitID] then
    return
  end

  if UnitDef.customParams.dynamic_comm or UnitDef.customParams.disable_level_weapon  then
    return
  end

  local candidateWeapons = levelWeaponList[UnitDef.customParams.level_weapon_cat]
  if candidateWeapons then
	local randInd = math.random(1, #candidateWeapons)
	local slot = UnitDef.customParams.num_normal_weapons + randInd
	GG.unitWeapons[unitID] = slot
  end
end

local unitTargetCommand = {
	[CMD.GUARD] = true,
	[CMD_ORBIT] = true,
}

local singleParamUnitTargetCommand = {
	[CMD.REPAIR] = true,
	[CMD.ATTACK] = true,
}

local function ReAssignAssists(newUnit,oldUnit)
	local allUnits = spGetAllUnits(newUnit)
	for i = 1, #allUnits do
		local unitID = allUnits[i]

		if GG.GetUnitTarget(unitID) == oldUnit then
			GG.SetUnitTarget(unitID, newUnit)
		end

		local cmds = spGetCommandQueue(unitID, -1)
		for j = 1, #cmds do
			local cmd = cmds[j]
			local params = cmd.params
			if (unitTargetCommand[cmd.id] or (singleParamUnitTargetCommand[cmd.id] and #params == 1)) and (params[1] == oldUnit) then
				params[1] = newUnit
				local opts = (cmd.options.meta and CMD.OPT_META or 0) + (cmd.options.ctrl and CMD.OPT_CTRL or 0) + (cmd.options.alt and CMD.OPT_ALT or 0)
				spGiveOrderToUnit(unitID, CMD.INSERT, {cmd.tag, cmd.id, opts, params[1], params[2], params[3]}, 0)
				spGiveOrderToUnit(unitID, CMD.REMOVE, {cmd.tag}, 0)
			end
		end
	end
end

local function HeadingToFacing(heading)
	return math.floor((heading + 8192) / 16384) % 4
end

local upgradedUnits = {}
local upgradingUnit = false
local function UpgradeUnit(unitID, newUnitDef, unitTeam, reverse)
	if upgradingUnit or (not newUnitDef) then
		return
	end

	local defName = newUnitDef.name
	-- copy dominatrix stuff
	local originTeam, originAllyTeam, controllerID, controllerAllyTeam = GG.Capture.GetMastermind(unitID)

	-- you see, Anarchid's exploit is fixed this way
	if (originTeam ~= nil) and (spValidUnitID(controllerID)) then
		unitTeam = spGetUnitTeam(controllerID)
  end

	local px, py, pz = spGetUnitPosition(unitID)
	local h = spGetUnitHeading(unitID)
	spSetUnitBlocking(unitID, false)

	--// copy health
	local oldHealth,oldMaxHealth,paralyzeDamage,captureProgress,buildProgress = spGetUnitHealth(unitID)

	local isBeingBuilt = false
	if buildProgress and buildProgress < 1 then
		isBeingBuilt = true
	end

	local newUnit
	upgradingUnit = true

	if newUnitDef.isImmobile then
		local x = math.floor(px/16)*16
		local y = py
		local z = math.floor(pz/16)*16
		local face = HeadingToFacing(h)
		local xsize = newUnitDef.xsize
		local zsize =(newUnitDef.zsize or newUnitDef.ysize)
		if ((face == 1) or(face == 3)) then
			xsize, zsize = zsize, xsize
		end
		if xsize/4 ~= math.floor(xsize/4) then
			x = x+8
		end
		if zsize/4 ~= math.floor(zsize/4) then
			z = z+8
		end
    newUnit = spCreateUnit(defName, x, y, z, face, unitTeam, isBeingBuilt)
		spSetUnitPosition(newUnit, x, y, z)
	else
    newUnit = spCreateUnit(defName, px, py, pz, HeadingToFacing(h), unitTeam, isBeingBuilt)
		spSetUnitRotation(newUnit, 0, -h * math.pi / 32768, 0)
		spSetUnitPosition(newUnit, px, py, pz)
	end

	--// copy facplop
	local facplop = spGetUnitRulesParam(unitID, "facplop")
	-- Remove old facplop due to a bug that allows facplop duplication if done during morph.
	if facplop and (facplop == 1) then
		spSetUnitRulesParam(unitID, "facplop", 0, {inlos = true})
	end
	--//copy command queue
	local cmds = spGetCommandQueue(unitID, -1)

	local states = spGetUnitStates(unitID) -- This can be left in table-state mode until REVERSE_COMPAT is not an issue.
	states.retreat = spGetUnitRulesParam(unitID, "retreatState") or 0
	states.buildPrio = spGetUnitRulesParam(unitID, "buildpriority") or 1
	states.miscPrio = spGetUnitRulesParam(unitID, "miscpriority") or 1

	--// copy cloak state
	local wantCloakState = spGetUnitRulesParam(unitID, "wantcloak")
	--// copy shield power
	local shieldNum = spGetUnitRulesParam(unitID, "comm_shield_num") or -1
	local oldShieldState, oldShieldCharge = spGetUnitShieldState(unitID, shieldNum)
	--//copy experience
	local newXp = spGetUnitExperience(unitID)
	local oldBuildTime = suGetUnitCost(unitID, newUnitDef.id)
	--//copy unit speed
	local velX,velY,velZ = spGetUnitVelocity(unitID) --remember speed

	spSetUnitRulesParam(newUnit, "jumpReload", spGetUnitRulesParam(unitID, "jumpReload") or 1)

	--// FIXME: - re-attach to current transport?
	--// update selection
	spSetUnitBlocking(newUnit, true)

	-- copy disarmed
	local paradisdmg, pdtime = GG.getUnitParalysisExternal(unitID)
	if (paradisdmg ~= nil) then
		GG.setUnitParalysisExternal(newUnit, paradisdmg, pdtime)
	end

	-- copy dominatrix lineage
	if (originTeam ~= nil) then
		GG.Capture.SetMastermind(newUnit, originTeam, originAllyTeam, controllerID, controllerAllyTeam)
	end

	spDestroyUnit(unitID, false, true) -- selfd = false, reclaim = true

	--//transfer unit speed
	local gy = spGetGroundHeight(px, pz)
	if py>gy+1 then --unit is off-ground
		spAddUnitImpulse(newUnit,0,1,0) --dummy impulse (applying impulse>1 stop engine from forcing new unit to stick on map surface, unstick!)
		spAddUnitImpulse(newUnit,0,-1,0) --negate dummy impulse
	end
	spAddUnitImpulse(newUnit,velX,velY,velZ) --restore speed

	-- script.StartMoving is not called if a unit is created and then given velocity via impulse.
	local speed = math.sqrt(velX^2 + velY^2 + velZ^2)
	if speed > 0.6 then
		local env = Spring.UnitScript.GetScriptEnv(newUnit)
		if env and env.script.StartMoving then
			Spring.UnitScript.CallAsUnit(newUnit,env.script.StartMoving)
		end
	end

	--// transfer facplop
	if facplop and (facplop == 1) then
		spSetUnitRulesParam(newUnit, "facplop", 1, {inlos = true})
	end

	--// transfer health
	-- old health is declared far above
	local _,newMaxHealth		 = spGetUnitHealth(newUnit)
	local newHealth = (oldHealth / oldMaxHealth) * newMaxHealth
	if newHealth <= 1 then
		newHealth = 1
	end

	local newPara = paralyzeDamage*newMaxHealth/oldMaxHealth
	local slowDamage = spGetUnitRulesParam(unitID,"slowState")
	if slowDamage then
		GG.addSlowDamage(newUnit, slowDamage*newMaxHealth)
	end
	spSetUnitHealth(newUnit, {health = newHealth, build = buildProgress, paralyze = newPara, capture = captureProgress })

	--//transfer experience
	spSetUnitExperience(newUnit, newXp)

	--//transfer drone state
	local parentUnitID = spGetUnitRulesParam(unitID, "parent_unit_id")
	local droneIdx = spGetUnitRulesParam(unitID, "drone_set_index")
	if parentUnitID then
		-- we don't actually want this
		--spSetUnitRulesParam(newUnit, "parent_unit_id", unitID)
	end

	if droneIdx then
		spSetUnitRulesParam(newUnit, "drone_set_index", setNum)
	end

	spSetUnitRulesParam(newUnit, "shieldChargeDisabled", 0, { allied = true })

	--//transfer some state
	local transferTable = {
		{CMD.FIRE_STATE,    { states.firestate             }, 0 },
		{CMD.MOVE_STATE,    { states.movestate             }, 0 },
		{CMD.REPEAT,        { states["repeat"] and 1 or 0  }, 0 },
		{CMD_WANT_CLOAK,    { wantCloakState or 0          }, 0 },
		{CMD.ONOFF,         { 1                            }, 0 },
		{CMD.TRAJECTORY,    { states.trajectory and 1 or 0 }, 0 },
		{CMD_PRIORITY,      { states.buildPrio             }, 0 },
		{CMD_RETREAT,       { states.retreat               }, states.retreat == 0 and CMD.OPT_RIGHT or 0 },
		{CMD_MISC_PRIORITY, { states.miscPrio              }, 0 },
	}

	spGiveOrderArrayToUnitArray({ newUnit }, transferTable)

	--//reassign assist commands to new unit
	ReAssignAssists(newUnit,unitID)
	--//transfer command queue
	for i = 1, #cmds do
		local cmd = cmds[i]
		local coded = cmd.options.coded + (cmd.options.shift and 0 or CMD.OPT_SHIFT) -- orders without SHIFT can appear at positions other than the 1st due to CMD.INSERT; they'd cancel any previous commands if added raw
		if cmd.id < 0 then -- repair case for construction
			local units = spGetUnitsInRectangle(cmd.params[1] - 16, cmd.params[3] - 16, cmd.params[1] + 16, cmd.params[3] + 16)
			local allyTeam = spGetUnitAllyTeam(unitID)
			local notFound = true
			for j = 1, #units do
				local areaUnitID = units[j]
				if allyTeam == spGetUnitAllyTeam(areaUnitID) and spGetUnitDefID(areaUnitID) == -cmd.id then
					spGiveOrderToUnit(newUnit, CMD.REPAIR, {areaUnitID}, coded)
					notFound = false
					break
				end
			end
			if notFound then
				spGiveOrderToUnit(newUnit, cmd.id, cmd.params, coded)
			end
		else
			spGiveOrderToUnit(newUnit, cmd.id, cmd.params, coded)
		end
	end

	upgradingUnit = false
  return newUnit
end

local function setStats(unitID, UnitDef, experience)
	if blacklist.nogrowth[UnitDef.name] then
		return
	end

	local current_health, old_max_health = spGetUnitHealth(unitID)
	local is_mini = string.find(UnitDef.name, "_mini")
	local mini_scale_mult = (is_mini and growthSettings.miniScale) or 1.0
	local mini_speed_mult = (is_mini and growthSettings.miniSpeed) or 1.0
	local exp_clamped = math.min(math.floor(experience), growthSettings.eliteLevel)
	local max_hp_mult = math.pow(growthSettings.maxHPMult, exp_clamped)
	local speed_mult = math.pow(growthSettings.speedMult, exp_clamped) * mini_speed_mult
	local range_mult = ((not blacklist.norangegrowth[UnitDef.name]) and math.pow(growthSettings.rangeMult, exp_clamped)) or 1.0
	local sense_mult = math.pow(growthSettings.senseMult, exp_clamped)
	local reload_mult = math.pow(growthSettings.reloadMult, exp_clamped)
	local scale_mult = math.pow(growthSettings.scaleMult, exp_clamped) * mini_scale_mult
	local econ_mult = math.pow(growthSettings.econMult, exp_clamped)

	local new_max_health = max_hp_mult * UnitDef.health
	local new_current_health = current_health + new_max_health - old_max_health
	spSetUnitMaxHealth(unitID, new_max_health)
	spSetUnitHealth(unitID, math.min(new_max_health, new_current_health))
	
	local cost = getCost(unitID, spGetUnitDefID(unitID))
	spSetUnitCosts(unitID, {
		buildTime = cost * max_hp_mult,
		metalCost = cost * max_hp_mult,
		energyCost = cost * max_hp_mult
	})

	if not blacklist.noscale[UnitDef.name] and (not string.find(UnitDef.name, "dyntrainer")) then
    	GG.UnitScale(unitID, scale_mult)
	end

	-- we use a cheaper alternative to replacing the unit every level
	GG.Attributes.AddEffect(unitID, "level_effect", {
		move = speed_mult,
		reload = reload_mult,
		range = range_mult,
		sense = sense_mult,
	})

	local allyTeamID = Spring.GetUnitAllyTeam(unitID)
	local allyTeamIncome = GG.allyTeamIncomeMult and GG.allyTeamIncomeMult[allyTeamID]
	GG.unit_handicap[unitID] = econ_mult * (allyTeamIncome or 1)
	GG.UpdateUnitAttributes(unitID)

	GG.PerkOnStatChange(unitID)
end

local unitReplaceList = {}
local autoxpList = {}
function gadget:Initialize()
	GG.SetStats = setStats

	Spring.SetGameRulesParam("econ_mult_enabled", 1)
end

function gadget:UnitExperience(unitID, unitDefID, unitTeam, experience, oldExperience)
	if math.floor(experience) - math.floor(oldExperience) == 0 then
		return
	end

	local UnitDef = UnitDefs[unitDefID]
	if not (blacklist.nogrowth[UnitDef.name] or GG.DummyUnits[unitID]) then
		if experience > 9.0 then
			GetLevelWeapon(unitID, UnitDef)
		end

		local is_mini = (string.find(UnitDef.name, "_mini") and true) or false
		if experience >= growthSettings.eliteLevel
			and (not upgradedUnits[unitID])
			and (not blacklist.nomaxlvl[UnitDef.name])
		then
			if is_mini then
				spSetUnitExperience(unitID, 0.0)
				local normalName = string.gsub(UnitDef.name, "_mini", "")
				unitReplaceList[unitID] = { udName = normalName, team = unitTeam, reverse = false }
			else
				upgradedUnits[unitID] = true
			end
		end

		if experience >= growthSettings.eliteLevel then
			local pts = math.floor(math.floor(experience) / growthSettings.levelsPerPerk)
			GG.SetPerkPoints(unitID, pts)
		end

		setStats(unitID, UnitDef, experience)
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local UnitDef = UnitDefs[unitDefID]

	if autoxpDefs[UnitDef.name] then
		autoxpList[unitID] = autoxpDefs[UnitDef.name]
	end

	setStats(unitID, UnitDef, spGetUnitExperience(unitID))
end

-- res, zombies, etc.
function gadget:GameFrame(n)
	while next(unitReplaceList) do
		local id,r = next(unitReplaceList)
		if (Spring.ValidUnitID(id) and (not Spring.GetUnitIsDead(id))) then
			local newUd = UnitDefNames[r.udName]
			local oldWeapon = GG.unitWeapons[id]
			local newUnit = UpgradeUnit(id, newUd, r.team, r.reverse)
			if newUnit then
				upgradedUnits[newUnit] = ((not r.reverse) and string.find(r.udName, "_maxlvl")) or nil
				GG.unitWeapons[newUnit] = ((not r.reverse) and oldWeapon) or nil
			end
		end
		unitReplaceList[id] = nil
	end

	if (n % 30 < 0.01) then
		for id,rate in pairs(autoxpList) do
			spSetUnitExperience(id, spGetUnitExperience(id) + rate);
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	unitReplaceList[unitID] = nil
	upgradedUnits[unitID] = nil
	autoxpList[unitID] = nil
	GG.unitWeapons[unitID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if not Spring.ValidUnitID(attackerID) then
		return damage
	end

	local experience = Spring.GetUnitExperience(attackerID)
	local exp_clamped = math.min(math.floor(experience), growthSettings.eliteLevel)
	local damageMult = math.pow(growthSettings.damageMult, exp_clamped)
	return damage * damageMult
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
end