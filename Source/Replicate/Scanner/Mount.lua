CollectionatorReplicateMountScannerFrameMixin = CreateFromMixins(CollectionatorReplicateScannerFrameMixin)

function CollectionatorReplicateMountScannerFrameMixin:OnLoad()
  CollectionatorReplicateScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.MountLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.MountLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.MOUNT_SCAN_STEP_SIZE
end

function CollectionatorReplicateMountScannerFrameMixin:GetSourceName()
  return "CollectionatorReplicateMountScannerFrameMixin"
end

function CollectionatorReplicateMountScannerFrameMixin:GetItem(index, link, scanInfo)
  local mountID = C_MountJournal.GetMountFromItem(scanInfo.replicateInfo[17])

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
    levelRequired = select(5, GetItemInfo(link)),
  }
end
