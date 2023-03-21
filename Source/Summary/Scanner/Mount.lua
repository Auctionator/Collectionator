CollectionatorSummaryMountScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

function CollectionatorSummaryMountScannerFrameMixin:OnLoad()
  CollectionatorSummaryScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SummaryMountLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SummaryMountLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.SummaryScanMountStepSize
end

function CollectionatorSummaryMountScannerFrameMixin:GetSourceName()
  return "CollectionatorSummaryMountScannerFrameMixin"
end

function CollectionatorSummaryMountScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  local mountID = C_MountJournal.GetMountFromItem(scanInfo.itemKey.itemID)

  if not mountID then
    return
  end
  
  local sourceType = select(6, C_MountJournal.GetMountInfoByID(mountID))
  local mountType = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
  return {
    index = index,
    id = mountID,
    fromProfession = sourceType == 4, --Sourced from a profession
    mountType = mountType,
    levelRequired = select(5, GetItemInfo(scanInfo.itemKey.itemID)),
  }
end
