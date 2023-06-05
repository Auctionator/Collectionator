local TMOG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = COLLECTIONATOR_L_LEVEL_REQUIRED,
    headerParameters = { "levelRequired" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "levelRequired" },
    width = 120
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = COLLECTIONATOR_L_CHOICES,
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

CollectionatorSummaryTMogDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorSummaryTMogDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryTMogLoadStart,
    Collectionator.Events.SummaryTMogLoadEnd,
    Collectionator.Events.TMogPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryTMogDataProvider")

  self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
  self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED")

  self.dirty = false
  self.sources = {}
end

function CollectionatorSummaryTMogDataProviderMixin:OnEvent(eventName, ...)
  -- transmog source learnt/unlearnt
  self.uniquesFiltered = nil
  self.completionistFiltered = nil
end

function CollectionatorSummaryTMogDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryFocusItem,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorSummaryTMogDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Collectionator.Events.SummaryFocusItem,
  })
end

function CollectionatorSummaryTMogDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.SummaryTMogLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
    self.uniquesFiltered = nil
    self.completionistFiltered = nil
  elseif eventName == Collectionator.Events.SummaryTMogLoadEnd then
    self.sources = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.TMogPurchased then
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
  levelRequired = Auctionator.Utilities.NumberComparator,
}

function CollectionatorSummaryTMogDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

local function GroupedBySourceID(array)
  local results = {}

  for _, info in ipairs(array) do
    if results[info.id] == nil then
      results[info.id] = {}
    end
    table.insert(results[info.id], info)
  end

  return results
end

local function GroupedByVisualID(array)
  local results = {}

  for _, info in ipairs(array) do
    if results[info.visual] == nil then
      results[info.visual] = {}
    end
    table.insert(results[info.visual], info)
  end

  return results
end

function CollectionatorSummaryTMogDataProviderMixin:EarlyUniquesPossessionCheck(sourceInfo)
  local check = true
  for _, altSource in ipairs(sourceInfo.set) do
    local tmogInfo = C_TransmogCollection.GetSourceInfo(altSource)
    check = check and not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[altSource]
  end
  return check
end

function CollectionatorSummaryTMogDataProviderMixin:EarlyCompletionistPossessionCheck(sourceInfo)
  local tmogInfo = C_TransmogCollection.GetSourceInfo(sourceInfo.id)
  return not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[sourceInfo.id]
end

function CollectionatorSummaryTMogDataProviderMixin:LateUniquesPossessionCheck(sourceInfo)
  for _, altSource in ipairs(sourceInfo.set) do
    if Collectionator.State.Purchases.TMog[altSource] then
      return false
    end
  end
  return true
end

function CollectionatorSummaryTMogDataProviderMixin:LateCompletionistPossessionCheck(sourceInfo)
  return not Collectionator.State.Purchases.TMog[sourceInfo.id]
end

function CollectionatorSummaryTMogDataProviderMixin:TMogFilterCheck(sourceInfo, cachedFilters)
  local check = true

  check = check and cachedFilters.qualityFilter:GetValue(sourceInfo.itemKeyInfo.quality)

  check = check and cachedFilters.slotFilter:GetValue(sourceInfo.slot)

  if sourceInfo.armor ~= -1 then
    check = check and cachedFilters.armorFilter:GetValue(sourceInfo.armor)
  else
    check = check and cachedFilters.weaponFilter:GetValue(sourceInfo.weapon)
  end

  check = check and string.find(sourceInfo.itemNameLower, cachedFilters.searchString, 1, true)

  check = check and sourceInfo.levelRequired >= cachedFilters.minLevel and sourceInfo.levelRequired <= cachedFilters.maxLevel

  check = check and (cachedFilters.includeCrafted or COLLECTIONATOR_CRAFTED_ITEMS[sourceInfo.itemID] == nil)

  if not cachedFilters.includeCollected then
    if cachedFilters.uniquesOnly then
      check = check and sourceInfo.doesNotHaveSource and self:LateUniquesPossessionCheck(sourceInfo)
    else
      check = check and sourceInfo.doesNotHaveSource and self:LateCompletionistPossessionCheck(sourceInfo)
    end
  end

  if cachedFilters.characterOnly then
    --Check that the character can use the gear
    return check and C_TransmogCollection.PlayerKnowsSource(sourceInfo.id)
  else
    return check
  end
end

function CollectionatorSummaryTMogDataProviderMixin:PreprocessFilteredList(filtered)
  table.sort(filtered, function(a, b)
    return self.fullScan[a.index].minPrice < self.fullScan[b.index].minPrice
  end)
  for _, sourceInfo in ipairs(filtered) do
    sourceInfo.itemName = Collectionator.Utilities.SummaryColorName(sourceInfo.itemKeyInfo)
    sourceInfo.itemNameLower = string.lower(sourceInfo.itemKeyInfo.itemName)
    sourceInfo.keyString = Auctionator.Utilities.ItemKeyString(self.fullScan[sourceInfo.index].itemKey)
  end
end

function CollectionatorSummaryTMogDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

  --self:GetParent().WoDBonusScanner:CheckWoDItems(self.fullScan)

  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filteredOnly

  -- Preprocess filter data to speed up refreshes after a purchase
  if self:GetParent().UniquesOnly:GetChecked() then
    -- Uniques
    if not self.uniquesFiltered then
      local grouped = GroupedByVisualID(self.sources)
      self.uniquesFiltered = Collectionator.Utilities.SummaryExtractWantedItems(grouped, self.fullScan)
      self:PreprocessFilteredList(self.uniquesFiltered)
      for _, sourceInfo in ipairs(self.uniquesFiltered) do
        sourceInfo.doesNotHaveSource = self:EarlyUniquesPossessionCheck(sourceInfo)
      end
    end
    filteredOnly = self.uniquesFiltered
  else
    -- Completionist
    if not self.completionistFiltered then
      local grouped = GroupedBySourceID(self.sources)
      self.completionistFiltered = Collectionator.Utilities.SummaryExtractWantedItems(grouped, self.fullScan)
      self:PreprocessFilteredList(self.completionistFiltered)
      for _, sourceInfo in ipairs(self.completionistFiltered) do
        sourceInfo.doesNotHaveSource = self:EarlyCompletionistPossessionCheck(sourceInfo)
      end
    end
    filteredOnly = self.completionistFiltered
  end

  Auctionator.Debug.Message("CollectionatorSummaryTMogDataProviderMixin:Refresh", "filtered", #filteredOnly)

  local results = {}

  local cachedFilters = {
    searchString = string.lower(self:GetParent().TextFilter:GetText()),
    minLevel = self:GetParent().LevelFilter:GetMin(),
    maxLevel = self:GetParent().LevelFilter:GetMax(),
    includeCrafted = self:GetParent().IncludeCrafted:GetChecked(),
    includeCollected = self:GetParent().IncludeCollected:GetChecked(),
    uniquesOnly = self:GetParent().UniquesOnly:GetChecked(),
    characterOnly = self:GetParent().CharacterOnly:GetChecked(),
    qualityFilter = self:GetParent().QualityFilter,
    slotFilter = self:GetParent().SlotFilter,
    armorFilter = self:GetParent().ArmorFilter,
    weaponFilter = self:GetParent().WeaponFilter,
  }
  if cachedFilters.maxLevel == 0 then
    cachedFilters.maxLevel = Collectionator.Constants.MaxLevel
  end

  for _, sourceInfo in ipairs(filteredOnly) do
    local info = self.fullScan[sourceInfo.index]

    if self:TMogFilterCheck(sourceInfo, cachedFilters) then
      table.insert(results, {
        index = sourceInfo.index,
        itemName = sourceInfo.itemName,
        name = sourceInfo.itemKeyInfo.itemName,
        names = sourceInfo.allNames,
        quantity = sourceInfo.quantity,
        levelRequired = sourceInfo.levelRequired,
        price = info.minPrice,
        itemKey = info.itemKey,
        itemKeyInfo = sourceInfo.itemKeyInfo,
        iconTexture = sourceInfo.itemKeyInfo.iconFileID,
        selected = sourceInfo.keyString == self.focussedItem,
      })
    end
  end

  self:GetParent().ShowingXResultsText:SetText(COLLECTIONATOR_L_SHOWING_X_RESULTS:format(#results))
  self:GetParent().ShowingXResultsText:Show()

  self:AppendEntries(results, true)
  if self:IsVisible() then
    Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryDisplayedResultsUpdated, results)
  end
end

function CollectionatorSummaryTMogDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorSummaryTMogDataProviderMixin:GetTableLayout()
  return TMOG_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_TMOG", "collectionator_columns_tmog", {})

function CollectionatorSummaryTMogDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_TMOG)
end

function CollectionatorSummaryTMogDataProviderMixin:GetRowTemplate()
  return "CollectionatorSummaryTMogRowTemplate"
end
