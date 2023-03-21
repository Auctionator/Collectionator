local function SortByPriceAscending(array, getPrice)
  table.sort(array, function(a, b)
    return getPrice(a) < getPrice(b)
  end)
end
local function CombineForCheapest(array, getName, getPrice)
  SortByPriceAscending(array, getPrice)

  array[1].quantity = #array
  array[1].allNames = {}
  for index, item in ipairs(array) do
    local name = getName(item)
    if tIndexOf(array[1].allNames, name) == nil then
      table.insert(array[1].allNames, name)
    end
  end


  return array[1]
end

function Collectionator.Utilities.ExtractWantedItems(grouped, getName, getPrice)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result, CombineForCheapest(array, getName, getPrice))
  end

  return result
end

function Collectionator.Utilities.ReplicateExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result,
      CombineForCheapest(array,
        function(item)
          return fullScan[item.index].replicateInfo[1]
        end,
        function(item)
          return fullScan[item.index].replicateInfo[10]
        end
      )
    )
  end

  return result
end

function Collectionator.Utilities.SummaryExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result,
      CombineForCheapest(array,
        function(item)
          return item.itemKeyInfo.itemName
        end,
        function(item)
          return fullScan[item.index].minPrice
        end
      )
    )
  end

  return result
end
