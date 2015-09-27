function shuffleTable(t)
  if t == nil then
    print("Couldn't shuffle as its nil")
    return t
  end
  local newTable = {}
  for i=1, #t do
    table.insert(newTable, math.random(#newTable), t[i])
  end
  return newTable
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
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
