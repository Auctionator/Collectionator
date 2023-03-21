local TOY_TABLE_LAYOUT = {
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

CollectionatorSummaryToyDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorSummaryToyDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryToyLoadStart,
    Collectionator.Events.SummaryToyLoadEnd,
    Collectionator.Events.ToyPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryToyDataProvider")

  self.dirty = false
  self.toys = {}
end

function CollectionatorSummaryToyDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryFocusItem,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorSummaryToyDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.SummaryToyLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.SummaryToyLoadEnd then
    self.toys = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.ToyPurchased then
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
}

function CollectionatorSummaryToyDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function CollectionatorSummaryToyDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.SummaryExtractWantedItems(Collectionator.Utilities.SummaryGroupedByID(self.toys, self.fullScan), self.fullScan)
  local results = {}

  -- Filter toys
  for _, toyInfo in ipairs(filtered) do
    local info = self.fullScan[toyInfo.index]

    local check = true

    if not self:GetParent().IncludeCollected:GetChecked() then
      check = check and not PlayerHasToy(toyInfo.id) and not Collectionator.State.Purchases.Toys[toyInfo.id]
    end

    if not self:GetParent().IncludeUnusable:GetChecked() then
      check = check and toyInfo.usable
    end

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(toyInfo.itemKeyInfo.itemName), string.lower(searchString), 1, true)

    if check then
      table.insert(results, {
        index = toyInfo.index,
        itemName = Collectionator.Utilities.SummaryColorName(toyInfo.itemKeyInfo),
        name = toyInfo.itemKeyInfo.itemName,
        quantity = toyInfo.quantity,
        price = info.minPrice,
        itemLink = toyInfo.itemLink, -- Used for tooltips
        itemKey = info.itemKey,
        itemKeyInfo = toyInfo.itemKeyInfo,
        iconTexture = toyInfo.itemKeyInfo.iconFileID,
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

function CollectionatorSummaryToyDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorSummaryToyDataProviderMixin:GetTableLayout()
  return TOY_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_TOY", "collectionator_columns_toy", {})

function CollectionatorSummaryToyDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_TOY)
end


function CollectionatorSummaryToyDataProviderMixin:GetRowTemplate()
  return "CollectionatorSummaryToyMountRowTemplate"
end
