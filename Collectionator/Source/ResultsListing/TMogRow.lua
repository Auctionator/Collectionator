CollectionatorTMogRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorTMogRowMixin:DoSearch()
  local sorts = Collectionator.Constants.ITEM_SORTS
  local itemID = GetItemInfoInstant(self.rowData.itemLink)

  local itemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}

  Auctionator.AH.SendSellSearchQuery(itemKey, sorts, true)
end

function CollectionatorTMogRowMixin:GetSearchResult(itemKey)
  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if info.itemLink == self.rowData.itemLink then
      return info
    end
  end

  return nil
end
