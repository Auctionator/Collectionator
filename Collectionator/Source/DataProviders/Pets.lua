local PET_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_LEVEL,
    headerParameters = { "level" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "level" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 150,
  },
}

CollectionatorPetDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorPetDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.PetLoadStart,
    Collectionator.Events.PetLoadEnd,
  })

  self.processCountPerUpdate = 500
  self.dirty = false
end

function CollectionatorPetDataProviderMixin:OnShow()
  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorPetDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.PetLoadStart then
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
  elseif eventName == Collectionator.Events.PetLoadEnd then
    self.pets = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsShown() then
      self:Refresh()
    end
  end
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
}

function CollectionatorPetDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function CollectionatorPetDataProviderMixin:Refresh()
  self.dirty = false
  self:Reset()

  if self.pets == nil or #self.pets == 0 then
    return
  end

  local results = {}

  self.onSearchStarted()

  -- Filter pets
  for _, petInfo in ipairs(self.pets) do
    local info = self.fullScan[petInfo.index]
    if petInfo.amountOwned == 0 then
      table.insert(results, {
        index = petInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = petInfo.amountOwned,--petInfo.quantity,
        level = petInfo.level,
        price = info.replicateInfo[10] or info.replicateInfo[11],
        itemLink = info.itemLink, -- Used for tooltips
        iconTexture = info.replicateInfo[2],
      })
    end
  end

  self:AppendEntries(results, true)
end

function CollectionatorPetDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorPetDataProviderMixin:GetTableLayout()
  return PET_TABLE_LAYOUT
end

function CollectionatorPetDataProviderMixin:GetRowTemplate()
  return "CollectionatorTMogRowTemplate"
end
