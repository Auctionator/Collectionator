CollectionatorBuyProcessorMixin = {}

function CollectionatorBuyProcessorMixin:Init(itemLink)
  self.itemLink = itemLink
end

function CollectionatorBuyProcessorMixin:StartSearch()
  error("override")
end

function CollectionatorBuyProcessorMixin:GetSearchResult(itemKey)
  error("override")
end

-- Since 9.1 crafted items include the GUID of the crafter in the item link,
-- this removes it so that we can match irrespective of who crafted it.
local function RemovePlayerGUID(itemLink)
  if string.find(itemLink, ":Player[^: ]+:") then
    return string.gsub(itemLink, ":Player[^: ]+:", "::")
  end
  return itemLink
end

local function GetIdenticalLinkItem(itemLink, itemKey)
  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if RemovePlayerGUID(info.itemLink) == itemLink then
      return info
    end
  end

  return nil
end

local function GetSameItemID(itemID, itemKey)
  if itemID == itemKey.itemID then
    return C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
  end
end

CollectionatorBuyProcessorTMogMixin = CreateFromMixins(CollectionatorBuyProcessorMixin)

function CollectionatorBuyProcessorTMogMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.itemLink)
  local itemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
  self.expectedItemID = itemID

  -- Queries item key (necessary for the next search to work, just is, found by
  -- experiment - probably some internal Blizzard AH thing)
  Auctionator.AH.GetItemKeyInfo(itemKey, function(itemKeyInfo)
    Auctionator.AH.SendSellSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
  end)
end

function CollectionatorBuyProcessorTMogMixin:GetSearchResult(itemKey)
  return GetIdenticalLinkItem(self.itemLink, itemKey)
end

function CollectionatorBuyProcessorTMogMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.expectedItemID
end

CollectionatorBuyProcessorPetMixin = CreateFromMixins(CollectionatorBuyProcessorMixin)

function CollectionatorBuyProcessorPetMixin:StartSearch()
  local auctionatorDBKey = Auctionator.Utilities.BasicDBKeyFromLink(self.itemLink)
  local _, petID = strsplit(":", auctionatorDBKey)
  if petID ~= nil then
    self.cagedSearch = true
    -- Use that an Auctionator database key for a pet has the format p:[speciesID]
    self.expectedItemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, tonumber(petID))
    Auctionator.AH.SendSearchQuery(self.expectedItemKey, Collectionator.Constants.ITEM_SORTS, true)

  else
    self.cagedSearch = false
    Auctionator.AH.GetItemKeyInfo(C_AuctionHouse.MakeItemKey(tonumber(auctionatorDBKey)), function(itemKeyInfo)
      -- Use that any other DB key is of the format [item-id]
      self.expectedItemKey = C_AuctionHouse.MakeItemKey(tonumber(auctionatorDBKey))
      Auctionator.AH.SendSearchQuery(self.expectedItemKey, Collectionator.Constants.ITEM_SORTS, true)
    end)
  end
end

function CollectionatorBuyProcessorPetMixin:GetSearchResult(itemKey)
  if self.cagedSearch then
    return GetIdenticalLinkItem(self.itemLink, itemKey)

  else
    local itemID = GetItemInfoInstant(self.itemLink)
    return GetSameItemID(itemID, itemKey)
  end
end

function CollectionatorBuyProcessorPetMixin:IsExpectedItemKey(itemKey)
  return self.expectedItemKey and Auctionator.Utilities.ItemKeyString(self.expectedItemKey) == Auctionator.Utilities.ItemKeyString(itemKey)
end

CollectionatorBuyProcessorOtherMixin = CreateFromMixins(CollectionatorBuyProcessorMixin)

function CollectionatorBuyProcessorOtherMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.itemLink)

  self.expectedItemID = itemID

  Auctionator.AH.GetItemKeyInfo(C_AuctionHouse.MakeItemKey(itemID), function(itemKeyInfo)
    Auctionator.AH.SendSearchQuery(C_AuctionHouse.MakeItemKey(itemID), Collectionator.Constants.ITEM_SORTS, true)
  end)
end

function CollectionatorBuyProcessorOtherMixin:GetSearchResult(itemKey)
  return GetSameItemID(self.expectedItemID, itemKey)
end

function CollectionatorBuyProcessorOtherMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.expectedItemID
end

function Collectionator.Buy.GetProcessor(queryType, itemLink)
  if queryType == "TMOG" then
    return CreateAndInitFromMixin(CollectionatorBuyProcessorTMogMixin, itemLink)
  elseif queryType == "PET" then
    return CreateAndInitFromMixin(CollectionatorBuyProcessorPetMixin, itemLink)
  elseif queryType == "OTHER" then
    return CreateAndInitFromMixin(CollectionatorBuyProcessorOtherMixin, itemLink)
  end
end
