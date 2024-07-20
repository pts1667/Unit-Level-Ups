local root = piece "root"

function script.Create()
	Spring.SetUnitNoDraw(unitID, true)
	Spring.SetUnitNoSelect(unitID, true)
	Spring.SetUnitNoMinimap(unitID, true)
	Spring.SetUnitRadiusAndHeight(unitID, 0, 0)
end