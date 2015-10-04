-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('cluedota')
require('functions')
require('libraries/animations')



require('hints/npc/earthshaker_hints')
require('hints/npc/kunkka_hints')
require('hints/npc/beastmaster_hints')
require('hints/npc/omni_hints')
require('hints/npc/spirit_breaker_hints')
require('hints/npc/tusk_hints')
require('hints/npc/legion_hints')
require('hints/npc/anti_mage_hints')
require('hints/npc/mirana_hints')
require('hints/npc/sniper_hints')
require('hints/npc/ursa_hints')
require('hints/npc/naga_hints')
require('hints/npc/maiden_hints')
require('hints/npc/windrunner_hints')
require('hints/npc/lina_hints')
require('hints/npc/dazzle_hints')
require('hints/npc/skywrath_hints')
require('hints/npc/ogremagi_hints')
require('hints/npc/meepo_hints')

require('hints/hero/alchemist_hints')
require('hints/hero/dragon_knight_hints')
require('hints/hero/juggernaut_hints')
require('hints/hero/night_stalker_hints')
require('hints/hero/pudge_hints')
require('hints/hero/riki_hints')
require('hints/hero/bounty_hunter_hints')
require('hints/hero/lycan_hints')
require('hints/hero/brewmaster_hints')
require('hints/hero/phantom_assassin_hints')
require('hints/hero/rubick_hints')
require('hints/hero/templar_assassin_hints')
require('hints/hero/keeper_of_the_light_hints')
require('hints/hero/warlock_hints')


function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See cluedota:PostLoadPrecache() in cluedota.lua for more information
  ]]

  DebugPrint("[CLUEDOTA] Performing pre-load precache")


  --Precache NPCs
  PrecacheUnitByNameSync("npc_cd_earthshaker", context)
  PrecacheUnitByNameSync("npc_cd_kunkka", context)
  PrecacheUnitByNameSync("npc_cd_beastmaster", context)
  PrecacheUnitByNameSync("npc_cd_omni", context)
  PrecacheUnitByNameSync("npc_cd_spirit_breaker", context)
  PrecacheUnitByNameSync("npc_cd_tusk", context)
  PrecacheUnitByNameSync("npc_cd_legion", context)
  PrecacheUnitByNameSync("npc_cd_anti_mage", context)
  PrecacheUnitByNameSync("npc_cd_mirana", context)
  PrecacheUnitByNameSync("npc_cd_sniper", context)
  PrecacheUnitByNameSync("npc_cd_ursa", context)
  PrecacheUnitByNameSync("npc_cd_naga", context)
  PrecacheUnitByNameSync("npc_cd_maiden", context)
  PrecacheUnitByNameSync("npc_cd_windrunner", context)
  PrecacheUnitByNameSync("npc_cd_lina", context)
  PrecacheUnitByNameSync("npc_cd_dazzle", context)
  PrecacheUnitByNameSync("npc_cd_skywrath", context)
  PrecacheUnitByNameSync("npc_cd_ogremagi", context)
  PrecacheUnitByNameSync("npc_cd_meepo", context)


  PrecacheResource(particle, "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf", context)


  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed



  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models

end

-- Create the game mode when we activate
function Activate()
  GameRules.cluedota = cluedota()
  GameRules.cluedota:Initcluedota()
end
