CollectionatorPetRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorPetRowMixin:DoSearch()
  -- Use that an Auctionator database key for a pet has the format p:[speciesID]
  local _, petID = strsplit(":", Auctionator.Utilities.ItemKeyFromLink(self.rowData.itemLink))
  local itemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, tonumber(petID))

  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorPetRowMixin:GetSearchResult(itemKey)
  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if info.itemLink == self.rowData.itemLink then
      return info
    end
  end

  return nil
end
