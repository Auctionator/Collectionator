CollectionatorMountScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorMountScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.MountLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.MountLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.MOUNT_SCAN_STEP_SIZE
end

function CollectionatorMountScannerFrameMixin:GetSourceName()
  return "CollectionatorMountScannerFrameMixin"
end

function CollectionatorMountScannerFrameMixin:GetItem(index, link, scanInfo)
  local mountID = C_MountJournal.GetMountFromItem(scanInfo.replicateInfo[17])

  if not mountID then
    return
  end
  
  local sourceType = select(6, C_MountJournal.GetMountInfoByID(mountID))
  local mountType = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
  return {
    index = index,
    id = mountID,
    usable = not select(11, C_MountJournal.GetMountInfoByID(mountID)),
    fromProfession = sourceType == 4, --Sourced from a profession
    mountType = mountType,
    levelRequired = select(5, GetItemInfo(link)),
  }
end
