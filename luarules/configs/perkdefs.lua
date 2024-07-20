local perkDefs = {
  fireKing = {
    name = "Fire King",
    id = 1,
    description = "Fire damage heals you",
    icon = "perk_fireking.png",
    affectsDrones = true
  },
  flamePop = {
    name = "Flame Pop",
    id = 2,
    description = "When you or your drones hit a unit with fire, it flares to nearby units for 3 seconds",
    icon = "perk_flamepop.png",
    affectsDrones = true,
    prerequisites = { "fireKing" },
  },
  slowAndSteady = {
    name = "Slow & Steady",
    id = 3,
    description = "When you haven't dealt damage for 5 seconds, get a 250% damage increase to your next shot",
    icon = "perk_slowandsteady.png"
  },
  burstFire = {
    name = "Cluster Fire",
    id = 4,
    description = "When you hit a target, the shot spreads and ricochets to upto 3 other nearby targets",
    icon = "perk_burstfire.png",
    prerequisites = { "slowAndSteady" }
  },
  clusterRange = {
    name = "Cluster Range",
    id = 10,
    description = "Level range bonus is also applied to cluster projectile range. This does not include perks such as Glass Cannon",
    icon = "perk_clusterrange.png",
    prerequisites = { "burstFire" }
  },
  glassCannon = {
    name = "Glass Cannon",
    id = 5,
    description = "+100% damage and +50% range (+100% radar), but max HP set to 10",
    icon = "perk_glasscannon.png",
    prerequisites = { "slowAndSteady" },
    noAutoPick = true
  },
  fastAndHeavy = {
    name = "Fast & Heavy",
    id = 6,
    description = "Every time you damage an enemy, you get 3% additional fire speed for 5 seconds. Stacks to 99%",
    icon = "perk_fastandheavy.png"
  },
  evenFaster = {
    name = "Even Faster",
    id = 7,
    description = "Fire rate +100%, but you only deal 40% damage",
    icon = "perk_fastandheavy.png",
    prerequisites = { "fastAndHeavy" }
  },
  moreDrones = {
    name = "Drones",
    id = 8,
    description = "Every 5 levels, you gain a miniature 'drone' version of yourself. You cannot command them directly but they will guard you",
    icon = "perk_moredrones.png"
  },
  droneLove = {
    name = "Drone Love",
    id = 9,
    description = "Drones no longer take damage; instead, the damage is passed along to you",
    icon = "perk_dronelove.png",
    affectsDrones = true,
    prerequisites = { "moreDrones" }
  },
  ouch = {
    name = "Ouch",
    id = 10,
    description = "Friendly fire between you and your drones is disabled",
    icon = "perk_ouch.png",
    affectsDrones = true,
    prerequisites = { "moreDrones" }
  },
  shield = {
    name = "Shield",
    id = 13,
    description = "You gain a small shield",
    icon = "perk_shield.png"
  },
  bigshield = {
    name = "Big Shield",
    id = 14,
    description = "Your shield grows larger",
    icon = "perk_biggershield.png",
    prerequisites = { "shield" }
  },
  droneshield = {
    name = "Drone Shield",
    id = 15,
    description = "Your drones have their own shield",
    icon = "perk_droneshield.png",
    prerequisites = { "shield" },
    affectsDrones = true
  },
  projShield = {
    name = "Come On Now",
    id = 16,
    description = "Your projectiles have their own shields",
    icon = "perk_projshield.png",
    prerequisites = { "shield" }
  },
  projWeapon = {
    name = "Spread",
    id = 17,
    description = "Your projectiles shoot other projectiles. Does not work with laser weapons.",
    icon = "perk_targetedspread.png",
    prerequisites = { "fastAndHeavy" }
  },
  badLoser = {
    name = "Bad Loser",
    id = 12,
    description = "Unit explodes on death, or the explosion becomes much bigger. Scales with max HP. Does not work with self-destruct",
    icon = "perk_badloser.png",
    activateLast = true
  },
  iQuit = {
    name = "I Quit",
    id = 18,
    description = "Every time you take damage your death explosion becomes 1% bigger (additive). You can no longer repair and attacking removes stacks",
    icon = "perk_iquit.png",
    prerequisites = { "badLoser" }
  },
  electroDrones = {
    name = "Electro Drones",
    id = 19,
    description = "Drone damage +300% and converted entirely into EMP damage",
    icon = "perk_electrodrones.png",
    prerequisites = { "moreDrones" },
    affectsDrones = true,
    activateLast = true
  }
}

local perkIDTable = {}
for perkName,perk in pairs(perkDefs) do
  perkIDTable[perk.id] = perkName
end

return perkDefs, perkIDTable