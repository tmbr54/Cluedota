function addVotePoint(events)
  local caster = events.caster
  local target = events.target
  local playerID = caster:GetPlayerID()

  table_player_votes[playerID] = target:GetUnitName()


  GameRules:SendCustomMessageToTeam("You voted for <font color='#7e9efc'>"..table_hero_names[target:GetUnitName()].."</font> as the suspect.", caster:GetTeamNumber(), 0,0)


end
