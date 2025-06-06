CollectionatorReplicateTMogScannerFrameMixin = CreateFromMixins(CollectionatorReplicateScannerFrameMixin)

function CollectionatorReplicateTMogScannerFrameMixin:OnLoad()
  CollectionatorReplicateScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SourceLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SourceLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.TMOG_SCAN_STEP_SIZE
end

function CollectionatorReplicateTMogScannerFrameMixin:GetSourceName()
  return "CollectionatorReplicateTMogScannerFrameMixin"
end

function CollectionatorReplicateTMogScannerFrameMixin:FilterLink(link)
  local itemID, _, _, invType = C_Item.GetItemInfoInstant(link)
  return itemID and invType ~= "INVTYPE_NON_EQUIP"
end

function CollectionatorReplicateTMogScannerFrameMixin:GetItem(index, link, scanInfo)
  local _, source = C_TransmogCollection.GetItemInfo(link)
  if source == nil then
    source = Collectionator.Utilities.RecoverTMogSource(C_Item.GetItemInfoInstant(link))
  end

  if source ~= nil then
    local sourceInfo = C_TransmogCollection.GetSourceInfo(source)
    local inventorySlot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
    local visual = sourceInfo.visualID

    local set = C_TransmogCollection.GetAllAppearanceSources(visual)
    if #set == 0 then
      set = {source}
    end

    local armorType = -1
    local weaponType = -1

    local itemInfo = {C_Item.GetItemInfo(link)}
    if itemInfo[12] == 4 then
      armorType = itemInfo[13]
    elseif itemInfo[12] == 2 then
      weaponType = itemInfo[13]
    end

    return {
      id = source, visual = visual, index = index, set = set,
      armor = armorType, weapon = weaponType, slot = inventorySlot,
      levelRequired = itemInfo[5],
    }

  else
    return nil
  end
end
