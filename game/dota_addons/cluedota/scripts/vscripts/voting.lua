function start_voting()

  table_player_votes = {}
  voted_on_killer = 0

  -- find all heroes
  local table_all_entities = Entities:FindAllInSphere(Vector(0,0,0), 10000)
  local table_all_heroes = {}
  for k,v in pairs(table_all_entities) do
    if v.IsHero and v:IsHero() then
      table.insert(table_all_heroes, v)
    end
  end

  -- find all NPCs
  local table_current_npcs = Entities:FindAllByClassname("npc_dota_creature")
  -- remove them
  for num,npc in pairs(table_current_npcs) do
    if npc then
      npc:RemoveSelf()
    end
  end


  -- transport all players to voting place
  for num,hero in pairs(table_all_heroes) do
    local new_position_entity = Entities:FindByName(nil, "vote_place_"..num)
    local new_position = new_position_entity:GetAbsOrigin()
    local new_forward_vector = new_position_entity:GetForwardVector()
    hero:SetAbsOrigin(new_position)

    hero:SetForwardVector(new_forward_vector)
    --root them
    hero:AddNewModifier(target, nil, "modifier_rooted", nil)

    --extend vision
    local vote_position = Entities:FindByName(nil, "vote_vision"):GetAbsOrigin()
    AddFOWViewer(hero:GetTeamNumber(), vote_position, 1500.0, 30, false)
    --remove their skills and give them voting skill
    hero:RemoveAbility("fake_vote")
    hero:RemoveAbility("voting")
    hero:RemoveAbility("melee_kill")
    hero:RemoveAbility("get_hint")

    if hero:GetUnitName() == CURRENT_KILLER then
      hero:AddAbility("fake_vote")
      local voting_ability = hero:FindAbilityByName("fake_vote")
      voting_ability:SetLevel(1)
    else
      hero:AddAbility("voting")
      local voting_ability = hero:FindAbilityByName("voting")
      voting_ability:SetLevel(1)
    end

    --give voting instructions
    --TODO: Panorama junk

  end

  --tally votes after 45 seconds

  Timers:CreateTimer(45, function()

    PrintTable(table_player_votes)

    for playerID,hero in pairs(table_player_votes) do
      -- did this player vote for the killer?
      if table_player_votes[playerID] == CURRENT_KILLER then
        table_player_points[playerID] = table_player_points[playerID] + 1
        voted_on_killer = voted_on_killer + 1
      end
    end

    -- give killer points (1 point for every player that chose wrong)
    local killer_points = #table_players - voted_on_killer
    table_player_points[CURRENT_KILLER_NUMBER] = killer_points

    PrintTable(table_player_points)


    --announce results (panorama score table thing)
    --TODO: Panorama junk
    Timers:CreateTimer(5, function()


      --start new round
      Timers:CreateTimer(10, function()
        startNewRound()
        return nil
      end)
      return nil
    end)

  end)


end
