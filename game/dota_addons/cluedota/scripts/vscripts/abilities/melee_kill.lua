function melee_kill(event)
  --PrintTable(event)
  local target = event.target
  local caster = event.caster

  local table_toBeKilled = table_npc_values[NPC_TO_BE_KILLED]


  if target:GetUnitName() == NPC_TO_BE_KILLED then



    --particles
    local blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf", PATTACH_ABSORIGIN, target)
    local blood_position = target:GetAbsOrigin()
    local blood_direction_forward = target:GetForwardVector()

    ParticleManager:SetParticleControl(blood_particle, 0, blood_position)
    ParticleManager:SetParticleControlForward(blood_particle, 1, blood_direction_forward)
    ParticleManager:SetParticleControl(blood_particle, 1, blood_position)
    print("NPC_TO_BE_KILLED", NPC_TO_BE_KILLED, "has been killed by ", caster:GetUnitName())


    -- sound
    local death_sound_num = RandomInt(1,9)

    EmitGlobalSound(table_toBeKilled[1].."_0"..death_sound_num)
    EmitGlobalSound("ui.npe_badge")

    --logic
    MAIN_NPC_HAS_BEEN_KILLED = true

    --figure out a way to keep corpse around
    target:ForceKill(true)


  else
    --fix NPC name
    GameRules:SendCustomMessageToTeam("<font color='#ff3e3e'>Don't go around killing innocent people!</font><br> Your target is:<font color='#3379fa'> "..table_toBeKilled[3].."</font>", caster:GetTeamNumber(), 0,0)
  end
end
