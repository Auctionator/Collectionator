CollectionatorTMogScannerFrameMixin = {}

function CollectionatorTMogScannerFrameMixin:OnLoad()
  self.sources = {}
  self.leftCount = 0

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, "CollectionatorTMogScannerFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorTMogScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsVisible() then
      self:Process()
    end
  end
end

function CollectionatorTMogScannerFrameMixin:LoadOldScan()
  local oldScan = COLLECTIONATOR_LAST_FULL_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorTMogScannerFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(
    self,
    Collectionator.Events.SourceLoadStart
  )

  self.sources = {}
  self.leftCount = #self.fullScan

  self:BatchStep(1, Collectionator.Constants.TMOG_SCAN_STEP_SIZE)
end

function CollectionatorTMogScannerFrameMixin:GetItemSource(index, link)
  local _, source = C_TransmogCollection.GetItemInfo(link)

  if source ~= nil then
    local visual = C_TransmogCollection.GetSourceInfo(source).visualID
    local set = C_TransmogCollection.GetAllAppearanceSources(visual)
    if #set == 0 then
      set = {source}
    end
    table.insert(self.sources, {
      id = source, visual = visual, index = index, set = set,
      levelRequired = select(5, GetItemInfo(link)),
    })
    return
  end
end

function CollectionatorTMogScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorTMogScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorTMogScannerFrameMixin:BatchStep", "READY", start, #self.sources)
    return
  end

  for i=start, math.min(limit, #self.fullScan) do
    local link = self.fullScan[i].itemLink

    local item = Item:CreateFromItemID(self.fullScan[i].replicateInfo[17])
    item:ContinueOnItemLoad((function(index, link)
      return function()
        self:GetItemSource(index, link)

        self.leftCount = self.leftCount - 1
        if self.leftCount == 0 then
          Auctionator.EventBus:Fire(
            self,
            Collectionator.Events.SourceLoadEnd,
            self.sources,
            self.fullScan
          )
        end
      end
    end)(i, link))
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end
