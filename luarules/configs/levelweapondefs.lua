local VFS_Include = VFS.Include

local shared = VFS_Include('gamedata/unitdefs_pre.lua', nil, VFS_GAME)
Shared = shared

local system = VFS_Include('gamedata/system.lua')
local lowerKeys = system.lowerkeys

function combineArrays(...)
  local ret = {}

  for i=1,select("#", ...) do
    local t = select(i, ...)
    for j=1,#t do
      ret[#ret+1] = t[j]
    end
  end

  return ret
end

local levelWeaponList = {
  lowCost = {
    [[TORPMISSILE_LVLWEP]],
    [[BOT_ROCKET_LVLWEP]],
  },
  medCostSkirm = {
    [[DISRUPTOR_BEAM_LVLWEP]],
    [[MISSILE_BATTERY_LVLWEP]]
  },
  medCostRiot = {
    [[FLECHETTE_LVLWEP]],
    [[LASER_LVLWEP]]
  },
  medCostRaid = {
    [[GRENADE_LVLWEP]],
    [[NAPALM_BOMBLET_LVLWEP]]
  },
  medCostAssault = {
    [[LIGHTNING_LVLWEP]],
  },
  highCost = {
    [[PLASMA_LVLWEP]],
    [[ATA_LVLWEP]],
    [[NAPALM_MISSILE_LVLWEP]]
  },
  veryHighCost = {
    [[ORCONE_ROCKET_LVLWEP]],
    [[RED_KILLER_LVLWEP]],
    [[ORANGE_ROASTER_LVLWEP]]
  },
  melee = {
    [[SLOWBEAM_LVLWEP]]
  }
}

levelWeaponList.medCost = combineArrays(
  levelWeaponList.medCostSkirm,
  levelWeaponList.medCostRaid,
  levelWeaponList.medCostRiot
)

local levelWeaponListDefs = {
  NAPALM_MISSILE_LVLWEP = {
    name                    = [[Napalm Missile]],
    cegTag                  = [[napalmtrail]],
    areaOfEffect            = 256,
    craterAreaOfEffect      = 64,
    avoidFriendly           = false,
    collideFriendly         = false,
    craterBoost             = 4,
    craterMult              = 3.5,

    customParams            = {
      setunitsonfire = "1",
      burntime = 90,

      area_damage = 1,
      area_damage_radius = 128,
      area_damage_dps = 20,
      area_damage_duration = 20,
      
      light_color = [[1.35 0.5 0.36]],
      light_radius = 225,
    },

    damage                  = {
      default = 101,
    },

    edgeEffectiveness       = 0.4,
    explosionGenerator      = [[custom:napalm_missile]],
    fireStarter             = 220,
    flightTime              = 100,
    impulseBoost            = 0,
    impulseFactor           = 0,
    interceptedByShieldType = 1,
    model                   = [[wep_napalm.s3o]],
    noSelfDamage            = true,
    range                   = 3500,
    reloadtime              = 20,
    smokeTrail              = false,
    soundHit                = [[weapon/missile/nalpalm_missile_hit]],
    soundStart              = [[SiloLaunch]],
    tolerance               = 4000,
    turnrate                = 18000,
    weaponAcceleration      = 180,
    weaponTimer             = 3,
    weaponType              = [[StarburstLauncher]],
    weaponVelocity          = 1200,
  },
  LIGHTNING_LVLWEP = {
    name                    = [[Lightning Gun]],
    areaOfEffect            = 8,
    craterBoost             = 0,
    craterMult              = 0,

    customParams            = {
      extra_damage = 600,
      
      light_camera_height = 1600,
      light_color = [[0.85 0.85 1.2]],
      light_radius = 200,
    },

    cylinderTargeting      = 0,

    damage                  = {
      default        = 230,
    },

    duration                = 10,
    explosionGenerator      = [[custom:LIGHTNINGPLOSION]],
    fireStarter             = 50,
    impactOnly              = true,
    impulseBoost            = 0,
    impulseFactor           = 0,
    intensity               = 12,
    interceptedByShieldType = 1,
    paralyzeTime            = 1,
    range                   = 340,
    reloadtime              = 2.2,
    rgbColor                = [[0.5 0.5 1]],
    soundStart              = [[weapon/more_lightning_fast]],
    soundTrigger            = true,
    sprayAngle              = 900,
    texture1                = [[lightning]],
    thickness               = 10,
    turret                  = true,
    waterweapon             = false,
    weaponType              = [[LightningCannon]],
    weaponVelocity          = 400,
  },
  RED_KILLER_LVLWEP = {
    name                    = [[Red Killer]],
    accuracy                = 750,
    avoidFeature            = false,
    avoidGround             = false,
    areaOfEffect            = 192,
    craterBoost             = 4,
    craterMult              = 3,
    damage                  = {
      default = 1500.1,
    },

    edgeeffectiveness       = 0.5,
    explosionGenerator      = [[custom:NUKE_150]],
    impulseBoost            = 0.5,
    impulseFactor           = 0.2,
    interceptedByShieldType = 1,
    myGravity               = 0.18,
    range                   = 7500,
    rgbColor                = [[1 0.1 0.1]],
    reloadtime              = 10,
    size                    = 15,
    sizeDecay               = 0.03,
    soundHit                = [[explosion/mini_nuke]],
    soundStart              = [[weapon/cannon/big_begrtha_gun_fire]],
    stages                  = 30,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 1100,
  },
  ORANGE_ROASTER_LVLWEP = {
    name                    = [[Orange Roaster]],
    accuracy                = 750,
    areaOfEffect            = 640,
    craterAreaOfEffect      = 80,
    avoidFeature            = false,
    avoidGround             = false,
    craterBoost             = 0.25,
    craterMult              = 0.5,
    
    customParams              = {
      setunitsonfire = "1",
      burntime = 240,
      burnchance = 1,
      area_damage = 1,
      area_damage_radius = 320,
      area_damage_dps = 40,
      area_damage_duration = 15,
    },

    damage                  = {
      default = 300.9,
      planes  = 300,
    },

    edgeeffectiveness       = 0.25,
    explosionGenerator      = [[custom:napalm_drp]],
    impulseBoost            = 0.2,
    impulseFactor           = 0.1,
    interceptedByShieldType = 1,
    myGravity               = 0.18,
    range                   = 7500,
    rgbColor                = [[0.9 0.3 0]],
    reloadtime              = 10,
    size                      = 15,
    sizeDecay                  = 0.03,
    soundHit                = [[weapon/missile/nalpalm_missile_hit]],
    soundStart              = [[weapon/cannon/big_begrtha_gun_fire]],
    stages                  = 30,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 1100,
  },
  ATA_LVLWEP = {
    name                    = [[Tachyon Accelerator]],
    areaOfEffect            = 20,
    beamTime                = 1,
    coreThickness           = 0.5,
    craterBoost             = 0,
    craterMult              = 0,
    
    customParams            = {
      burst = Shared.BURST_RELIABLE,

      light_color = [[1.25 0.8 1.75]],
      light_radius = 320,
    },
    damage                  = {
      default = 3000.1,
      planes  = 3000.1,
      subs    = 150.1,
    },

    explosionGenerator      = [[custom:ataalaser]],
    fireTolerance           = 8192, -- 45 degrees
    impactOnly              = true,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    largeBeamLaser          = true,
    laserFlareSize          = 10,
    leadLimit               = 18,
    minIntensity            = 1,
    noSelfDamage            = true,
    range                   = 1000,
    reloadtime              = 20,
    rgbColor                = [[0.25 0 1]],
    soundStart              = [[weapon/laser/heavy_laser6]],
    soundStartVolume        = 15,
    texture1                = [[largelaser]],
    texture2                = [[flare]],
    texture3                = [[flare]],
    texture4                = [[smallflare]],
    thickness               = 16.9373846859543,
    tolerance               = 10000,
    turret                  = true,
    weaponType              = [[BeamLaser]],
    weaponVelocity          = 1500,
  },
  SLOWBEAM_LVLWEP = {
    name                    = [[Slowing Beam]],
    areaOfEffect            = 8,
    beamDecay               = 0.9,
    beamTime                = 0.1,
    beamttl                 = 30,
    coreThickness           = 0,
    craterBoost             = 0,
    craterMult              = 0,

    customparams = {
      timeslow_damagefactor = 12,
      timeslow_smartretarget = 0.33,
      timeslow_smartretargethealth = 50,
      
      light_camera_height = 1800,
      light_color = [[0.4 0.15 0.55]],
      light_radius = 150,
    },

    damage                  = {
      default = 15,
    },

    explosionGenerator      = [[custom:flashslow]],
    fireStarter             = 30,
    impactOnly              = true,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    largeBeamLaser          = true,
    laserFlareSize          = 4,
    minIntensity            = 1,
    noSelfDamage            = true,
    range                   = 240,
    reloadtime              = 2,
    rgbColor                = [[0.3 0 0.4]],
    soundStart              = [[weapon/laser/pulse_laser2]],
    soundStartVolume        = 30,
    soundTrigger            = true,
    sweepfire               = false,
    texture1                = [[largelaser]],
    texture2                = [[flare]],
    texture3                = [[flare]],
    texture4                = [[smallflare]],
    thickness               = 8,
    tolerance               = 18000,
    turret                  = true,
    weaponType              = [[BeamLaser]],
    weaponVelocity          = 500,
  },
  NAPALM_BOMBLET_LVLWEP = {
    name                    = [[Flame Bomb]],
    accuracy                = 1200,
    areaOfEffect            = 96,
    avoidFeature            = true,
    avoidFriendly           = true,
    burnblow                = true,
    cegTag                  = [[flamer_koda]],
    craterBoost             = 0,
    craterMult              = 0,

    customParams              = {
      setunitsonfire = "1",
      burnchance     = "1",
      burntime       = 30,

      area_damage = 1,
      area_damage_radius = 54,
      area_damage_dps = 43,
      area_damage_plateau_radius = 20,
      area_damage_duration = 1.6,
      
      light_color = [[1.6 0.8 0.32]],
      light_radius = 320,
    },
    
    damage                  = {
      default = 40,
      planes  = 40,
      subs    = 2,
    },

    explosionGenerator      = [[custom:napalm_koda_small]],
    fireStarter             = 65,
    flameGfxTime            = 0.1,
    impulseBoost            = 0,
    impulseFactor           = 0.2,
    interceptedByShieldType = 1,
    leadLimit               = 90,
    model                   = [[wep_b_fabby.s3o]],
    myGravity               = 0.2,
    noSelfDamage            = true,
    range                   = 215,
    reloadtime              = 0.5,
    soundHit                = [[FireHit]],
    soundHitVolume          = 5,
    soundStart              = [[FireLaunch]],
    soundStartVolume        = 5,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 520,
  },
  GRENADE_LVLWEP = {
    name                    = [[Grenade Launcher]],
    accuracy                = 200,
    areaOfEffect            = 96,
    craterBoost             = 1,
    craterMult              = 2,

    damage                  = {
      default = 240,
      planes  = 240,
      subs    = 12,
    },

    explosionGenerator      = [[custom:PLASMA_HIT_96]],
    fireStarter             = 180,
    impulseBoost            = 0,
    impulseFactor           = 0.2,
    interceptedByShieldType = 2,
    model                   = [[diskball.s3o]],
    projectiles             = 2,
    range                   = 360,
    reloadtime              = 3,
    smokeTrail              = true,
    soundHit                = [[explosion/ex_med6]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/cannon/cannon_fire3]],
    soundStartVolume        = 2,
    soundTrigger            = true,
    sprayangle              = 512,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 400,
  },
  MISSILE_BATTERY_LVLWEP = {
    name                    = [[Heavy Missile Battery]],
    areaOfEffect            = 80,
    cegTag                  = [[missiletrailyellow]],
    craterBoost             = 1,
    craterMult              = 1.4,
    
    customParams        = {
      burst = Shared.BURST_RELIABLE,

      light_camera_height = 3000,
      light_color = [[1 0.58 0.17]],
      light_radius = 200,
    },
    
    damage                  = {
      default = 330,
    },

    fireStarter             = 70,
    fixedlauncher           = true,
    flightTime              = 3.1,
    impulseBoost            = 0.75,
    impulseFactor           = 0.3,
    interceptedByShieldType = 2,
    leadlimit               = 0,
    model                   = [[wep_m_dragonsfang.s3o]],
    projectiles             = 2,
    range                   = 440,
    reloadtime              = 10,
    smokeTrail              = true,
    soundHit                = [[explosion/ex_med5]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/missile/rapid_rocket_fire2]],
    soundStartVolume        = 7,
    startVelocity           = 190,
    texture2                = [[lightsmoketrail]],
    tracks                  = true,
    trajectoryHeight        = 0.4,
    turnRate                = 21000,
    turret                  = true,
    weaponAcceleration      = 90,
    weaponType              = [[MissileLauncher]],
    weaponVelocity          = 180,
  },
  LASER_LVLWEP = {
    name                    = [[High Intensity Laserbeam]],
    areaOfEffect            = 8,
    beamTime                = 0.1,
    coreThickness           = 0.5,
    craterBoost             = 0,
    craterMult              = 0,

    customparams = {
      stats_hide_damage = 1, -- continuous laser
      stats_hide_reload = 1,
      
      light_color = [[0.25 1 0.25]],
      light_radius = 120,
    },

    damage                  = {
      default = 29.68,
      subs    = 1.75,
    },

    explosionGenerator      = [[custom:flash1green]],
    fireStarter             = 30,
    impactOnly              = true,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    largeBeamLaser          = true,
    laserFlareSize          = 4.33,
    minIntensity            = 1,
    noSelfDamage            = true,
    range                   = 345,
    reloadtime              = 0.1,
    rgbColor                = [[0 1 0]],
    soundStart              = [[weapon/laser/laser_burn10]],
    soundTrigger            = true,
    sweepfire               = false,
    texture1                = [[largelaser]],
    texture2                = [[flare]],
    texture3                = [[flare]],
    texture4                = [[smallflare]],
    thickness               = 4.33,
    tolerance               = 18000,
    turret                  = true,
    weaponType              = [[BeamLaser]],
    weaponVelocity          = 500,
  },
  TORPMISSILE_LVLWEP = {
    name                    = [[Torpedo]],
    areaOfEffect            = 32,
    cegTag                  = [[missiletrailyellow]],
    craterBoost             = 1,
    craterMult              = 2,

    customparams = {
      burst = Shared.BURST_RELIABLE,

      light_color = [[1 0.6 0.2]],
      light_radius = 180,
    },

    damage                  = {
      default = 130.01,
      subs    = 10,
    },

    explosionGenerator      = [[custom:INGEBORG]],
    flightTime              = 3.5,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    leadlimit               = 1,
    model                   = [[wep_m_ajax.s3o]],
    noSelfDamage            = true,
    projectiles             = 1,
    range                   = 240,
    reloadtime              = 2,
    smokeTrail              = true,
    soundHit                = [[weapon/cannon/cannon_hit2]],
    soundStart              = [[weapon/missile/missile_fire9]],
    startVelocity           = 140,
    texture2                = [[lightsmoketrail]],
    tolerance               = 1000,
    tracks                  = true,
    trajectoryHeight        = 0.4,
    turnRate                = 18000,
    turret                  = true,
    weaponAcceleration      = 90,
    weaponType              = [[MissileLauncher]],
    weaponVelocity          = 200,
  },
  BOT_ROCKET_LVLWEP = {
    name                    = [[Rocket]],
    areaOfEffect            = 48,
    burnblow                = true,
    cegTag                  = [[rocket_trail_bar]],
    craterBoost             = 0,
    craterMult              = 0,

    customParams        = {
      burst = Shared.BURST_RELIABLE,

      light_camera_height = 1600,
      light_color = [[0.90 0.65 0.30]],
      light_radius = 250,
      reload_move_mod_time = 3,
    },

    damage                  = {
      default = 180,
      subs    = 9,
    },

    fireStarter             = 70,
    flightTime              = 2.45,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 2,
    model                   = [[wep_m_ajax.s3o]],
    noSelfDamage            = true,
    range                   = 455,
    reloadtime              = 3.5,
    smokeTrail              = false,
    soundHit                = [[weapon/missile/sabot_hit]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/missile/sabot_fire]],
    soundStartVolume        = 7,
    startVelocity           = 200,
    tracks                  = false,
    turret                  = true,
    weaponAcceleration      = 200,
    weaponType              = [[MissileLauncher]],
    weaponVelocity          = 200,
  },
  FLECHETTE_LVLWEP = {
    name                    = [[Flechette]],
    areaOfEffect            = 32,
    burst                   = 3,
    burstRate               = 0.033,
    coreThickness           = 0.5,
    craterBoost             = 0,
    craterMult              = 0,

    customParams            = {
      light_camera_height = 2000,
      light_color = [[0.3 0.3 0.05]],
      light_radius = 120,
    },

    damage                  = {
      default = 23,
      subs    = 1.6,
    },

    duration                = 0.02,
    explosionGenerator      = [[custom:BEAMWEAPON_HIT_YELLOW]],
    fireStarter             = 50,
    heightMod               = 1,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    projectiles             = 3,
    range                   = 270,
    reloadtime              = 0.8,
    rgbColor                = [[1 1 0]],
    soundHit                = [[impacts/shotgun_impactv5]],
    soundStart              = [[weapon/shotgun_firev4]],
    soundStartVolume        = 0.5,
    soundTrigger            = true,
    sprayangle              = 1500,
    thickness               = 2,
    tolerance               = 10000,
    turret                  = true,
    weaponType              = [[LaserCannon]],
    weaponVelocity          = 880,
  },
  DISRUPTOR_BEAM_LVLWEP = {
  name                    = [[Disruptor Pulse Beam]],
    areaOfEffect            = 32,
    beamdecay               = 0.9,
    beamTime                = 1/30,
    beamttl                 = 30,
    coreThickness           = 0.25,
    craterBoost             = 0,
    craterMult              = 0,
    
    customparams = {
      burst = Shared.BURST_RELIABLE,

      timeslow_damagefactor = 4,
      timeslow_overslow_frames = 2*30,
      
      light_color = [[1.88 0.63 2.5]],
      light_radius = 320,
    },

    damage                  = {
        default = 460.1,
    },
    
    explosionGenerator      = [[custom:flash2purple]],
    fireStarter             = 30,
    impactOnly              = true,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    largeBeamLaser          = true,
    laserFlareSize          = 4.33,
    minIntensity            = 1,
    noSelfDamage            = true,
    range                   = 420,
    reloadtime              = 10,
    rgbColor                = [[0.3 0 0.4]],
    soundStart              = [[weapon/laser/heavy_laser5]],
    soundStartVolume        = 3.8,
    soundTrigger            = true,
    texture1                = [[largelaser]],
    texture2                = [[flare]],
    texture3                = [[flare]],
    texture4                = [[smallflare]],
    thickness               = 12,
    tolerance               = 18000,
    turret                  = true,
    weaponType              = [[BeamLaser]],
    weaponVelocity          = 500,
  },
  ORCONE_ROCKET_LVLWEP = {
    name                    = [[Medium-Range Missiles]],
    areaOfEffect            = 160,
    cegTag                  = [[seismictrail]],
    collideFriendly         = false,
    craterBoost             = 1,
    craterMult              = 2,
    
    customParams            = {
      gatherradius = [[180]],
      smoothradius = [[120]],
      smoothmult   = [[0.25]],
      smoothexponent = [[0.45]],
      movestructures = [[1]],
      
      light_color = [[1 1.4 0.35]],
      light_radius = 400,
      reaim_time = 1,
    },

    damage                  = {
      default = 851,
      subs    = 42.5,
    },

    edgeEffectiveness       = 0.75,
    explosionGenerator      = [[custom:TESS]],
    fireStarter             = 55,
    flightTime              = 10,
    impulseBoost            = 0,
    impulseFactor           = 0.8,
    interceptedByShieldType = 2,
    model                   = [[wep_m_kickback.s3o]],
    noSelfDamage            = true,
    range                   = 925,
    reloadtime              = 1.533,
    smokeTrail              = false,
    soundHit                = [[weapon/missile/vlaunch_hit]],
    soundStart              = [[weapon/missile/missile_launch]],
    turnrate                = 18000,
    weaponAcceleration      = 245,
    weaponTimer             = 2,
    weaponType              = [[StarburstLauncher]],
    weaponVelocity          = 10000,
  },
  PLASMA_LVLWEP = {
    name                    = [[Long-Range Plasma Battery]],
    areaOfEffect            = 192,
    avoidFeature            = false,
    avoidGround             = true,
    burst                   = 3,
    burstRate               = 0.133,
    craterBoost             = 1,
    craterMult              = 2,

    customParams            = {
      light_color = [[1.4 0.8 0.3]],
    },

    damage                  = {
      default = 601,
      planes  = 601,
      subs    = 30,
    },

    edgeEffectiveness       = 0.5,
    explosionGenerator      = [[custom:330rlexplode]],
    fireStarter             = 120,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    mygravity               = 0.1,
    range                   = 1850,
    reloadtime              = 10,
    soundHit                = [[explosion/ex_large4]],
    soundStart              = [[explosion/ex_large5]],
    sprayangle              = 1024,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 400,
  },
}

for _,wd in pairs(levelWeaponListDefs) do
  wd.customParams = wd.customParams or {}
  wd.customParams.hidden = true
end

return {
  list = lowerKeys(levelWeaponList),
  defs = lowerKeys(levelWeaponListDefs)
}