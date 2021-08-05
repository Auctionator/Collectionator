CollectionatorRecipeScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorRecipeScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.RecipeLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.RecipeLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.RECIPE_SCAN_STEP_SIZE
end

function CollectionatorRecipeScannerFrameMixin:GetSourceName()
  return "CollectionatorRecipeScannerFrameMixin"
end

function CollectionatorRecipeScannerFrameMixin:FilterLink(link)
  return select(6, GetItemInfoInstant(link)) == Enum.ItemClass.Recipe
end

function CollectionatorRecipeScannerFrameMixin:GetItem(index, link, scanInfo)
  local spellID = COLLECTIONATOR_RECIPES_TO_IDS[scanInfo.replicateInfo[17]]

  if spellID then
    return {
      index = index,
      id = spellID,
    }
  end
end
