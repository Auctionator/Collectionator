CollectionatorSummaryBuyProcessorMixin = {}

function CollectionatorSummaryBuyProcessorMixin:Init(itemKey, itemKeyInfo)
  self.itemKey = itemKey
  self.itemKeyInfo = itemKeyInfo
end

function CollectionatorSummaryBuyProcessorMixin:Send()
  error("override")
end

function CollectionatorSummaryBuyProcessorMixin:IsReady()
  error("override")
end

function CollectionatorSummaryBuyProcessorMixin:GetSearchResult(itemKey)
  error("override")
end

local function GetSameItemID(itemID, itemKey)
  if itemID == itemKey.itemID then
    return C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
  end
end

CollectionatorSummaryBuyProcessorTMogMixin = CreateFromMixins(CollectionatorSummaryBuyProcessorMixin)

function CollectionatorSummaryBuyProcessorTMogMixin:IsReady()
  return C_AuctionHouse.GetItemKeyInfo(self.itemKey) ~= nil
end

function CollectionatorSummaryBuyProcessorTMogMixin:Send()
  Auctionator.AH.SendSearchQueryByItemKey(self.itemKey, Collectionator.Constants.ITEM_SORTS, false)
end

function CollectionatorSummaryBuyProcessorTMogMixin:GetSearchResult(itemKey)
  local targetSource
  if self.itemKeyInfo.appearanceLink ~= nil then
    targetSource = tonumber(self.itemKeyInfo.appearanceLink:match("transmogappearance:(%d+)"))
  else
    targetSource = select(2, C_TransmogCollection.GetItemInfo(self.itemKey.itemID))
  end

  for i = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, i)
    local source = select(2, C_TransmogCollection.GetItemInfo(result.itemLink))
    if source == targetSource then
      return result
    end
  end
end

function CollectionatorSummaryBuyProcessorTMogMixin:IsExpectedItemKey(itemKey)
  return Auctionator.Utilities.ItemKeyString(self.itemKey) == Auctionator.Utilities.ItemKeyString(itemKey)
end

CollectionatorSummaryBuyProcessorPetMixin = CreateFromMixins(CollectionatorSummaryBuyProcessorMixin)

function CollectionatorSummaryBuyProcessorPetMixin:IsReady()
  return C_AuctionHouse.GetItemKeyInfo(self.itemKey) ~= nil
end

function CollectionatorSummaryBuyProcessorPetMixin:Send()
  Auctionator.AH.SendSearchQueryByItemKey(self.itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorSummaryBuyProcessorPetMixin:GetSearchResult(itemKey)
  return C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
end

function CollectionatorSummaryBuyProcessorPetMixin:IsExpectedItemKey(itemKey)
  return Auctionator.Utilities.ItemKeyString(self.itemKey) == Auctionator.Utilities.ItemKeyString(itemKey)
end

CollectionatorSummaryBuyProcessorOtherMixin = CreateFromMixins(CollectionatorSummaryBuyProcessorMixin)

function CollectionatorSummaryBuyProcessorOtherMixin:Send()
  Auctionator.AH.SendSearchQueryByItemKey(self.itemKey, Collectionator.Constants.ITEM_SORTS, false)
end

function CollectionatorSummaryBuyProcessorOtherMixin:GetSearchResult(itemKey)
  return C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
end

function CollectionatorSummaryBuyProcessorOtherMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.itemKey.itemID
end

function Collectionator.Summary.Buy.GetProcessor(queryType, itemKey, itemKeyInfo)
  if queryType == "TMOG" then
    return CreateAndInitFromMixin(CollectionatorSummaryBuyProcessorTMogMixin, itemKey, itemKeyInfo)
  elseif queryType == "PET" then
    return CreateAndInitFromMixin(CollectionatorSummaryBuyProcessorPetMixin, itemKey, itemKeyInfo)
  elseif queryType == "OTHER" then
    return CreateAndInitFromMixin(CollectionatorSummaryBuyProcessorOtherMixin, itemKey, itemKeyInfo)
  end
end
