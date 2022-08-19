function Collectionator.Utilities.GetRealmAndFaction()
  local realm = Auctionator.Variables.GetConnectedRealmRoot()
  local faction = UnitFactionGroup("player")

  return realm .. "_" .. faction
end
