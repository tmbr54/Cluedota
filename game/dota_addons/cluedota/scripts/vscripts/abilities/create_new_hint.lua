function createNewHint(event)

  -- Oh my god, what a mess ...


  local target = event.target
  local caster = event.caster

  --Get target to face caster
  rotateTargetToCaster(target, caster)



  local npc_name = target:GetUnitName()
  local caster_name = caster:GetUnitName()
  print("Target name", npc_name)
  print("Caster name", caster_name)


  --get a random hint according to current state
  --nothing has happened yet:
  if MAIN_NPC_HAS_BEEN_KILLED == false then


    local hint_table = _G["table_" .. npc_name .. "_trivia"]
    print("Pulling hint from trivia table")
    local hint_num = RandomInt(1,#hint_table)
    local hint = hint_table[hint_num]

    createHintBubble(target, hint)
  end





  -- NPC has been killed

  if MAIN_NPC_HAS_BEEN_KILLED == true then
    if SUSPICIOUS_ACTIVITY == true then -- TODO: add check to see if the target is the same as
      -- the npc who raised the SUSPICIOUS_ACTIVITY call
      print("Pulling hint from hero table (SUSPICIOUS_ACTIVITY is ON)", CURRENT_KILLER)
      local odds = RandomInt(0,100)
      if odds >= 20 then
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_positive"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      elseif odds < 20 and odds > 5 then
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_neutral"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      else
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_negative"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      end
      --HERO table or NPC table?
    elseif RandomInt(0,100) <= 20 then
      --NPC table
      print("Pulling hint from NPC table", npc_name)
      local odds = RandomInt(0,100)
      if odds >= 70 then
        local hint_table = _G["table_" .. npc_name .. "_positive"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      elseif odds < 70 and odds > 20 then
        local hint_table = _G["table_" .. npc_name .. "_neutral"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      elseif odds < 20 and odds > 10 then
        local hint_table = _G["table_" .. npc_name .. "_trivia"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      else
        local hint_table = _G["table_" .. npc_name .. "_negative"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      end
    else
      --HERO Table
      print("Pulling hint from hero table", CURRENT_KILLER)

      local odds = RandomInt(0,100)
      if odds >= 50 then
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_positive"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      elseif odds < 50 and odds > 10 then
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_neutral"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      else
        local hint_table = _G["table_" .. CURRENT_KILLER .. "_negative"]
        local hint_num = RandomInt(1,#hint_table)
        local hint = hint_table[hint_num]

        createHintBubble(target, hint)
      end
    end
  end
end
