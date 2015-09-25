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
