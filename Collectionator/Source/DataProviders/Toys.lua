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

CollectionatorToyDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorToyDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ToyLoadStart,
    Collectionator.Events.ToyLoadEnd,
  })

  self.dirty = false
  self.toys = {}
end

function CollectionatorToyDataProviderMixin:OnShow()
  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorToyDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.ToyLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.ToyLoadEnd then
    self.toys = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  end
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
}

function CollectionatorToyDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function CollectionatorToyDataProviderMixin:Refresh()
  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.ExtractWantedItems(Collectionator.Utilities.GroupedByID(self.toys, self.fullScan), self.fullScan)
  local results = {}

  -- Filter toys
  for _, toyInfo in ipairs(filtered) do
    local info = self.fullScan[toyInfo.index]

    local check = true

    if not self:GetParent().IncludeCollected:GetChecked() then
      check = check and not PlayerHasToy(toyInfo.id)
    end

    if not self:GetParent().IncludeUnusable:GetChecked() then
      check = check and toyInfo.usable
    end

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(info.replicateInfo[1]), string.lower(searchString), 1, true)

    if check then
      table.insert(results, {
        index = toyInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = toyInfo.quantity,
        price = Collectionator.Utilities.GetPrice(info.replicateInfo),
        itemLink = info.itemLink, -- Used for tooltips
        iconTexture = info.replicateInfo[2],
      })
    end
  end

  self:GetParent().ShowingXResultsText:SetText(COLLECTIONATOR_L_SHOWING_X_RESULTS:format(#results))
  self:GetParent().ShowingXResultsText:Show()

  Collectionator.Utilities.SortByPrice(results, self.fullScan)
  self:AppendEntries(results, true)
end

function CollectionatorToyDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorToyDataProviderMixin:GetTableLayout()
  return TOY_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_TOY", "collectionator_columns_toy", {})

function CollectionatorToyDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_TOY)
end


function CollectionatorToyDataProviderMixin:GetRowTemplate()
  return "CollectionatorToyMountRowTemplate"
end
