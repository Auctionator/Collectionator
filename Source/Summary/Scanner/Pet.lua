CollectionatorSummaryPetScannerFrameMixin = CreateFromMixins(CollectionatorSummaryScannerFrameMixin)

function CollectionatorSummaryPetScannerFrameMixin:OnLoad()
  CollectionatorSummaryScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SummaryPetLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SummaryPetLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.SummaryScanPetStepSize
end

function CollectionatorSummaryPetScannerFrameMixin:GetSourceName()
  return "CollectionatorSummaryPetScannerFrameMixin"
end

function CollectionatorSummaryPetScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  if scanInfo.itemKey.battlePetSpeciesID ~= 0 then
    --Caged pet
    local id = scanInfo.itemKey.battlePetSpeciesID
    local petInfo = {C_PetJournal.GetPetInfoBySpeciesID(id)}

    local result = {
      id = id,
      petType = petInfo[3],
      fromProfession = string.match(petInfo[5], BATTLE_PET_SOURCE_4),
      index = index,
      name = petInfo[1],
    }

    return result

  else
    --Uncaged pet
    local itemID = scanInfo.itemKey.itemID
    local petInfo = {C_PetJournal.GetPetInfoByItemID(itemID)}
    if #petInfo == 0 then
      return
    end

    return {
      id = petInfo[13],
      petType = petInfo[3],
      fromProfession = string.match(petInfo[5], BATTLE_PET_SOURCE_4),
      level = 1,
      index = index,
      name = petInfo[1] .. GRAY_FONT_COLOR:WrapTextInColorCode("; " .. itemKeyInfo.itemName),
    }
  end
end
