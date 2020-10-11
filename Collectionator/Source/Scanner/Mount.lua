CollectionatorMountScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorMountScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.MountLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.MountLoadEnd
  self.SCAN_STEP =  1000
end

function CollectionatorMountScannerFrameMixin:GetSourceName()
  return "CollectionatorMountScannerFrameMixin"
end

function CollectionatorMountScannerFrameMixin:GetItem(index, link, scanInfo)
  local mountID = C_MountJournal.GetMountFromItem(scanInfo.replicateInfo[17])

  if not mountID then
    return
  end
  return {
    index = index,
    id = mountID,
    usable = not select(11, C_MountJournal.GetMountInfoByID(mountID)),
  }
end
