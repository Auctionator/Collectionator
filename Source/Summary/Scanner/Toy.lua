CollectionatorSummaryToyScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

function CollectionatorSummaryToyScannerFrameMixin:OnLoad()
  CollectionatorSummaryScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SummaryToyLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SummaryToyLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.SummaryScanToyStepSize
end

function CollectionatorSummaryToyScannerFrameMixin:GetSourceName()
  return "CollectionatorSummaryToyScannerFrameMixin"
end

function CollectionatorSummaryToyScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  if not C_ToyBox.GetToyInfo(scanInfo.itemKey.itemID) then
    return
  end

  local toyID = C_ToyBox.GetToyInfo(scanInfo.itemKey.itemID)

  return {
    index = index,
    id = toyID,
    usable = C_ToyBox.IsToyUsable(toyID),
  }
end
