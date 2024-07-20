if not gadgetHandler:IsSyncedCode() then return end

function gadget:GetInfo() return {
	name    = "Experience",
	desc    = "Handles unit XP",
	author  = "Sprung",
	date    = "2016",
	license = "PD",
	layer   = 0,
	enabled = true,
} end

local levelSettings = VFS.Include('luarules/configs/levelupsettings.lua')
local spGetUnitHealth = Spring.GetUnitHealth
local spValidUnitID = Spring.ValidUnitID
local spSetUnitExperience = Spring.SetUnitExperience
local spGetUnitExperience = Spring.GetUnitExperience
local getCost = Spring.Utilities.GetUnitCost
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitLosState = Spring.GetUnitLosState
local spEcho = Spring.Echo
local allyTeamByTeam = {}

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if not attackerID or not spValidUnitID(attackerID)
	or spAreTeamsAllied(unitTeam, attackerTeam)
	or GG.DummyUnits[attackerID]
	--or paralyzer -- requires a sensible formula? LOL
	then
		return
	end

	local hp, maxHP = spGetUnitHealth(unitID)
	local victimXP = spGetUnitExperience(unitID)
	local attackerXP = spGetUnitExperience(attackerID)
	local paralyzerMult = (paralyzer and 0.3) or 1.0
	local xpCostFactor = math.min(20.0, getCost(unitID, unitDefID) / getCost(attackerID, attackerDefID))
	local xpFalloffFactor = math.pow(levelSettings.xpFalloff, math.floor(attackerXP))
	local xpVictimFactor = math.min(20.0, 1.0 + math.floor(victimXP) * 0.25)
	local xpMult = levelSettings.xpScale * xpCostFactor * xpFalloffFactor * xpVictimFactor
	local xpAdd = paralyzerMult * xpMult * (((hp > 0) and damage or (damage + hp)) / maxHP)
	spSetUnitExperience(attackerID, spGetUnitExperience(attackerID) + xpAdd)
end

function gadget:Initialize()
	Spring.SetExperienceGrade(1.0)

	local teams = Spring.GetTeamList()
	for i = 1, #teams do
		local teamID = teams[i]
		local allyTeamID = select(6, Spring.GetTeamInfo(teamID, false))
		allyTeamByTeam[teamID] = allyTeamID
	end
end
