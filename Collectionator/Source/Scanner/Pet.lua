CollectionatorPetScannerFrameMixin = {}

function CollectionatorPetScannerFrameMixin:OnLoad()
  self.pets = {}
  self.droppedCount = 0
  self.leftCount = 0

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, "CollectionatorPetScannerFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorPetScannerFrameMixin:LoadOldScan()
  local oldScan = COLLECTIONATOR_LAST_FULL_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorPetScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsVisible() then
      self:Process()
    end
  end
end

function CollectionatorPetScannerFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(
    self,
    Collectionator.Events.PetLoadStart,
    self.pets
  )

  self.pets = {}
  self.droppedCount = 0
  self.leftCount = #self.fullScan

  self:BatchStep(1, 500)
end

function CollectionatorPetScannerFrameMixin:GetPetInfo(index, link)
  local id = tonumber(string.match(link, "battlepet:(%d+):"))
  local ownedString = C_PetJournal.GetOwnedBattlePetString(id)
  local amountOwned = 0
  if ownedString ~= nil then
    amountOwned = tonumber(string.match(ownedString, "(%d)/%d"))
  end

  local petInfo = {C_PetJournal.GetPetInfoBySpeciesID(id)}

  table.insert(self.pets, {
    id = id,
    petType = petInfo[3],
    fromProfession = string.match(petInfo[5], BATTLE_PET_SOURCE_4),
    level = Auctionator.Utilities.GetPetLevelFromLink(link),
    index = index,
    amountOwned = amountOwned,
  })
end

function CollectionatorPetScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorPetScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorPetScannerFrameMixin:BatchStep", "READY", start, #self.pets)
    return
  end

  for i=start, math.min(limit, #self.fullScan) do
    local link = self.fullScan[i].itemLink
    if string.match(link, "battlepet") then
      local item = Item:CreateFromItemID(self.fullScan[i].replicateInfo[17])
      item:ContinueOnItemLoad((function(index, link)
        return function()
          self:GetPetInfo(index, link)

          self.leftCount = self.leftCount - 1
          if self.leftCount == 0 then
            Auctionator.EventBus:Fire(
              self,
              Collectionator.Events.PetLoadEnd,
              self.pets,
              self.fullScan
            )
          end
        end
      end)(i, link))
    else
      self.leftCount = self.leftCount - 1
    end
  end

  if self.leftCount == 0 then
    Auctionator.EventBus:Fire(
      self,
      Collectionator.Events.PetLoadEnd,
      self.pets,
      self.fullScan
    )
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end
