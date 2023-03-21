function Collectionator.Utilities.ColorName(link, name)
  local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(link)
  return "|c" .. qualityColor .. name .. "|r"
end

function Collectionator.Utilities.SummaryColorName(itemKeyInfo)
  return ITEM_QUALITY_COLORS[itemKeyInfo.quality].color:WrapTextInColorCode(itemKeyInfo.itemName)
end
