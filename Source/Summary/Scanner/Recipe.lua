CollectionatorSummaryRecipeScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

function CollectionatorSummaryRecipeScannerFrameMixin:OnLoad()
  CollectionatorSummaryScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SummaryRecipeLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SummaryRecipeLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.SummaryScanRecipeStepSize
end

function CollectionatorSummaryRecipeScannerFrameMixin:GetSourceName()
  return "CollectionatorSummaryRecipeScannerMixin"
end

function CollectionatorSummaryRecipeScannerFrameMixin:FilterItemID(itemID)
  return select(6, GetItemInfoInstant(itemID)) == Enum.ItemClass.Recipe
end

function CollectionatorSummaryRecipeScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  local spellID = COLLECTIONATOR_RECIPES_TO_IDS[scanInfo.itemKey.itemID]

  if spellID then
    local subClassID = select(13, GetItemInfo(scanInfo.itemKey.itemID))
    return {
      index = index,
      id = spellID,
      subClassID = subClassID,
    }
  end
end
