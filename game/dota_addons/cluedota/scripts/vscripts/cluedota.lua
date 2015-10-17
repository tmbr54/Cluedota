-- This is the primary cluedota cluedota script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by cluedota
-- You can also change the cvar 'cluedota_spew' at any time to 1 or 0 for output/no output
CLUEDOTA_DEBUG_SPEW = false

if cluedota == nil then
    DebugPrint( '[CLUEDOTA] creating cluedota game mode' )
    _G.cluedota = class({})


end







-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')

-- These internal libraries set up cluedota's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/cluedota')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core cluedota files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core cluedota files.
require('events')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability#
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function cluedota:PostLoadPrecache()
  DebugPrint("[CLUEDOTA] Performing Post-Load precache")
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--logic for a game round
function roundLogic()
  print("initialized round logic")
  --timer inits
  CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
  Timers:CreateTimer(0, function()
    CountdownTimer()

    print("Current time left:", nCOUNTDOWNTIMER)

    -- round starts
    -- timer runs out
    if nCOUNTDOWNTIMER <= 0 then
      print("Round over")
      if GAME_ROUND_OVER == false then
        if MAIN_NPC_HAS_BEEN_KILLED == false then
          KILLER_LOST = true
          GAME_ROUND_OVER = true
          -- display a message stating killer has lost
          print("killer failed to assassinate his target in 5 minutes, he loses")
          -- handle points for killer and everyone else (killer 0 points, everyone 1 point)
          -- start new round
          startNewRound()
        elseif MAIN_NPC_HAS_BEEN_KILLED == true then
          print("main npc has been killed")
          print("going to voting screen now ..")
          GAME_ROUND_OVER = true
          start_voting()
        end

        return nil
      end
    end
    return 1
  end)
end

--Starts a new round.
function startNewRound()
  nCOUNTDOWNTIMER = ROUND_TIME
  roundLogic()
  GAME_ROUND_OVER = false
  print("Starting a new round..")

  --inits
  local NUM_OF_PLAYERS = #table_players
  table_bubbles = {}
  spawnNewNpcs()
  CURRENT_KILLER_NUMBER = RandomInt(0,NUM_OF_PLAYERS)
  print("CURRENT_KILLER_NUMBER", CURRENT_KILLER_NUMBER)
  MAIN_NPC_HAS_BEEN_KILLED = false


  --shuffle tables
  local table_spawn_new = shuffleTable(table_spawn)
  local table_new_heroes_original_name = shuffleTable(table_all_heroes_original_name)
  --PrintTable(table_new_heroes_original_name)


  -- iterate over all players
  for num,player in pairs(table_players) do
    local playerID = player:GetPlayerID()
    local old_hero = player:GetAssignedHero()
    print("*************")
    print("playerID", playerID,"old hero", old_hero:GetUnitName())
    print("playerID", playerID, "new hero ", table_new_heroes_original_name[playerID+1])
    print("*************")
    -- make new hero
    local hero = nil
    -- replace their heroes
    PrecacheUnitByNameAsync(table_new_heroes_original_name[playerID+1], function()
      PlayerResource:ReplaceHeroWith(playerID,table_new_heroes_original_name[playerID+1], 0, 0)
      -- remove the zombie hero
      old_hero:RemoveSelf()
      --get new hero assignment
      local hero = player:GetAssignedHero()

      --set to new position
      new_position = table_spawn_new[playerID+1]:GetAbsOrigin()
      hero:SetAbsOrigin(new_position)
      FindClearSpaceForUnit(hero, new_position, false)
    end, playerID)

  end
end


function spawnNewNpcs()
print("*************************************************************************")
-- cleanup
  -- find all current npcs (creates a new table)
  local table_current_npcs = Entities:FindAllByClassname("npc_dota_creature")
  -- remove them
  for num,npc in pairs(table_current_npcs) do
    if npc then
      npc:RemoveSelf()
    end
  end

  -- spawn new npcs
  -- pull random npcs from table_all_npcs
  local new_npcs = shuffleTable(table_all_npcs)
  -- find NPC locations
  local spawn_positions = Entities:FindAllByName("ent_spawn_npc")
  local spawn_positions = shuffleTable(spawn_positions)
  --PrintTable(spawn_positions)
  -- generate killers target
  local to_be_killed = RandomInt(1,MAX_NUM_OF_NPCS)
  -- create NPCs


  for i=1,MAX_NUM_OF_NPCS,1 do
    local current_spawn_pos = spawn_positions[i]:GetAbsOrigin()
    local npc = CreateUnitByName(new_npcs[i], current_spawn_pos, false, nil, nil, -1)
    print(i, "NPC ",npc:GetUnitName()," has spawned at ",current_spawn_pos,".")
    if i == to_be_killed then
      NPC_TO_BE_KILLED = npc:GetUnitName()
    end
    WalkToRandomPos(npc, i)

  end
  print("NPC to be killed:", NPC_TO_BE_KILLED )

print("*************************************************************************")

end



--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in Initcluedota() but needs to be done before everyone loads in.
]]
function cluedota:OnFirstPlayerLoaded()
  DebugPrint("[CLUEDOTA] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function cluedota:OnAllPlayersLoaded()
  DebugPrint("[CLUEDOTA] All Players have loaded into the game")

  --insert all possible players into table
  for id = 0, (MAX_NUMBER_OF_TEAMS) do
    table_players[id] = PlayerResource:GetPlayer(id)

    --if player is valid
    if table_players[id] then
      local playerID = table_players[id]:GetPlayerID()
      print("Added player", playerID, "to table_players")
      table_players[id]:MakeRandomHeroSelection()
      --random a hero
      PlayerResource:SetHasRepicked(playerID)
      PlayerResource:SetHasRandomed(playerID)
    else
      --if player doesnt exist
      if PlayerResource:GetConnectionState(id) == 1 then
        table_players[id] = "player_not_connected"
        print("Player "..id.." hasn't connected")
      end
    end
  end



  print("All players have connected:")
  -- PrintTable(table_players)
  print("Number of Players:", #table_players)
  local NUM_OF_PLAYERS = #table_players

  -- get killer
  CURRENT_KILLER_NUMBER = RandomInt(0,NUM_OF_PLAYERS)
  print("Current Killer playerID:", CURRENT_KILLER_NUMBER)

end




--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
  ]]

function cluedota:OnHeroInGame(hero)
  DebugPrint("[CLUEDOTA] Hero spawned in game for first time -- " .. hero:GetUnitName())

  --print("hero:GetAbsOrigin", hero:GetAbsOrigin())
  hero:SetGold(0, false)




  --add hero to table_current_heroes
  local playerID = hero:GetPlayerOwnerID()
  print("PlayerID of ",hero:GetName()," : ", playerID)
  table_current_heroes[playerID] = hero

  local player = PlayerResource:GetPlayer(playerID)

  --set hero to a 'random' position
  local new_position = table_spawn[playerID+1]:GetAbsOrigin() --lazy fix because table_spawn starts at 1, yet playerID at 0
  --print("new pos table spawn", new_position)
  --set to new position
  hero:SetAbsOrigin(new_position)
  FindClearSpaceForUnit(hero, new_position, true)

  --Is this hero the killer?
  if playerID == CURRENT_KILLER_NUMBER then
    CURRENT_KILLER = hero:GetUnitName()
    print("Killer found! CURRENT KILLER : ", CURRENT_KILLER)
    --give him the melee kill ability
    hero:RemoveAbility("get_hint")
    hero:AddAbility("melee_kill")
    local melee_kill = hero:FindAbilityByName("melee_kill")
    melee_kill:SetLevel(1)
    --Tell the player what his role is
    --panorama stuff
  else

    -- panorama stuff
  end

  -- force selection
  --PlayerResource:SetOverrideSelectionEntity(playerID, hero) TODO UNCOMMENT THIS


  --remove hp_bar
  local no_hp = hero:FindAbilityByName("no_hp")
  if no_hp then
    no_hp:SetLevel(1)
  end

  local get_hint = hero:FindAbilityByName("get_hint")
  if get_hint then
    get_hint:SetLevel(1)
  end
  --remove skill points
  hero:SetAbilityPoints(0)

end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function cluedota:OnGameInProgress()
  DebugPrint("[CLUEDOTA] The game has officially begun")
  spawnNewNpcs()
  roundLogic()



end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function cluedota:Initcluedota()
  cluedota = self


  DebugPrint('[CLUEDOTA] Starting to load cluedota...')
  --init global values
  MAIN_NPC_HAS_BEEN_KILLED = false
  MAX_NUM_OF_NPCS = 10
  ROUND_TIME = 60
  nCOUNTDOWNTIMER = ROUND_TIME
  GAME_ROUND_OVER = false


  --init Tables
    table_has_seen_killer = {}
    table_bubbles = {}
    table_players = {}
    table_current_heroes = {}

    table_already_occupied_position = {}

    table_player_points = {
      [0] = 0,
      [1] = 0,
      [2] = 0,
      [3] = 0,
      [4] = 0,
      [5] = 0,

  }
    table_npc_values = {
    ["npc_cd_earthshaker"] = {"earthshaker_erth_death", 0, "Hermit" },
    ["npc_cd_kunkka"] = {"kunkka_kunk_death", 0, "Admiral" },
    ["npc_cd_beastmaster"] = {"beastmaster_beas_death", 0, "Barbarian"  },
    ["npc_cd_omni"] = {"omniknight_omni_death", 0, "Paladin" },
    ["npc_cd_spirit_breaker"] = {"spirit_breaker_spir_death", 0, "Bull" },
    ["npc_cd_tusk"] = {"tusk_tusk_death", 0, "Drunkard" },
    ["npc_cd_legion"] = {"legion_commander_legcom_death", 0, "Commander" },
    ["npc_cd_anti_mage"] = {"anti_mage_anti_death", 0, "Monk" },
    ["npc_cd_mirana"] = {"mirana_mir_death", 0, "Huntress" },
    ["npc_cd_sniper"] = {"sniper_snip_death", 0, "Hunter" },
    ["npc_cd_ursa"] = {"ursa_ursa_death", 0, "Bear" },
    ["npc_cd_maiden"] = {"crystalmaiden_cm_death", 0, "Maiden" },
    ["npc_cd_windrunner"] = {"windrunner_wind_death", 0, "Ranger" },
    ["npc_cd_lina"] = {"lina_lina_death", 0, "Sorceress" },
    ["npc_cd_dazzle"] = {"dazzle_dazz_death", 0, "Shaman" },
    ["npc_cd_ogremagi"] = {"ogre_magi_ogmag_death", 0, "Ogre" },
    ["npc_cd_skywrath"] = {"skywrath_mage_drag_death", 0, "Sky Mage" },
    ["npc_cd_meepo"] = {"meepo_meepo_death", 0, "Bum" },
    ["npc_cd_enchantress"] = {"enchantress_ench_death_01", 0, "Dryad" },
  }



    --ghetto solution to fixing shuffle: first hero is 2x in table. dont do this.
    table_all_heroes_original_name = {
    "npc_dota_hero_alchemist",
    "npc_dota_hero_alchemist",
    "npc_dota_hero_dragon_knight",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_night_stalker",
    "npc_dota_hero_pudge",
    "npc_dota_hero_riki",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_lycan",
    "npc_dota_hero_brewmaster",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_rubick",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_keeper_of_the_light",
    "npc_dota_hero_warlock",
    }

    table_hero_names = {
    ["npc_dota_hero_alchemist"] = "Alchemist",
    ["npc_dota_hero_alchemist"] = "Alchemist",
    ["npc_dota_hero_dragon_knight"] = "Dragon Knight",
    ["npc_dota_hero_juggernaut"] = "Juggernaut",
    ["npc_dota_hero_night_stalker"] = "Night Stalker",
    ["npc_dota_hero_pudge"] = "Pudge",
    ["npc_dota_hero_riki"] = "Riki",
    ["npc_dota_hero_bounty_hunter"] = "Bounty Hunter",
    ["npc_dota_hero_lycan"] = "Lycanthrope",
    ["npc_dota_hero_brewmaster"] = "Brewmaster",
    ["npc_dota_hero_phantom_assassin"] = "Phantom Assassin",
    ["npc_dota_hero_rubick"] = "Rubick",
    ["npc_dota_hero_templar_assassin"] = "Templar Assassin",
    ["npc_dota_hero_keeper_of_the_light"] = "Keeper of the Light",
    ["npc_dota_hero_warlock"] = "Warlock",
    }


    table_all_npcs = {"empty",
       "npc_cd_earthshaker",
    "npc_cd_kunkka",
    "npc_cd_beastmaster",
    "npc_cd_omni",
    "npc_cd_spirit_breaker",
    "npc_cd_tusk",
    "npc_cd_legion",
    "npc_cd_anti_mage",
    "npc_cd_mirana",
    "npc_cd_sniper",
    "npc_cd_ursa",
    "npc_cd_maiden",
    "npc_cd_windrunner",
    "npc_cd_lina",
    "npc_cd_dazzle",
    "npc_cd_ogremagi",
    "npc_cd_skywrath",
    "npc_cd_meepo",
    }

    --find spawn positions
    table_spawn = Entities:FindAllByName("ent_spawn")
    table_spawn = shuffleTable(table_spawn)
    --find random movement positions
    table_positions = Entities:FindAllByName("random_walk_point")
    --table_already_occupied_spawn = table_positions


  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/cluedota to see/modify the exact code
  cluedota:_Initcluedota()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "debug_command", Dynamic_Wrap(cluedota, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand( "debug_timer", function(...) return SetTimer( ... ) end, "Set the timer.", FCVAR_CHEAT )
  ListenToGameEvent("player_connect_full", Dynamic_Wrap(cluedota, "OnPlayerLoaded"), self)

  DebugPrint('[CLUEDOTA] Done loading cluedota cluedota!\n\n')
end

function cluedota:OnPlayerLoaded(keys)

end

-- This is an example console command
function cluedota:ExampleConsoleCommand()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
        --SUSPICIOUS_ACTIVITY = true
        --PrintTable(table_bubbles)
        --startNewRound()
        --print(CURRENT_KILLER)
        SetTimer(10)
        CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )





    end
  end

end
