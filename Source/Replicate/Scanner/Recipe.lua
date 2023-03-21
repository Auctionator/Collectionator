CollectionatorReplicateRecipeScannerFrameMixin = CreateFromMixins(CollectionatorReplicateScannerFrameMixin)

function CollectionatorReplicateRecipeScannerFrameMixin:OnLoad()
  CollectionatorReplicateScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.RecipeLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.RecipeLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.RECIPE_SCAN_STEP_SIZE
end

function CollectionatorReplicateRecipeScannerFrameMixin:GetSourceName()
  return "CollectionatorReplicateRecipeScannerFrameMixin"
end

function CollectionatorReplicateRecipeScannerFrameMixin:FilterLink(link)
  return select(6, GetItemInfoInstant(link)) == Enum.ItemClass.Recipe
end

function CollectionatorReplicateRecipeScannerFrameMixin:GetItem(index, link, scanInfo)
  local spellID = COLLECTIONATOR_RECIPES_TO_IDS[scanInfo.replicateInfo[17]]

  if spellID then
    local subClassID = select(13, GetItemInfo(link))
    return {
      index = index,
      id = spellID,
      subClassID = subClassID,
    }
  end
end
