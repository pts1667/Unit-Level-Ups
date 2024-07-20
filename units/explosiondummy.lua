return { explosiondummy = {
    unitname = [[explosiondummy]],
    name = [[Explosion Dummy]],
    description = [[oops]],
    acceleration = 0.0,
    activateWhenBuilt = true,
    brakeRate = 10.0,
    metalCost = 0,
    buildTime = 1,
    buildPic = [[amphaa.png]],
    canGuard = true,
    canMove = true,
    canPatrol = true,
    category = [[FAKEUNIT]],
    selectionVolumeOffsets = [[0 0 0]],
    selectionVolumeScales  = [[0 0 0]],
    selectionVolumeType    = [[ellipsoid]],
  
    customParams = {
      dontCount = [[1]],
    },
  
    explodeAs = [[explosiondummy_DEATH]],
    energyUse = 0,
    levelGround = false,
    idleAutoHeal = 10000,
    health = 100000,
    maxSlope = 60,
    speed = 0,
    minCloakDistance = 10,
    reclaimable = false,
    onoffable = false,
    sightDistance = 0,
    movementClass = [[AKBOT2]],
    moveState = 0,
    objectName = [[dummy.dae]],
    script = [[standarddummy.lua]],
    blocking = false,
    turnRate = 2000,
  
    weapons = {
    },
  
    weaponDefs = {
        explosiondummy_DEATH = {
            areaOfEffect       = 400,
            craterBoost        = 4,
            craterMult         = 5,
            edgeEffectiveness  = 0.3,
            explosionGenerator = "custom:NUKE_150",
            explosionSpeed     = 10000,
            impulseBoost       = 0,
            impulseFactor      = 0.1,
            name               = "Explosion",
            soundHit           = "explosion/mini_nuke",

            customParams       = {
                burst = Shared.BURST_UNRELIABLE,
                lups_explodelife = 3,
            },
            damage = {
                default          = 1000,
            },
        },
    }
  }}