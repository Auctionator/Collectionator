CollectionatorSummaryTMogScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

local modelScene
modelScene = CreateFrame("ModelScene", nil, UIParent, "ModelSceneMixinTemplate")
modelScene:TransitionToModelSceneID(596, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true)
modelScene:Hide()
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
  if(modelScene:GetPlayerActor():SetModelByUnit("player")) then
    frame:SetScript("OnUpdate", nil)
  end
end)

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
  local invType = select(4, C_Item.GetItemInfoInstant(itemID))
  return invType ~= "INVTYPE_NON_EQUIP" and invType ~= "INVTYPE_NON_EQUIP_IGNORE"
end

function CollectionatorSummaryTMogScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  local source

  if itemKeyInfo.appearanceLink ~= nil then
    source = tonumber(itemKeyInfo.appearanceLink:match("transmogappearance:(%d+)"))
  else
    source = select(2, C_TransmogCollection.GetItemInfo(scanInfo.itemKey.itemID))
  end

  if not source and C_Item.IsDressableItemByID(scanInfo.itemKey.itemID) then
    local pa = modelScene:GetPlayerActor()
    local invType = select(4, C_Item.GetItemInfoInstant(scanInfo.itemKey.itemID))
    local mainhandOverride = invType == "INVTYPE_WEAPON" or invType == "INVTYPE_RANGEDRIGHT"
    local slot = Collectionator.Constants.SlotMap[invType]
    if slot then
      local link = select(2, C_Item.GetItemInfo(scanInfo.itemKey.itemID))
      local result
      if mainhandOverride then
        result = pa:TryOn(link, "MAINHANDSLOT")
      else
        result = pa:TryOn(link)
      end
      if result == Enum.ItemTryOnReason.Success then
        local info = pa:GetItemTransmogInfo(slot)
        if info then
          source = info.appearanceID
        end
      end
    end
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

    local itemInfo = {C_Item.GetItemInfo(scanInfo.itemKey.itemID)}
    if itemInfo[12] == 4 then
      armorType = itemInfo[13]
    elseif itemInfo[12] == 2 then
      weaponType = itemInfo[13]
    end

    local replacementItemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(source))

    return {
      id = source, visual = visual, index = index, set = set,
      armor = armorType, weapon = weaponType, slot = inventorySlot,
      levelRequired = C_AuctionHouse.GetItemKeyRequiredLevel(scanInfo.itemKey) or 0,
      itemID = scanInfo.itemKey.itemID,
      replacementItemLink = replacementItemLink,
    }

  else
    return nil
  end
end
