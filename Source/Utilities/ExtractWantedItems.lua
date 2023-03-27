local function SortByPriceAscending(array, getPrice)
  table.sort(array, function(a, b)
    return getPrice(a) < getPrice(b)
  end)
end

local function ReplicateCombineForCheapest(array, fullScan)
  SortByPriceAscending(array, function(item)
    return fullScan[item.index].replicateInfo[10]
  end)

  array[1].quantity = #array
  array[1].allNames = {}
  for index, item in ipairs(array) do
    local name = fullScan[item.index].replicateInfo[1]
    if tIndexOf(array[1].allNames, name) == nil then
      table.insert(array[1].allNames, name)
    end
  end


  return array[1]
end

function Collectionator.Utilities.ReplicateExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result, ReplicateCombineForCheapest(array, fullScan))
  end

  return result
end

local function SummaryAddQuantities(array, fullScan)
  local total = 0
  for _, r in ipairs(array) do
    total = total + fullScan[r.index].totalQuantity
  end
  return total
end

local function SummaryCombineForCheapest(array, fullScan)
  SortByPriceAscending(array, function(item)
    return fullScan[item.index].minPrice
  end)

  array[1].quantity = SummaryAddQuantities(array, fullScan)
  array[1].allNames = {}
  for index, item in ipairs(array) do
    local name = item.itemKeyInfo.itemName
    if tIndexOf(array[1].allNames, name) == nil then
      table.insert(array[1].allNames, name)
    end
  end


  return array[1]
end

function Collectionator.Utilities.SummaryExtractWantedItems(grouped, fullScan)
  local result = {}

  for _, array in pairs(grouped) do
    table.insert(result, SummaryCombineForCheapest(array, fullScan))
  end

  return result
end
