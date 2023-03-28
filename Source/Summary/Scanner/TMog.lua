CollectionatorSummaryTMogScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

function CollectionatorSummaryTMogScannerFrameMixin:OnLoad()
  CollectionatorSummaryScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SummaryTMogLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SummaryTMogLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.SummaryScanTMogStepSize
end

function CollectionatorSummaryTMogScannerFrameMixin:GetSourceName()
  return "CollectionatorSummaryTMogScannerFrameMixin"
end

function CollectionatorSummaryTMogScannerFrameMixin:FilterItemID(itemID)
  return select(2, C_TransmogCollection.GetItemInfo(itemID))
end

function CollectionatorSummaryTMogScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  local source

  if itemKeyInfo.appearanceLink ~= nil then
    source = tonumber(itemKeyInfo.appearanceLink:match("transmogappearance:(%d+)"))
  else
    source = select(2, C_TransmogCollection.GetItemInfo(scanInfo.itemKey.itemID))
  end

  if source ~= nil and source > 0 then
    local sourceInfo = C_TransmogCollection.GetSourceInfo(source)
    local inventorySlot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
    local visual = sourceInfo.visualID

    local set = C_TransmogCollection.GetAllAppearanceSources(visual)
    if #set == 0 then
      set = {source}
    end

    local armorType = -1
    local weaponType = -1

    local itemInfo = {GetItemInfo(scanInfo.itemKey.itemID)}
    if itemInfo[12] == 4 then
      armorType = itemInfo[13]
    elseif itemInfo[12] == 2 then
      weaponType = itemInfo[13]
    end

    return {
      id = source, visual = visual, index = index, set = set,
      armor = armorType, weapon = weaponType, slot = inventorySlot,
    }

  else
    return nil
  end
end
