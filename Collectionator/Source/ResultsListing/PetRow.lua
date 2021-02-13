CollectionatorPetRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorPetRowMixin:DoSearch()
  self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  local sorts = Collectionator.Constants.ITEM_SORTS
  -- Use that an Auctionator database key for a pet has the format p:[speciesID]
  local _, petID = strsplit(":", Auctionator.Utilities.ItemKeyFromLink(self.rowData.itemLink))

  local itemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, tonumber(petID))

  Auctionator.AH.SendSearchQuery(itemKey, sorts, true)
end

function CollectionatorPetRowMixin:OnEvent(eventName, itemKey)
  self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if info.itemLink == self.rowData.itemLink then
      Auctionator.EventBus
        :RegisterSource(self, "CollectionatorPetRowMixin")
        :Fire(self, Collectionator.Events.ShowBuyoutOptions, info, self.rowData)
        :UnregisterSource(self)
      return
    end
  end
  Auctionator.EventBus
    :RegisterSource(self, "CollectionatorPetRowMixin")
    :Fire(self, Collectionator.Events.ShowBuyoutOptions, nil, self.rowData)
    :UnregisterSource(self)
end
