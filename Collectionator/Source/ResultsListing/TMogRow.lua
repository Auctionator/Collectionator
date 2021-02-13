CollectionatorTMogRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorTMogRowMixin:DoSearch()
  self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  local sorts = Collectionator.Constants.ITEM_SORTS
  local itemID = GetItemInfoInstant(self.rowData.itemLink)

  local itemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}

  Auctionator.AH.SendSellSearchQuery(itemKey, sorts, true)
end

function CollectionatorTMogRowMixin:OnEvent(eventName, itemKey)
  self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if info.itemLink == self.rowData.itemLink then
      Auctionator.EventBus
        :RegisterSource(self, "CollectionatorTMogRowMixin")
        :Fire(self, Collectionator.Events.ShowBuyoutOptions, info, self.rowData)
        :UnregisterSource(self)
      return
    end
  end
  Auctionator.EventBus
    :RegisterSource(self, "CollectionatorTMogRowMixin")
    :Fire(self, Collectionator.Events.ShowBuyoutOptions, nil, self.rowData)
    :UnregisterSource(self)
end
