CollectionatorPetRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorPetRowMixin:StartSearch()
  -- Use that an Auctionator database key for a pet has the format p:[speciesID]
  local _, petID = strsplit(":", Auctionator.Utilities.ItemKeyFromLink(self.rowData.itemLink))
  local itemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, tonumber(petID))

  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorPetRowMixin:GetSearchResult(itemKey)
  return Collectionator.Utilities.GetIdenticalLinkItem(self.rowData.itemLink, itemKey)
end
