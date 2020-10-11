CollectionatorToyScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorToyScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.ToyLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.ToyLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.TOY_SCAN_STEP_SIZE
end

function CollectionatorToyScannerFrameMixin:GetSourceName()
  return "CollectionatorToyScannerFrameMixin"
end

function CollectionatorToyScannerFrameMixin:GetItem(index, link, scanInfo)
  if not C_ToyBox.GetToyInfo(scanInfo.replicateInfo[17]) then
    return
  end

  local toyID = C_ToyBox.GetToyInfo(scanInfo.replicateInfo[17])

  return {
    index = index,
    owned = PlayerHasToy(toyID),
    usable = C_ToyBox.IsToyUsable(toyID),
  }
end
