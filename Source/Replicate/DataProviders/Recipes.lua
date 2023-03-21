local RECIPE_TABLE_LAYOUT = {
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

CollectionatorReplicateRecipeDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function CollectionatorReplicateRecipeDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Collectionator.Events.RecipeLoadStart,
    Collectionator.Events.RecipeLoadEnd,
    Collectionator.Events.RecipePurchased,
  })
  Auctionator.EventBus:RegisterSource(self, "CollectionatorReplicateRecipeDataProvider")

  self.dirty = false
  self.recipes = {}
end

function CollectionatorReplicateRecipeDataProviderMixin:OnShow()
  self.focussedLink = nil
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ReplicateFocusLink,
  })

  if self.dirty then
    self:Refresh()
  end
end

function CollectionatorReplicateRecipeDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Collectionator.Events.ReplicateFocusLink,
  })
end

function CollectionatorReplicateRecipeDataProviderMixin:ReceiveEvent(eventName, eventData, eventData2)
  if eventName == Collectionator.Events.RecipeLoadStart then
    self:Reset()
    self.onSearchStarted()
    self:GetParent().NoFullScanText:Hide()
    self:GetParent().ShowingXResultsText:Hide()
  elseif eventName == Collectionator.Events.RecipeLoadEnd then
    self.recipes = eventData
    self.fullScan = eventData2

    self.dirty = true
    if self:IsVisible() then
      self:Refresh()
    end
  elseif eventName == Collectionator.Events.RecipePurchased then
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

function CollectionatorReplicateRecipeDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function CollectionatorReplicateRecipeDataProviderMixin:Refresh()
  if self.dirty then
    self.onPreserveScroll()
  else
    self.onResetScroll()
  end

  self.dirty = false
  self:Reset()

  self.onSearchStarted()

  local filtered = Collectionator.Utilities.ReplicateExtractWantedItems(Collectionator.Utilities.ReplicateGroupedByID(self.recipes, self.fullScan), self.fullScan)
  local results = {}

  -- Filter recipes
  for _, recipeInfo in ipairs(filtered) do
    local info = self.fullScan[recipeInfo.index]

    local check = true

    local searchString = self:GetParent().TextFilter:GetText()
    check = check and string.find(string.lower(info.replicateInfo[1]), string.lower(searchString), 1, true)

    local usableState = self:GetParent().Usable:GetValue()

    if usableState == Collectionator.Constants.RecipesUsableOption.PreviousCharacter then
      check = check and COLLECTIONATOR_RECIPES_CACHE.couldKnow[recipeInfo.id] ~= nil
    elseif usableState == Collectionator.Constants.RecipesUsableOption.CurrentRealmAndFaction then
      local couldKnow = COLLECTIONATOR_RECIPES_CACHE.couldKnow[recipeInfo.id]
      check = check and couldKnow ~= nil and tIndexOf(couldKnow, Collectionator.Utilities.GetRealmAndFaction()) ~= nil
    end

    if not self:GetParent().IncludeCollected:GetChecked() then
      check = check and not COLLECTIONATOR_RECIPES_CACHE.known[recipeInfo.id] and not Collectionator.State.Purchases.Recipes[recipeInfo.id]
    end

    check = check and self:GetParent().ProfessionFilter:GetValue(recipeInfo.subClassID)
    check = check and self:GetParent().QualityFilter:GetValue(info.replicateInfo[4])

    if check then
      table.insert(results, {
        index = recipeInfo.index,
        itemName = Collectionator.Utilities.ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = recipeInfo.quantity,
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

function CollectionatorReplicateRecipeDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function CollectionatorReplicateRecipeDataProviderMixin:GetTableLayout()
  return RECIPE_TABLE_LAYOUT
end

Auctionator.Config.Create("COLLECTIONATOR_COLUMNS_RECIPE", "collectionator_columns_recipe", {})

function CollectionatorReplicateRecipeDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_COLUMNS_RECIPE)
end

function CollectionatorReplicateRecipeDataProviderMixin:GetRowTemplate()
  return "CollectionatorReplicateToyMountRowTemplate"
end
