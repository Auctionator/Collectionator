local function SortByPrice(array, fullScan)
  table.sort(array, function(a, b)
    return fullScan[a.index].replicateInfo[10] < fullScan[b.index].replicateInfo[10]
  end)
end
local function CombineForCheapest(array, fullScan)
  SortByPrice(array, fullScan)

  array[1].quantity = #array

  return array[1]
end

function Collectionator.Utilities.ExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result, CombineForCheapest(array, fullScan))
  end

  return result
end
