CollectionatorMountRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorMountRowMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.rowData.itemLink)
  local itemKey = C_AuctionHouse.MakeItemKey(itemID)

  self.expectedItemID = itemID
  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorMountRowMixin:GetSearchResult(itemKey)
  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if GetItemInfoInstant(info.itemLink) == self.expectedItemID then
      return info
    end
  end

  return nil
end
