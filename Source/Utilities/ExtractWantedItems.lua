local function SortByPriceAscending(array, fullScan)
  table.sort(array, function(a, b)
    return fullScan[a.index].replicateInfo[10] < fullScan[b.index].replicateInfo[10]
  end)
end
local function CombineForCheapest(array, fullScan)
  SortByPriceAscending(array, fullScan)

  array[1].quantity = #array
  array[1].allNames = {}
  for index, item in ipairs(array) do
    local name = fullScan[item.index].replicateInfo[1]
    if tIndexOf(array[1].allNames, name) == nil then
      table.insert(array[1].allNames, fullScan[item.index].replicateInfo[1])
    end
  end


  return array[1]
end

function Collectionator.Utilities.ExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result, CombineForCheapest(array, fullScan))
  end

  return result
end
