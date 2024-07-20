local blacklistDefs = {
  noweapon = {
    striderantiheavy = true,
    shipheavyarty = true,
    striderdante = true,
    striderscorpion = true,
    shipriot = true,
    jumpsumo = true,
    gunshipheavytrans = true,
    gunshipkrow = true,
    striderdetriment = true,
    bomberheavy = true,
    chicken_shield = true,
    raveparty = true,
    vehcon = true,
    tankcon = true,
    spidercon = true,
    shipcon = true,
    jumpcon = true,
    hovercon = true,
    gunshipcon = true,
    cloakcon = true,
    amphcon = true,
    empmissile = true,
    tacnuke = true,
    seismic = true,
    napalmmissile = true,
    missileslow = true,
    staticnuke = true,
    vehcapture = true,
    staticjammer = true,
    cloakjammer = true
  },
  noscale = {
    striderfunnelweb = true,
    turretgauss = true,
    gunshipaa = true,
    energygeo = true,
    mahlazer = true,
    starlight_satellite = true,
    factoryveh = true
  },
  nogrowth = {
    shipcarrier = true,
    energywind = true
  },
  norangegrowth = {
    hoverdepthcharge = true,
  },
  nomaxlvl = { -- anything that still uses a COB script should go in here. They won't have weapons either unfortunately
    dronecarry = true,
    chicken_digger = true,
    chicken_dodo = true,
    chicken_dragon = true,
    chicken_drone_starter = true,
    chicken_drone = true,
    chicken_leaper = true,
    chicken_listener = true,
    chicken_pigeon = true,
    chicken_rafflesia = true,
    chicken_shield = true,
    chicken_spidermonkey = true,
    chicken_sporeshooter = true,
    chicken_tiamat = true,
    chicken = true,
    chickena = true,
    chickenblobber = true,
    chickenbroodqueen = true,
    chickenc = true,
    chickenf = true,
    chickenqueenlite = true,
    chickenr = true,
    chickens = true
  }
};

local function insertAppender(key, appender)
  local appendTable = {}
  for k,v in pairs(blacklistDefs[key]) do
    local appendKey = k..appender
    appendTable[appendKey] = true
  end
  for k,v in pairs(appendTable) do
    blacklistDefs[key][k] = true
  end
end

insertAppender("noweapon", "_maxlvl")
insertAppender("norangegrowth", "_maxlvl")
insertAppender("noscale", "_maxlvl")
insertAppender("noweapon", "_mini")
insertAppender("norangegrowth", "_mini")
insertAppender("noscale", "_mini")

return blacklistDefs