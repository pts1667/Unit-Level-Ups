return { standarddummy = {
  unitname = [[standarddummy]],
  name = [[Standard Dummy]],
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
    shieldDummy = [[1]],
    --completely_hidden = 1,
  },

  energyUpkeep = 0,
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
  }
}}