function Collectionator.Utilities.SortByPrice(array, fullScan)
  table.sort(array, function(a, b)
    return a.price < b.price
  end)
end
