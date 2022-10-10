CollectionatorBuyProcessorMixin = {}

function CollectionatorBuyProcessorMixin:Init(itemLink)
  self.itemLink = itemLink
end

function CollectionatorBuyProcessorMixin:PrepareSearch()
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

function CollectionatorBuyProcessorTMogMixin:PrepareSearch()
  local itemID = GetItemInfoInstant(self.itemLink)
  self.gearItemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
  self.expectedItemID = itemID
end

function CollectionatorBuyProcessorTMogMixin:Send()
  print("raw query", Auctionator.Utilities.ItemKeyString(self.gearItemKey))
  C_AuctionHouse.SendSellSearchQuery(self.gearItemKey, Collectionator.Constants.ITEM_SORTS, false)
end

function CollectionatorBuyProcessorTMogMixin:GetSearchResult(itemKey)
  return GetIdenticalLinkItem(self.itemLink, itemKey)
end

function CollectionatorBuyProcessorTMogMixin:IsExpectedItemKey(itemKey)
  return itemKey.itemID == self.expectedItemID
end

CollectionatorBuyProcessorPetMixin = CreateFromMixins(CollectionatorBuyProcessorMixin)

function CollectionatorBuyProcessorPetMixin:PrepareSearch()
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

function CollectionatorBuyProcessorPetMixin:Send()
  local itemKey
  if self.cagedSearch then
    itemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, self.expectedPetSpecies)
  else
    itemKey = C_AuctionHouse.MakeItemKey(self.expectedItemID)
  end

  print("raw query", Auctionator.Utilities.ItemKeyString(itemKey))
  C_AuctionHouse.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
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
  if self.cagedSearch then
    return itemKey.battlePetSpeciesID == self.expectedPetSpecies
  else
    return itemKey.itemID == self.expectedItemID
  end
end

CollectionatorBuyProcessorOtherMixin = CreateFromMixins(CollectionatorBuyProcessorMixin)

function CollectionatorBuyProcessorOtherMixin:PrepareSearch()
  local itemID = GetItemInfoInstant(self.itemLink)

  self.expectedItemID = itemID
end

function CollectionatorBuyProcessorOtherMixin:Send()
  print("raw query")
  local itemKey = C_AuctionHouse.MakeItemKey(self.expectedItemID)
  C_AuctionHouse.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
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
