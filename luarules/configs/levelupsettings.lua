local modOptions = Spring.GetModOptions()

return {
  scaleMult = (modOptions["scalemult"] and tonumber(modOptions["scalemult"])) or 1.025,
  maxHPMult = (modOptions["maxhpmult"] and tonumber(modOptions["maxhpmult"])) or 1.1,
  speedMult = (modOptions["speedmult"] and tonumber(modOptions["speedmult"])) or 1.025,
  senseMult = (modOptions["sensemult"] and tonumber(modOptions["sensemult"])) or 1.025,
  econMult = (modOptions["econmult"] and tonumber(modOptions["econmult"])) or 1.05,
  reloadMult = (modOptions["reloadmult"] and tonumber(modOptions["reloadmult"])) or 1.025,
  rangeMult = (modOptions["rangemult"] and tonumber(modOptions["rangemult"])) or 1.025,
  miniScale = (modOptions["miniscale"] and tonumber(modOptions["miniscale"])) or 0.5,
  miniSpeed = (modOptions["minispeed"] and tonumber(modOptions["minispeed"])) or 2.0,
  eliteLevel = (modOptions["elitelevel"] and tonumber(modOptions["elitelevel"])) or 20,
  levelsPerPerk = (modOptions["levelsperperk"] and tonumber(modOptions["levelsperperk"])) or 10,
  xpScale = (modOptions["xpscale"] and tonumber(modOptions["xpscale"])) or 2.0,
  xpFalloff = (modOptions["xpfalloff"] and tonumber(modOptions["xpfalloff"])) or 0.97,
  damageMult = (modOptions["damagemult"] and tonumber(modOptions["damagemult"])) or 1.05,
  aiElites = (modOptions["aielites"] and tonumber(modOptions["aielites"])) or 0.0,
}