local PET_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
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

CollectionatorSummaryPetDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorSummaryPetDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryPetLoadStart,
    Collectionator.Events.SummaryPetLoadEnd,
    Collectionator.Events.PetPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryPetDataProvider")

  self.dirty = false
  self.pets = {}
end

function CollectionatorSummaryPetDataProviderMixin:OnShow()
  self.focussedItem = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryFocusItem,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorSummaryPetDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.SummaryPetLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.SummaryPetLoadEnd then
    self.pets = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.PetPurchased then
    self.dirty = true
    if self:IsVisible() and not self:GetParent().IncludeCollected:GetChecked() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.SummaryFocusItem then
    self.focussedItem = eventData
    self.dirty = true
    self:Refresh()
  end
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
}

function CollectionatorSummaryPetDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

local function UniquePetKey(petInfo, info)
  return petInfo.id
end
local function GroupedByIDLevelAndQuality(array, fullScan)
  local results = {}

  for _, info in ipairs(array) do
    local key = UniquePetKey(info, fullScan[info.index])
    if results[key] == nil then
      results[key] = {}
    end
    table.insert(results[key], info)
  end

  return results
end


function CollectionatorSummaryPetDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.SummaryExtractWantedItems(GroupedByIDLevelAndQuality(self.pets, self.fullScan), self.fullScan)
  local results = {}

  -- Filter pets
  for _, petInfo in ipairs(filtered) do
    local info = self.fullScan[petInfo.index]
    local check = true

    if not self:GetParent().IncludeCollected:GetChecked() and
       not self:GetParent().NotMaxedOut:GetChecked() then
      local amountOwned = C_PetJournal.GetNumCollectedInfo(petInfo.id)
      check = amountOwned == 0 and Collectionator.State.Purchases.Pets[petInfo.id] == nil
    end

    if self:GetParent().NotMaxedOut:GetChecked() then
      local amountOwned, maxOwned = C_PetJournal.GetNumCollectedInfo(petInfo.id)
      check = check and amountOwned ~= maxOwned
    end

    if self:GetParent().ProfessionOnly:GetChecked() then
      check = check and petInfo.fromProfession
    end

    check = check and self:GetParent().TypeFilter:GetValue(petInfo.petType)

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(petInfo.itemKeyInfo.itemName), string.lower(searchString), 1, true)

    check = check and self:GetParent().QualityFilter:GetValue(petInfo.itemKeyInfo.quality)

    if check then
      table.insert(results, {
        index = petInfo.index,
        itemName = Collectionator.Utilities.SummaryColorName(petInfo.itemKeyInfo),
        names = petInfo.allNames,
        quantity = petInfo.quantity,
        level = petInfo.level,
        price = info.minPrice,
        itemKey = info.itemKey,
        itemKeyInfo = petInfo.itemKeyInfo,
        iconTexture = petInfo.itemKeyInfo.iconFileID,
        selected = Auctionator.Utilities.ItemKeyString(info.itemKey) == self.focussedItem,
      })
    end
  end

  self:GetParent().ShowingXResultsText:SetText(COLLECTIONATOR_L_SHOWING_X_RESULTS:format(#results))
  self:GetParent().ShowingXResultsText:Show()

  Collectionator.Utilities.SortByPrice(results, self.fullScan)
  self:AppendEntries(results, true)
  if self:IsVisible() then
    Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryDisplayedResultsUpdated, results)
  end
end

function CollectionatorSummaryPetDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorSummaryPetDataProviderMixin:GetTableLayout()
  return PET_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_PET", "collectionator_columns_pet", {})

function CollectionatorSummaryPetDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_PET)
end

function CollectionatorSummaryPetDataProviderMixin:GetRowTemplate()
  return "CollectionatorSummaryPetRowTemplate"
end
