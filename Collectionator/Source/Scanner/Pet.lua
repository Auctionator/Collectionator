CollectionatorPetScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorPetScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.PetLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.PetLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.PET_SCAN_STEP_SIZE
end

function CollectionatorPetScannerFrameMixin:GetSourceName()
  return "CollectionatorPetScannerFrameMixin"
end

function CollectionatorPetScannerFrameMixin:GetItem(index, link, scanInfo)
  if string.match(link, "battlepet") then
    --Caged pet
    local id = tonumber(string.match(link, "battlepet:(%d+):"))
    local petInfo = {C_PetJournal.GetPetInfoBySpeciesID(id)}

    local result = {
      id = id,
      petType = petInfo[3],
      fromProfession = string.match(petInfo[5], BATTLE_PET_SOURCE_4),
      level = Auctionator.Utilities.GetPetLevelFromLink(link),
      index = index,
      name = petInfo[1],
    }

    return result

  else
    --Uncaged pet
    local itemID = scanInfo.replicateInfo[17]
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
      name = petInfo[1] .. GRAY_FONT_COLOR:WrapTextInColorCode("; " .. scanInfo.replicateInfo[1]),
    }
  end
end
