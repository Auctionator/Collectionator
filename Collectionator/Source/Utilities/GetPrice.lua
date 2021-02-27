function Collectionator.Utilities.GetPrice(replicateInfo)
  if replicateInfo[10] == 0 then
    return math.max(replicateInfo[11], replicateInfo[8])
  else
    return replicateInfo[10]
end
