local MOUNT_TABLE_LAYOUT = {
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

CollectionatorReplicateMountDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorReplicateMountDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.MountLoadStart,
    Collectionator.Events.MountLoadEnd,
    Collectionator.Events.MountPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorReplicateMountDataProvider")

  self.dirty = false
  self.mounts = {}
end

function CollectionatorReplicateMountDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ReplicateFocusLink,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorReplicateMountDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.MountLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.MountLoadEnd then
    self.mounts = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.MountPurchased then
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
}

function CollectionatorReplicateMountDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function CollectionatorReplicateMountDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.ReplicateExtractWantedItems(Collectionator.Utilities.ReplicateGroupedByID(self.mounts, self.fullScan), self.fullScan)
  local results = {}

  -- Filter mounts
  for _, mountInfo in ipairs(filtered) do
    local info = self.fullScan[mountInfo.index]

    local check = true
    if not self:GetParent().IncludeCollected:GetChecked() then
      check = not select(11, C_MountJournal.GetMountInfoByID(mountInfo.id)) and not Collectionator.State.Purchases.Mounts[mountInfo.id]
    end
    if self:GetParent().ProfessionOnly:GetChecked() then
      check = check and mountInfo.fromProfession
    end
    check = check and self:GetParent().TypeFilter:GetValue(mountInfo.mountType)

    check = check and self:GetParent().QualityFilter:GetValue(info.replicateInfo[4])

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(info.replicateInfo[1]), string.lower(searchString), 1, true)

    local minLevel = self:GetParent().LevelFilter:GetMin()
    local maxLevel = self:GetParent().LevelFilter:GetMax()
    if maxLevel == 0 then
      maxLevel = Collectionator.Constants.MaxLevel
    end

    check = check and mountInfo.levelRequired >= minLevel and mountInfo.levelRequired <= maxLevel

    if check then
      table.insert(results, {
        index = mountInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = mountInfo.quantity,
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

function CollectionatorReplicateMountDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorReplicateMountDataProviderMixin:GetTableLayout()
  return MOUNT_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_MOUNT", "collectionator_columns_mount", {})

function CollectionatorReplicateMountDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_MOUNT)
end

function CollectionatorReplicateMountDataProviderMixin:GetRowTemplate()
  return "CollectionatorReplicateToyMountRowTemplate"
end
