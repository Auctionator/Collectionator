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

  self.dirty = false
  self.sources = {}
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

function CollectionatorSummaryTMogDataProviderMixin:UniquesPossessionCheck(sourceInfo)
  local check = true
  for _, altSource in ipairs(sourceInfo.set) do
    local tmogInfo = C_TransmogCollection.GetSourceInfo(altSource)
    check = check and not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[altSource]
  end
  return check
end

function CollectionatorSummaryTMogDataProviderMixin:CompletionistPossessionCheck(sourceInfo)
  local tmogInfo = C_TransmogCollection.GetSourceInfo(sourceInfo.id)
  return not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[sourceInfo.id]
end

function CollectionatorSummaryTMogDataProviderMixin:TMogFilterCheck(sourceInfo)
  local check = true

  check = check and self:GetParent().QualityFilter:GetValue(sourceInfo.itemKeyInfo.quality)

  check = check and self:GetParent().SlotFilter:GetValue(sourceInfo.slot)

  if sourceInfo.armor ~= -1 then
    check = check and self:GetParent().ArmorFilter:GetValue(sourceInfo.armor)
  else
    check = check and self:GetParent().WeaponFilter:GetValue(sourceInfo.weapon)
  end

  local searchString = self:GetParent().TextFilter:GetText()
  check = check and string.find(string.lower(sourceInfo.itemKeyInfo.itemName), string.lower(searchString), 1, true)

  local minLevel = self:GetParent().LevelFilter:GetMin()
  local maxLevel = self:GetParent().LevelFilter:GetMax()
  if maxLevel == 0 then
    maxLevel = Collectionator.Constants.MaxLevel
  end

  check = check and sourceInfo.levelRequired >= minLevel and sourceInfo.levelRequired <= maxLevel

  if not self:GetParent().IncludeCollected:GetChecked() then
    if self:GetParent().UniquesOnly:GetChecked() then
      check = check and self:UniquesPossessionCheck(sourceInfo)
    else
      check = check and self:CompletionistPossessionCheck(sourceInfo)
    end
  end

  if self:GetParent().CharacterOnly:GetChecked() then
    --Check that the character can use the gear
    return check and C_TransmogCollection.PlayerKnowsSource(sourceInfo.id)
  else
    --Would check for junk gear here, but the QualityFilter filters it out
    return check
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

  local grouped
  if self:GetParent().UniquesOnly:GetChecked() then
    -- Uniques
    grouped = GroupedByVisualID(self.sources)
  else
    -- Completionist
    grouped = GroupedBySourceID(self.sources)
  end

  local filteredOnly = Collectionator.Utilities.SummaryExtractWantedItems(grouped, self.fullScan)

  Auctionator.Debug.Message("CollectionatorSummaryTMogDataProviderMixin:Refresh", "filtered", #filteredOnly)

  local results = {}

  for _, sourceInfo in ipairs(filteredOnly) do
    local info = self.fullScan[sourceInfo.index]

    local check = true

    if self:TMogFilterCheck(sourceInfo) then
      table.insert(results, {
        index = sourceInfo.index,
        itemName = Collectionator.Utilities.SummaryColorName(sourceInfo.itemKeyInfo),
        name = sourceInfo.itemKeyInfo.itemName,
        names = sourceInfo.allNames,
        quantity = sourceInfo.quantity,
        levelRequired = sourceInfo.levelRequired,
        price = info.minPrice,
        itemKey = info.itemKey,
        itemKeyInfo = sourceInfo.itemKeyInfo,
        iconTexture = sourceInfo.itemKeyInfo.iconFileID,
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
