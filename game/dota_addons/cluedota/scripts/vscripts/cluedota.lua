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


--Starts a new round.
--Resets the board, finds new spawn_positions, stuns all heroes and moves them to new positions, then
-- restarts the game logic.

--technically works. maybe better once the game has been started to do midgame reinit
function startNewRound()
  print("Starting a new round..")
  spawnNewNpcs()
  --shuffle tables
  local table_spawn_new = shuffleTable(table_spawn)
  local table_new_heroes_original_name = shuffleTable(table_all_heroes_original_name)

  -- iterate over all players
  for num,player in pairs(table_players) do
    local playerID = player:GetPlayerID()
    local old_hero = player:GetAssignedHero()

    for i=0,NUM_OF_PLAYERS,1 do
      print("playerID", playerID,"old hero", old_hero:GetUnitName())
      print("*************")
      print("playerID", playerID, "new hero ", table_new_heroes_original_name[1])
      -- make new hero
      local hero = nil
      -- replace their heroes
      PrecacheUnitByNameAsync(table_new_heroes_original_name[playerID+1], function()
        print(playerID,table_new_heroes_original_name[playerID+1])

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
--( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )
-- spawn new npcs
  -- pull random npcs from table_all_npcs
  local new_npcs = shuffleTable(table_all_npcs)
  -- find NPC locations
  local spawn_positions = Entities:FindAllByName("ent_spawn_npc")
  local spawn_positions = shuffleTable(spawn_positions)
  --PrintTable(spawn_positions)
  -- create NPCs
  for i=1,10,1 do
    local current_spawn_pos = spawn_positions[i]:GetAbsOrigin()
    local npc = CreateUnitByName(new_npcs[i], current_spawn_pos, false, nil, nil, -1)
    print(i, "NPC ",npc:GetUnitName()," has spawned at ",current_spawn_pos,".")
  end
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

  --insert all connected players into table
  for id = 0, (MAX_NUMBER_OF_TEAMS) do
    table_players[id] = PlayerResource:GetPlayer(id)

    --if player connects
    if table_players[id] then
      local playerID = table_players[id]:GetPlayerID()
      table_players[id]:MakeRandomHeroSelection()
      --random a hero
      PlayerResource:SetHasRepicked(playerID)
      PlayerResource:SetHasRandomed(playerID)
    else

      --if player hasn't connected
      if PlayerResource:GetConnectionState(id) == 1 then
        table_players[id] = "player_not_connected"
        print("Player "..id.." hasn't connected")
      end
    end
  end



  print("All players have connected:")
  --PrintTable(table_players)
  NUM_OF_PLAYERS = table.getn(table_players)
end




--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]

function cluedota:OnHeroInGame(hero)
  DebugPrint("[CLUEDOTA] Hero spawned in game for first time -- " .. hero:GetUnitName())
  if hero then
    --print("hero:GetAbsOrigin", hero:GetAbsOrigin())
    hero:SetGold(0, false)
    print("test3")


    --add hero to table_current_heroes
    local playerID = hero:GetPlayerOwnerID()
    print("PlayerID of ",hero:GetName()," : ", playerID)
    table_current_heroes[playerID] = hero

    --set hero to a 'random' position
    local new_position = table_spawn[playerID+1]:GetAbsOrigin() --lazy fix because table_spawn starts at 1, yet playerID at 0
    --print("new pos table spawn", new_position)
    --set to new position
    hero:SetAbsOrigin(new_position)
    FindClearSpaceForUnit(hero, new_position, true)

    --remove hp_bar
    local no_hp = hero:FindAbilityByName("no_hp")
    if no_hp then
      no_hp:SetLevel(1)
    end
    --remove skill points
    hero:SetAbilityPoints(0)
  end

end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function cluedota:OnGameInProgress()
  DebugPrint("[CLUEDOTA] The game has officially begun")


    Timers:CreateTimer(5, -- Start this timer 30 game-time seconds later
    function()
        print("Gamelogic has started")
        --start gamelogic
        spawnNewNpcs()
      end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function cluedota:Initcluedota()
  cluedota = self


  DebugPrint('[CLUEDOTA] Starting to load cluedota cluedota...')

  --init Tables
    table_players = {}
    table_current_heroes = {}
    table_spawn = {}
    table_already_occupied_spawn = {}
    table_all_heroes = { "npc_dota_hero_alchemist_cluedota",
    "npc_dota_hero_dragon_knight_cluedota",
    "npc_dota_hero_juggernaut_cluedota",
    "npc_dota_hero_night_stalker_cluedota",
    "npc_dota_hero_pudge_cluedota",
    "npc_dota_hero_riki_cluedota",
    "npc_dota_hero_bounty_hunter_cluedota",
    "npc_dota_hero_lycan_cluedota",
    "npc_dota_hero_brewmaster_cluedota",
    "npc_dota_hero_phantom_assassin_cluedota",
    "npc_dota_hero_rubick_cluedota",
    "npc_dota_hero_phantom_assassin_cluedota",
    "npc_dota_hero_templar_assassin_cluedota",
    "npc_dota_hero_keeper_of_the_light_cluedota",
    "npc_dota_hero_invoker_cluedota",
    }

    table_all_heroes_original_nam = { "npc_dota_hero_alchemist_cluedota",
    "npc_dota_hero_dragon_knight_cluedota",
    "npc_dota_hero_juggernaut_cluedota",
    "npc_dota_hero_night_stalker_cluedota",
    "npc_dota_hero_pudge_cluedota",
    "npc_dota_hero_riki_cluedota",
    "npc_dota_hero_bounty_hunter_cluedota",
    "npc_dota_hero_lycan_cluedota",
    "npc_dota_hero_brewmaster_cluedota",
    "npc_dota_hero_phantom_assassin_cluedota",
    "npc_dota_hero_rubick_cluedota",
    "npc_dota_hero_phantom_assassin_cluedota",
    "npc_dota_hero_templar_assassin_cluedota",
    "npc_dota_hero_keeper_of_the_light_cluedota",
    "npc_dota_hero_invoker_cluedota",
    }

    table_all_heroes_original_name = { "npc_dota_hero_alchemist",
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
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_keeper_of_the_light",
    "npc_dota_hero_invoker",
    }


    table_all_npcs = { "npc_cd_earthshaker",
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

    --create spawn positions
    table_spawn = Entities:FindAllByName("ent_spawn")
    table_spawn = shuffleTable(table_spawn)
    --print("table_spawn")
    --PrintTable(table_spawn)

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/cluedota to see/modify the exact code
  cluedota:_Initcluedota()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "debug_command", Dynamic_Wrap(cluedota, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

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
      startNewRound()
    end
  end

end
