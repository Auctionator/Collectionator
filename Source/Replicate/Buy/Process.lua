CollectionatorReplicateBuyProcessorMixin = {}

function CollectionatorReplicateBuyProcessorMixin:Init(itemLink)
  self.itemLink = itemLink
end

function CollectionatorReplicateBuyProcessorMixin:PrepareSearch()
  error("override")
end

function CollectionatorReplicateBuyProcessorMixin:Send()
  error("override")
end

function CollectionatorReplicateBuyProcessorMixin:IsReady()
  error("override")
end

function CollectionatorReplicateBuyProcessorMixin:GetSearchResult(itemKey)
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

CollectionatorReplicateBuyProcessorTMogMixin = CreateFromMixins(CollectionatorReplicateBuyProcessorMixin)

function CollectionatorReplicateBuyProcessorTMogMixin:PrepareSearch()
  local itemID = C_Item.GetItemInfoInstant(self.itemLink)
  self.gearItemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
  self.expectedItemID = itemID
end

function CollectionatorReplicateBuyProcessorTMogMixin:IsReady()
  return C_AuctionHouse.GetItemKeyInfo(self.gearItemKey) ~= nil
end

function CollectionatorReplicateBuyProcessorTMogMixin:Send()
  Auctionator.AH.SendSellSearchQueryByItemKey(self.gearItemKey, Collectionator.Constants.ITEM_SORTS, false)
end

function CollectionatorReplicateBuyProcessorTMogMixin:GetSearchResult(itemKey)
  return GetIdenticalLinkItem(self.itemLink, itemKey)
end

function CollectionatorReplicateBuyProcessorTMogMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.expectedItemID
end

CollectionatorReplicateBuyProcessorPetMixin = CreateFromMixins(CollectionatorReplicateBuyProcessorMixin)

function CollectionatorReplicateBuyProcessorPetMixin:PrepareSearch()
  local auctionatorDBKey = Auctionator.Utilities.BasicDBKeyFromLink(self.itemLink)
  local _, petID = strsplit(":", auctionatorDBKey)
  if petID ~= nil then
    self.cagedSearch = true
    -- Use that an Auctionator database key for a pet has the format p:[speciesID]
    self.expectedPetSpecies = tonumber(petID)
  else
    self.cagedSearch = false
    -- Use that any other DB key is of the format [item-id]
    self.expectedItemID = tonumber(auctionatorDBKey)
  end
end

function CollectionatorReplicateBuyProcessorPetMixin:GetKey()
  if self.cagedSearch then
    return C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, self.expectedPetSpecies)
  else
    return C_AuctionHouse.MakeItemKey(self.expectedItemID)
  end
end

function CollectionatorReplicateBuyProcessorPetMixin:IsReady()
  return C_AuctionHouse.GetItemKeyInfo(self:GetKey()) ~= nil
end

function CollectionatorReplicateBuyProcessorPetMixin:Send()
  Auctionator.AH.SendSearchQueryByGenerator(function()
    return self:GetKey()
  end, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorReplicateBuyProcessorPetMixin:GetSearchResult(itemKey)
  if self.cagedSearch then
    return GetIdenticalLinkItem(self.itemLink, itemKey)

  else
    local itemID = C_Item.GetItemInfoInstant(self.itemLink)
    return GetSameItemID(itemID, itemKey)
  end
end

function CollectionatorReplicateBuyProcessorPetMixin:IsExpectedItemKey(itemKey)
  if self.cagedSearch then
    return itemKey.battlePetSpeciesID == self.expectedPetSpecies
  else
    return itemKey.itemID == self.expectedItemID
  end
end

CollectionatorReplicateBuyProcessorOtherMixin = CreateFromMixins(CollectionatorReplicateBuyProcessorMixin)

function CollectionatorReplicateBuyProcessorOtherMixin:PrepareSearch()
  local itemID = C_Item.GetItemInfoInstant(self.itemLink)

  self.expectedItemID = itemID
end

function CollectionatorReplicateBuyProcessorOtherMixin:GetKey()
  return C_AuctionHouse.MakeItemKey(self.expectedItemID)
end

function CollectionatorReplicateBuyProcessorOtherMixin:Send()
  Auctionator.AH.SendSearchQueryByGenerator(function()
    return self:GetKey()
  end, Collectionator.Constants.ITEM_SORTS, false)
end

function CollectionatorReplicateBuyProcessorOtherMixin:GetSearchResult(itemKey)
  return GetSameItemID(self.expectedItemID, itemKey)
end

function CollectionatorReplicateBuyProcessorOtherMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.expectedItemID
end

function Collectionator.Replicate.Buy.GetProcessor(queryType, itemLink)
  if queryType == "TMOG" then
    return CreateAndInitFromMixin(CollectionatorReplicateBuyProcessorTMogMixin, itemLink)
  elseif queryType == "PET" then
    return CreateAndInitFromMixin(CollectionatorReplicateBuyProcessorPetMixin, itemLink)
  elseif queryType == "OTHER" then
    return CreateAndInitFromMixin(CollectionatorReplicateBuyProcessorOtherMixin, itemLink)
  end
end
