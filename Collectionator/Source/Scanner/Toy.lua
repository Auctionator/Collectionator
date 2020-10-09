CollectionatorToyScannerFrameMixin = {}

function CollectionatorToyScannerFrameMixin:OnLoad()
  self.toys = {}
  self.leftCount = 0

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, "CollectionatorToyScannerFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorToyScannerFrameMixin:LoadOldScan()
  local oldScan = COLLECTIONATOR_LAST_FULL_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorToyScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsVisible() then
      self:Process()
    end
  end
end

function CollectionatorToyScannerFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(
    self,
    Collectionator.Events.ToyLoadStart,
    self.toys
  )

  self.toys = {}
  self.leftCount = #self.fullScan

  self:BatchStep(1, Collectionator.Constants.SCAN_STEP_SIZE)
end

function CollectionatorToyScannerFrameMixin:GetToyInfo(index)
  local info = self.fullScan[index]
  local toyID = C_ToyBox.GetToyInfo(info.replicateInfo[17])

  table.insert(self.toys, {
    index = index,
    owned = PlayerHasToy(toyID),
    usable = C_ToyBox.IsToyUsable(toyID),
  })
end

function CollectionatorToyScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorToyScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorToyScannerFrameMixin:BatchStep", "READY", start, #self.toys)
    return
  end

  for i=start, math.min(limit, #self.fullScan) do
    local item = Item:CreateFromItemID(self.fullScan[i].replicateInfo[17])
    item:ContinueOnItemLoad(function()
      if C_ToyBox.GetToyInfo(self.fullScan[i].replicateInfo[17]) then
        self:GetToyInfo(i)
      end

      self.leftCount = self.leftCount - 1

      if self.leftCount == 0 then
        Auctionator.EventBus:Fire(
          self,
          Collectionator.Events.ToyLoadEnd,
          self.toys,
          self.fullScan
        )
      end
    end)
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end
