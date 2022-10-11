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
    Collectionator.Events.PetPurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorPetDataProvider")

  self.dirty = false
  self.pets = {}
end

function CollectionatorPetDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.FocusLink,
  })

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
  elseif eventName == Collectionator.Events.PetPurchased then
    self.dirty = true
    if self:IsVisible() and not self:GetParent().IncludeCollected:GetChecked() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.FocusLink then
    self.focussedLink = eventData
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
local function GetLevelOfOwnedPets()
  C_PetJournal.SetDefaultFilters()
  local result = {}
  for index = 1, (C_PetJournal.GetNumPets()) do
    local info = { C_PetJournal.GetPetInfoByIndex(index) }
    local speciesID = info[2]
    local level = info[5]
    if result[speciesID] == nil then
      result[speciesID] = level
    else
      result[speciesID] = math.max(level, result[speciesID])
    end
  end

  for speciesID, levelDetails in pairs(Collectionator.State.Purchases.Pets) do
    for level in pairs(levelDetails) do
      if result[speciesID] == nil then
        result[speciesID] = level
      else
        result[speciesID] = math.max(level, result[speciesID])
      end
    end
  end

  return result
end


function CollectionatorPetDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

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

  local petLevelsInfo = nil
  if self:GetParent().NotAll25:GetChecked() then
    petLevelsInfo = GetLevelOfOwnedPets()
  end

  -- Filter pets
  for _, petInfo in ipairs(filtered) do
    local info = self.fullScan[petInfo.index]
    local check = true

    if not self:GetParent().IncludeCollected:GetChecked() and
       not self:GetParent().NotMaxedOut:GetChecked() and
       not self:GetParent().NotAll25:GetChecked() then
      local amountOwned = C_PetJournal.GetNumCollectedInfo(petInfo.id)
      check = amountOwned == 0 and Collectionator.State.Purchases.Pets[petInfo.id] == nil
    end

    if self:GetParent().NotMaxedOut:GetChecked() then
      local amountOwned, maxOwned = C_PetJournal.GetNumCollectedInfo(petInfo.id)
      check = check and amountOwned ~= maxOwned
    end

    if self:GetParent().NotAll25:GetChecked() then
      local got25 = petLevelsInfo[petInfo.id] ~= nil and petLevelsInfo[petInfo.id] == 25
      check = check and not got25 and petInfo.level == 25
    end

    if self:GetParent().ProfessionOnly:GetChecked() then
      check = check and petInfo.fromProfession
    end

    check = check and self:GetParent().TypeFilter:GetValue(petInfo.petType)

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(info.replicateInfo[1]), string.lower(searchString), 1, true)

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
        selected = info.itemLink == self.focussedLink,
      })
    end
  end

  self:GetParent().ShowingXResultsText:SetText(COLLECTIONATOR_L_SHOWING_X_RESULTS:format(#results))
  self:GetParent().ShowingXResultsText:Show()

  Collectionator.Utilities.SortByPrice(results, self.fullScan)
  self:AppendEntries(results, true)
  if self:IsVisible() then
    Auctionator.EventBus:Fire(self, Collectionator.Events.DisplayedResultsUpdated, results)
  end
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
