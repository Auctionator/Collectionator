function Collectionator.Utilities.ColorName(link, name)
  local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(link)
  return "|c" .. qualityColor .. name .. "|r"
end

