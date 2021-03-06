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
  self.pets = {}
end

function CollectionatorPetDataProviderMixin:OnShow()
  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorPetDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.PetLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.PetLoadEnd then
    self.pets = eventData
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
  level = Auctionator.Utilities.NumberComparator,
}

function CollectionatorPetDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

local function UniquePetKey(petInfo, info)
  return petInfo.id .. " " .. petInfo.level .. " " .. info.replicateInfo[4]
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


function CollectionatorPetDataProviderMixin:Refresh()
  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.ExtractWantedItems(GroupedByIDLevelAndQuality(self.pets, self.fullScan), self.fullScan)
  local results = {}

  local minLevel = self:GetParent().LevelFilter:GetMin()
  if minLevel == 0 then
    minLevel = 1
  end
  local maxLevel = self:GetParent().LevelFilter:GetMax() or 25
  if maxLevel == 0 then
    maxLevel = 25
  end
  -- Filter pets
  for _, petInfo in ipairs(filtered) do
    local info = self.fullScan[petInfo.index]
    local check = true

    if not self:GetParent().IncludeCollected:GetChecked() then
      local ownedString = C_PetJournal.GetOwnedBattlePetString(petInfo.id)
      local amountOwned = 0
      if ownedString ~= nil then
        amountOwned = tonumber(string.match(ownedString, "(%d)/%d"))
      end
      check = check and (amountOwned == 0)
    end
    if self:GetParent().ProfessionOnly:GetChecked() then
      check = check and petInfo.fromProfession
    end

    check = check and self:GetParent().TypeFilter:GetValue(petInfo.petType)

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.match(string.lower(info.replicateInfo[1]), string.lower(searchString))

    check = check and petInfo.level >= minLevel
    check = check and petInfo.level <= maxLevel

    check = check and self:GetParent().QualityFilter:GetValue(info.replicateInfo[4])

    if check then
      table.insert(results, {
        index = petInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, petInfo.name),
        names = petInfo.allNames,
        quantity = petInfo.quantity,
        level = petInfo.level,
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

function CollectionatorPetDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorPetDataProviderMixin:GetTableLayout()
  return PET_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_PET", "collectionator_columns_pet", {})

function CollectionatorPetDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_PET)
end

function CollectionatorPetDataProviderMixin:GetRowTemplate()
  return "CollectionatorPetRowTemplate"
end
