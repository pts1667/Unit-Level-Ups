local uluOptions = { 
  aielites = { name = "AI Elites enabled", default = 0.0 },
  scaleMult = { name = "Level Scale Multiplier", default = 1.025 },
  maxHPMult = { name = "Level HP Multiplier", default = 1.1 },
  speedMult = { name = "Level Speed Multiplier", default = 1.025 },
  senseMult = { name = "Level Radar Multiplier", default = 1.025 },
  econMult = { name = "Level Economy Multiplier", default = 1.05 },
  reloadMult = { name = "Level Reload Multiplier", default = 1.025 },
  rangeMult = { name = "Level Range Multiplier", default = 1.025 },
  miniScale = { name = "Drone Scale Multiplier", default = 0.5 },
  miniSpeed = { name = "Drone Speed Multiplier", default = 2.0 },
  eliteLevel = { name = "Elite Level", default = 20, integer = true },
  levelsPerPerk = { name = "Levels Per Perk", default = 10, integer = true },
  xpScale = { name = "XP Multiplier", default = 2.0 },
  xpFalloff = { name = "XP Falloff", default = 0.95 },
  damageMult = { name = "Level Damage Multiplier", default = 1.025 }
}

local options = {}
for optName,configLayout in pairs(uluOptions) do
  options[#options+1] = {
    key = optName,
    name = configLayout.name,
    desc = '\nkey: ' .. optName,
    section = 'Unit Level Ups',
    type = "number",
    def = configLayout.default,
    min = 0,
    max = 10000,
    step = (configLayout.integer and 1) or 0.05
  }
end

options[#options + 1] = {
  key = "noelo",
  name = "No Elo",
  desc = "Prevent battle from affecting Elo rankings",
  type = "bool",
  def = false
}

return options