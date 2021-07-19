CollectionatorRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
    self:StartSearch()
  end
end

-- Override
function CollectionatorRowMixin:StartSearch()
  Auctionator.Debug.Message("CollectionatorRowMixin:StartSearch")
end

-- Override
function CollectionatorRowMixin:GetSearchResult(itemKey)
  Auctionator.Debug.Message("CollectionatorRowMixin:GetResult")
end

function CollectionatorRowMixin:OnEvent(eventName, itemKey)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnEvent")
  self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  Auctionator.EventBus
    :RegisterSource(self, "CollectionatorRowMixin")
    :Fire(self, Collectionator.Events.ShowBuyoutOptions, self:GetSearchResult(itemKey), self.rowData)
    :UnregisterSource(self)
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
  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local info = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    if GetItemInfoInstant(info.itemLink) == itemID then
      return info
    end
  end
  return nil
end

CollectionatorTMogRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorTMogRowMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.rowData.itemLink)
  local itemKey = {itemID = itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}

  Auctionator.AH.SendSellSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorTMogRowMixin:GetSearchResult(itemKey)
  return GetIdenticalLinkItem(self.rowData.itemLink, itemKey)
end

CollectionatorPetRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorPetRowMixin:StartSearch()
  local itemKey
  local auctionatorDBKey = (Auctionator.Utilities.BasicDBKeyFromLink or Auctionator.Utilities.ItemKeyFromLink)(self.rowData.itemLink)
  local _, petID = strsplit(":", auctionatorDBKey)
  if petID ~= nil then
    self.cagedSearch = true
    -- Use that an Auctionator database key for a pet has the format p:[speciesID]
    itemKey = C_AuctionHouse.MakeItemKey(Auctionator.Constants.PET_CAGE_ID, 0, 0, tonumber(petID))
  else
    self.cagedSearch = false
    -- Use that any other DB key is of the format [item-id]
    itemKey = C_AuctionHouse.MakeItemKey(tonumber(auctionatorDBKey))
  end

  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorPetRowMixin:GetSearchResult(itemKey)
  if self.cagedSearch then
    return GetIdenticalLinkItem(self.rowData.itemLink, itemKey)

  else
    local itemID = GetItemInfoInstant(self.rowData.itemLink)
    return GetSameItemID(itemID, itemKey)
  end
end

CollectionatorToyMountRowMixin = CreateFromMixins(CollectionatorRowMixin)

function CollectionatorToyMountRowMixin:StartSearch()
  local itemID = GetItemInfoInstant(self.rowData.itemLink)
  local itemKey = C_AuctionHouse.MakeItemKey(itemID)

  self.expectedItemID = itemID
  Auctionator.AH.SendSearchQuery(itemKey, Collectionator.Constants.ITEM_SORTS, true)
end

function CollectionatorToyMountRowMixin:GetSearchResult(itemKey)
  return GetSameItemID(self.expectedItemID, itemKey)
end
