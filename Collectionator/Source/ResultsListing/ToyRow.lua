CollectionatorToyRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorToyRowMixin:DoSearch()
  self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  local itemID = GetItemInfoInstant(self.rowData.itemLink)

  local itemKey = C_AuctionHouse.MakeItemKey(itemID)

  self.expectedItemID = itemID
  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorToyRowMixin:OnEvent(eventName, itemKey)
  self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if GetItemInfoInstant(info.itemLink) == self.expectedItemID then
      Auctionator.EventBus
        :RegisterSource(self, "CollectionatorToyRowMixin")
        :Fire(self, Collectionator.Events.ShowBuyoutOptions, info, self.rowData)
        :UnregisterSource(self)
      return
    end
  end
  Auctionator.EventBus
    :RegisterSource(self, "CollectionatorToyRowMixin")
    :Fire(self, Collectionator.Events.ShowBuyoutOptions, nil, self.rowData)
    :UnregisterSource(self)
end
