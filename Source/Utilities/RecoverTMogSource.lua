local modelScene
if Auctionator.Constants.IsRetail then
  modelScene = CreateFrame("ModelScene", nil, UIParent, "ModelSceneMixinTemplate")
  modelScene:TransitionToModelSceneID(596, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true)
  modelScene:Hide()
  local frame = CreateFrame("Frame")
  frame:SetScript("OnUpdate", function()
    if(modelScene:GetPlayerActor():SetModelByUnit("player")) then
      frame:SetScript("OnUpdate", nil)
    end
  end)
end

function Collectionator.Utilities.RecoverTMogSource(itemID)
  local possible = select(2, C_TransmogCollection.GetItemInfo(itemID))
  if possible then
    return possible
  end
  if Auctionator.Constants.IsRetail and C_Item.IsDressableItemByID and C_Item.IsDressableItemByID(itemID) then
    local pa = modelScene:GetPlayerActor()
    local invType = select(4, C_Item.GetItemInfoInstant(itemID))
    local mainhandOverride = invType == "INVTYPE_WEAPON" or invType == "INVTYPE_RANGEDRIGHT"
    local slot = Collectionator.Constants.SlotMap[invType]
    if slot then
      local link = select(2, C_Item.GetItemInfo(itemID))
      local result
      if mainhandOverride then
        result = pa:TryOn(link, "MAINHANDSLOT")
      else
        result = pa:TryOn(link)
      end
      if result == Enum.ItemTryOnReason.Success then
        local info = pa:GetItemTransmogInfo(slot)
        if info then
          return info.appearanceID
        end
      end
    end
  end
end
