return {
  getGoodClusterProjPosition_XYZOrigin = function (x, y, z, weaponDefID, targetID)
    local wd = WeaponDefs[weaponDefID]
    local targetX,targetY,targetZ = Spring.GetUnitPosition(targetID)
    local accuracy = wd.accuracy or 0.0
    targetX = targetX + math.random() * accuracy
    targetZ = targetZ + math.random() * accuracy

    local tsX,tsY,tsZ,tOfsX,tOfsY,tOfsZ = Spring.GetUnitCollisionVolumeData(targetID)
    local totalTargetCentreX = tOfsX + targetX --+ tsX * 0.5
    local totalTargetCentreY = tOfsY + targetY + tsY * 0.5
    local totalTargetCentreZ = tOfsZ + targetZ --+ tsZ * 0.5

    local diffVec = {
      x = totalTargetCentreX - x,
      y = totalTargetCentreY - y,
      z = totalTargetCentreZ - z
    }

    local diffVecMag = math.sqrt(diffVec.x * diffVec.x + diffVec.y * diffVec.y + diffVec.z * diffVec.z)
    local diffVecNorm = {
      x = diffVec.x / diffVecMag,
      y = diffVec.y / diffVecMag,
      z = diffVec.z / diffVecMag
    }
    
    return {x, y, z},diffVecNorm
  end,
  getGoodClusterProjectilePosition = function (unitID, targetID)
    local unitX,unitY,unitZ = Spring.GetUnitPosition(unitID)
    local targetX,targetY,targetZ = Spring.GetUnitPosition(targetID)
    local sX,sY,sZ,ofsX,ofsY,ofsZ = Spring.GetUnitCollisionVolumeData(unitID)
    local tsX,tsY,tsZ,tOfsX,tOfsY,tOfsZ = Spring.GetUnitCollisionVolumeData(targetID)
    local totalOfsX = ofsX + unitX
    local totalOfsY = ofsY + unitY
    local totalOfsZ = ofsZ + unitZ
    local totalTargetCentreX = tOfsX + targetX --+ tsX * 0.5
    local totalTargetCentreY = tOfsY + targetY + tsY * 0.5
    local totalTargetCentreZ = tOfsZ + targetZ --+ tsZ * 0.5
    local diffVec = {
      x = totalTargetCentreX - totalOfsX,
      y = totalTargetCentreY - totalOfsY,
      z = totalTargetCentreZ - totalOfsZ
    }
    local diffVecMag = math.sqrt(diffVec.x * diffVec.x + diffVec.y * diffVec.y + diffVec.z * diffVec.z)
    local diffVecNorm = {
      x = diffVec.x / diffVecMag,
      y = diffVec.y / diffVecMag,
      z = diffVec.z / diffVecMag
    }
    local res = {
      x = totalOfsX + (sX + 0.5) * diffVecNorm.x,
      y = totalOfsY + (sY + 0.5) * diffVecNorm.y,
      z = totalOfsZ + (sZ + 0.5) * diffVecNorm.z
    }

    return {res.x, res.y, res.z},diffVecNorm
  end,
  getClusterRange = function (unitID, weaponDef)
    local range_raw = weaponDef.range
    local experience = math.min(20.0, math.floor(Spring.GetUnitExperience(unitID)))
    local range = range_raw * math.exp(1.05, experience)
    return (GG.HasPerk(unitID, "clusterRange") and range) or range_raw
  end,
  getRandomTargetListInRange = function (x, y, z, range, ally, n, excludeMap)
    local units = Spring.GetUnitsInSphere(x, y, z, range)
    local unitCandidates = {}
    local unitList = {}
    for i=1,#units do
      local targetable = not Spring.GetUnitRulesParam(units[i], 'untargetable')
      if (not (Spring.GetUnitAllyTeam(units[i]) == ally or (excludeMap and excludeMap[units[i]]))) and targetable then
        unitCandidates[#unitCandidates+1] = units[i]
      end
    end

    for i=1,math.min(#unitCandidates, n) do
      local randomIdx = math.floor(math.random() * #unitCandidates) + 1
      unitList[#unitList+1] = unitCandidates[randomIdx]
      table.remove(unitCandidates, randomIdx)
    end

    return unitList
  end,
  getRandomTargetInRange = function (x, y, z, range, ally, cond)
    local units = Spring.GetUnitsInSphere(x, y, z, range)
    local unitCandidates = {}
    for i=1,#units do
      local targetable = not Spring.GetUnitRulesParam(units[i], 'untargetable')
      if (not (Spring.GetUnitAllyTeam(units[i]) == ally)) and cond(units[i]) and targetable then
        unitCandidates[#unitCandidates+1] = units[i]
      end
    end

    local randomIdx = math.floor(math.random() * #unitCandidates)
    return unitCandidates[randomIdx]
  end
}