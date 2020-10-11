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

function CollectionatorPetScannerFrameMixin:FilterLink(link)
  return string.match(link, "battlepet")
end

function CollectionatorPetScannerFrameMixin:GetItem(index, link, scanInfo)
  local id = tonumber(string.match(link, "battlepet:(%d+):"))
  local ownedString = C_PetJournal.GetOwnedBattlePetString(id)
  local amountOwned = 0
  if ownedString ~= nil then
    amountOwned = tonumber(string.match(ownedString, "(%d)/%d"))
  end

  local petInfo = {C_PetJournal.GetPetInfoBySpeciesID(id)}

  return {
    id = id,
    petType = petInfo[3],
    fromProfession = string.match(petInfo[5], BATTLE_PET_SOURCE_4),
    level = Auctionator.Utilities.GetPetLevelFromLink(link),
    index = index,
    amountOwned = amountOwned,
  }
end
