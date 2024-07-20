return { shielddummylarge = {
  unitname = [[shielddummylarge]],
  name = [[Shield Dummy (large)]],
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
  selectionVolumeOffsets = [[0 2000 0]],
  selectionVolumeScales  = [[0 0 0]],
  selectionVolumeType    = [[ellipsoid]],

  customParams = {
    dontCount = [[1]],
    shieldDummy = [[1]],
    unarmed = true,
    completely_hidden = 1,
  },

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
  script = [[shielddummylarge.lua]],
  blocking = false,
  collisionVolumeOffsets = { 0.0, 2000.0, 0.0 },

  weapons = {
    {
      def = [[DUMMY_SHIELD_LARGE]]
    }
  },

  weaponDefs = {
    DUMMY_SHIELD_LARGE = {
      name = [[Dummy Shield (large)]],
      damage = {
        default = 10
      },
      customParams = {
        unlinked = true
      },
      exteriorShield = true,
      shieldAlpha = 0.2,
      shieldBadColor = [[1 0.1 0.1 1]],
      shieldGoodColor = [[0.1 0.1 1 1]],
      shieldInterceptType = 3,
      shieldPower = 100,
      shieldPowerRegen = 0,
      shieldPowerRegenEnergy = 0,
      shieldRadius = 600,
      shieldRepulser = false,
      shieldStartingPower = 500,
      smartShield = true,
      visibleShield = false,
      visibleShieldRepulse = false,
      weaponType = [[Shield]]
    }
  }
}}