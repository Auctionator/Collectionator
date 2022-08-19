function Collectionator.Utilities.GroupedByID(array, fullScan)
  local results = {}

  for _, info in ipairs(array) do
    local id = fullScan[info.index].replicateInfo[17]
    if results[id] == nil then
      results[id] = {}
    end
    table.insert(results[id], info)
  end

  return results
end
