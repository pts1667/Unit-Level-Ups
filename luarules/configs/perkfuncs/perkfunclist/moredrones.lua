local updateDrones = function (unitID, unitDefID, unitTeam, experience, oldExperience)
  GG.SetMiniMeGuardRadius(unitID, 300.0 + math.log(math.floor(experience)) * 10.0)
  if math.floor(experience / 5.0) == math.floor(oldExperience / 5.0) then
    return
  end

  if string.find(UnitDefs[unitDefID].name, "chicken") then
    return
  end

  local prevNumDrones = 0
  if GG.MiniMeMasterTables[unitID] then
    for _ in pairs(GG.MiniMeMasterTables[unitID]) do prevNumDrones = prevNumDrones + 1 end
  end

  local newDroneNum = math.floor(experience / 5.0)
  local normalName = UnitDefs[unitDefID].name
  local miniUnitDefExists = UnitDefNames[normalName .. "_mini"] or false
  if miniUnitDefExists then
    GG.QueueMiniMe(unitID, normalName .. "_mini", unitTeam, newDroneNum - prevNumDrones)
  end
end

return {
  onUnitExperience = function (unitID, unitDefID, unitTeam, experience, oldExperience)
    updateDrones(unitID, unitDefID, unitTeam, experience, oldExperience)
  end,
  onPick = function (unitID)
    local unitDefID = Spring.GetUnitDefID(unitID)
    local unitTeam = Spring.GetUnitTeam(unitID)
    local experience = Spring.GetUnitExperience(unitID)

    updateDrones(unitID, unitDefID, unitTeam, experience, 0.0)
  end
}