CollectionatorTMogRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorTMogRowMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.rowData.itemLink)
  local itemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}

  Auctionator.AH.SendSellSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorTMogRowMixin:GetSearchResult(itemKey)
  return Collectionator.Utilities.GetIdenticalLinkItem(self.rowData.itemLink, itemKey)
end
