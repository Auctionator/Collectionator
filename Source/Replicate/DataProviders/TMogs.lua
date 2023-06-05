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

CollectionatorReplicateTMogDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorReplicateTMogDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SourceLoadStart,
    Collectionator.Events.SourceLoadEnd,
    Collectionator.Events.TMogPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorReplicateTMogDataProvider")

  self.dirty = false
  self.sources = {}
end

function CollectionatorReplicateTMogDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ReplicateFocusLink,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorReplicateTMogDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Collectionator.Events.ReplicateFocusLink,
  })
end

function CollectionatorReplicateTMogDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.SourceLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.SourceLoadEnd then
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
  elseif eventName == Collectionator.Events.ReplicateFocusLink then
    self.focussedLink = eventData
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

function CollectionatorReplicateTMogDataProviderMixin:Sort(fieldName, sortDirection)
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

function CollectionatorReplicateTMogDataProviderMixin:UniquesPossessionCheck(sourceInfo)
  local check = true
  for _, altSource in ipairs(sourceInfo.set) do
    local tmogInfo = C_TransmogCollection.GetSourceInfo(altSource)
    check = check and not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[altSource]
  end
  return check
end

function CollectionatorReplicateTMogDataProviderMixin:CompletionistPossessionCheck(sourceInfo)
  local tmogInfo = C_TransmogCollection.GetSourceInfo(sourceInfo.id)
  return not tmogInfo.isCollected and not Collectionator.State.Purchases.TMog[sourceInfo.id]
end

function CollectionatorReplicateTMogDataProviderMixin:TMogFilterCheck(sourceInfo, auctionInfo)
  local check = true

  check = check and self:GetParent().QualityFilter:GetValue(auctionInfo.replicateInfo[4])

  check = check and self:GetParent().SlotFilter:GetValue(sourceInfo.slot)

  if sourceInfo.armor ~= -1 then
    check = check and self:GetParent().ArmorFilter:GetValue(sourceInfo.armor)
  else
    check = check and self:GetParent().WeaponFilter:GetValue(sourceInfo.weapon)
  end

  local searchString = self:GetParent().TextFilter:GetText()
  check = check and string.find(string.lower(auctionInfo.replicateInfo[1]), string.lower(searchString), 1, true)

  local minLevel = self:GetParent().LevelFilter:GetMin()
  local maxLevel = self:GetParent().LevelFilter:GetMax()
  if maxLevel == 0 then
    maxLevel = Collectionator.Constants.MaxLevel
  end

  check = check and sourceInfo.levelRequired >= minLevel and sourceInfo.levelRequired <= maxLevel

  check = check and (self:GetParent().IncludeCrafted:GetChecked() or COLLECTIONATOR_CRAFTED_ITEMS[auctionInfo.replicateInfo[17]] == nil)

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

function CollectionatorReplicateTMogDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

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

  local filteredOnly = Collectionator.Utilities.ReplicateExtractWantedItems(grouped, self.fullScan)

  Auctionator.Debug.Message("CollectionatorReplicateTMogDataProviderMixin:Refresh", "filtered", #filteredOnly)

  local results = {}

  for _, sourceInfo in ipairs(filteredOnly) do
    local info = self.fullScan[sourceInfo.index]

    local check = true

    if self:TMogFilterCheck(sourceInfo, info) then
      table.insert(results, {
        index = sourceInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        names = sourceInfo.allNames,
        quantity = sourceInfo.quantity,
        levelRequired = sourceInfo.levelRequired,
        price = Collectionator.Utilities.GetPrice(info.replicateInfo),
        itemLink = info.itemLink, -- Used for tooltips
        iconTexture = info.replicateInfo[2],
        selected = info.itemLink == self.focussedLink,
      })
    end
  end

  self:GetParent().ShowingXResultsText:SetText(COLLECTIONATOR_L_SHOWING_X_RESULTS:format(#results))
  self:GetParent().ShowingXResultsText:Show()

  Collectionator.Utilities.SortByPrice(results, self.fullScan)
  self:AppendEntries(results, true)
  if self:IsVisible() then
    Auctionator.EventBus:Fire(self, Collectionator.Events.ReplicateDisplayedResultsUpdated, results)
  end
end

function CollectionatorReplicateTMogDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorReplicateTMogDataProviderMixin:GetTableLayout()
  return TMOG_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_TMOG", "collectionator_columns_tmog", {})

function CollectionatorReplicateTMogDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_TMOG)
end

function CollectionatorReplicateTMogDataProviderMixin:GetRowTemplate()
  return "CollectionatorReplicateTMogRowTemplate"
end
