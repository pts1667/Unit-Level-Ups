function gadget:GetInfo()
  return {
    name      = "Perk Autoselector",
    desc      = "Autoselects perks",
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

local perkDefs,perkIDTable = VFS.Include("luarules/configs/perkdefs.lua")
local globalAutoperkEnabled = {}
local unitAutoperkEnabled = {}

local function PASAddUnit(unitID)
  local teamID = Spring.GetUnitTeam(unitID)
  if globalAutoperkEnabled[teamID] then
    unitAutoperkEnabled[unitID] = true
  end
end

GG.PASAddUnit = PASAddUnit
GG.GlobalAutoperkEnabled = {}

function gadget:Initialize()
  local totalTeamList = {}
	local tempTeamList = Spring.GetTeamList()
	for i=1, #tempTeamList do
		local team = tempTeamList[i]
		--Spring.Echo('team', team)
		if team ~= gaiaTeamID then
			totalTeamList[team] = true
		end
	end

  for teamID,_ in pairs(totalTeamList) do
    local _, _, _, isAI = Spring.GetTeamInfo(teamID, false)
    if isAI then
      globalAutoperkEnabled[teamID] = true
    end
  end

  GG.GlobalAutoperkEnabled = globalAutoperkEnabled
end

function gadget:DestroyUnit(unitID)
  unitAutoperkEnabled[unitID] = nil
end

function gadget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
  if unitAutoperkEnabled[unitID] and (not globalAutoperkEnabled[newTeam]) then
    unitAutoperkEnabled[unitID] = nil
  end
end

function gadget:GameFrame(frame)
  if (frame > 30 and (frame % 30 < 0.1)) then
    for unitID,_ in pairs(unitAutoperkEnabled) do
      local currentPerkInfo = GG.CurrentPerks(unitID)
      local perkPoints = currentPerkInfo.perkPoints or 0
      local availablePerks = currentPerkInfo.availablePerks or {}
      if perkPoints > 0 and #availablePerks > 0 then
        -- just pick random perk for now
        -- I would like a configurable perk autoselector for humans eventually
        local perkIdx = math.ceil(math.random() * #availablePerks)
        local perkName = availablePerks[perkIdx]
        if not perkDefs[perkName].noAutoPick then
          GG.AddPerk(unitID, perkName)
        end
      end
    end
  end
end