-- doesnt shuffle the first element in t, always puts it at the end
function shuffleTable(t)
  local newTable = {}
  for i=1, #t do
    table.insert(newTable, RandomInt(1,#newTable), t[i])
  end
  return newTable
end


-- figure out why it removes stuff from the original table
-- function shuffleTable2(t)
--   local oldTable = t
--   local newTable = {}
--   local oldLen = #t
--   for i=1, oldLen do
--     local element = RandomInt(1, oldLen)
--     print("element", oldTable[element])
--     table.insert(newTable, oldTable[element])
--     table.remove(oldTable, element)
--   end
--   return newTable
-- end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end



function WalkToRandomPos(unit, npcNumber)
  local unitName = unit:GetUnitName()

  Timers:CreateTimer(RandomFloat(1, 3) , function()
    if unit:IsNull() then
      return nil
    end

    --grab a random position out of all possible ones
    local random_position = table_positions[RandomInt(1, #table_positions)]:GetAbsOrigin()

    -- If someone is at that position, don't move
    if table.contains(table_already_occupied_position, random_position) then
      unit:Hold()
      --print("unit",unitName," is holding position")
    else

      --keep track of position
      table_already_occupied_position[npcNumber] = random_position

      --move unit
      local moveOrder = {
        UnitIndex = unit:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = random_position
      }

      if unit:IsIdle() then
        ExecuteOrderFromTable(moveOrder)
        --print("unit",unitName," is changing position")
      elseif unit:IsIdle() == false then
        --print("Unit", unitName," is currently moving")
      end

    end
    return RandomFloat(15,20)
  end)
end


function rotateTargetToCaster(target, caster)
  --super lazy way, thanks to mayheim

  --root target
  target:AddNewModifier(target, nil, "modifier_rooted", nil)

  local movementOrder = {
    UnitIndex = target:entindex(),
    Ordertype = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    position = caster:GetAbsOrigin()
  }

  local stopOrder = {
    UnitIndex = target:entindex(),
    OrderType = DOTA_UNIT_ORDER_STOP,
  }

  --send movement command to target
  ExecuteOrderFromTable(movementOrder)


  --once the target is looking at the caster, unroot it and stop it
  Timers:CreateTimer(1, function()
    target:RemoveModifierByName("modifier_rooted")
    ExecuteOrderFromTable(stopOrder)
    return nil
  end)
  --then give it a new random movement order
  WalkToRandomPos(target)

end





function createHintBubble(unit, hint)
  Timers:CreateTimer(0.5, function()
    -- speech bubbles have a cap of 4 at the same time
    local duration = 3
    print("hint: ", hint)
    --check for active speech bubbles
    local bubble_index = table.getn(table_bubbles)+1
    --print("bubble_index of current bubble", bubble_index)
    -- too many speech bubbles?
    if bubble_index > 4 then
      --local num = table.getn(table_bubbles)
      print("Too many speech bubbles at the moment : ", bubble_index)
      -- wait until bubbles expire
      Timers:CreateTimer(1,
      function()
        --try again
        createHintBubble(unit, hint)
        return nil
      end)
    else
      --less than 4 table_bubbles active
      -- +1 active bubble
      table.insert(table_bubbles, bubble_index)
      unit:AddSpeechBubble(bubble_index-1, hint, duration, 0, -20)
      local new_bubble_index = bubble_index
      Timers:CreateTimer(3,
      function()
        --print("removing bubble_index", new_bubble_index)
        -- -1 active bubble
        table_bubbles[new_bubble_index] = nil
        --table.remove(table_bubbles, new_bubble_index)
        --PrintTable(table_bubbles)
        return nil
      end)
    end
  end)
end


function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print("t", t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 60 then
        CustomGameEventManager:Send_ServerToAllClients( "timer_alert", broadcast_gametimer )
    end
end


function SetTimer( time )
    print( "Set the timer to: " .. time )
    nCOUNTDOWNTIMER = time
end
