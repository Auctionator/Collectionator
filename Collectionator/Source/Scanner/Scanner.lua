CollectionatorScannerFrameMixin = {}

function CollectionatorScannerFrameMixin:OnLoad()
  self.results = {}
  self.leftCount = 0

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, self.GetSourceName())
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsVisible() then
      self:Process()
    end
  end
end

function CollectionatorScannerFrameMixin:LoadOldScan()
  local oldScan = PRESERVE_AUCTIONATOR_AH_SCAN_LAST_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorScannerFrameMixin:Refresh()
  if self.leftCount == 0 then
    self.dirty = true
    self:Process()
  end
end


function CollectionatorScannerFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(self, self.SCAN_START_EVENT)

  self.results = {}
  self.leftCount = #self.fullScan

  self:BatchStep(1, self.SCAN_STEP)
end

function CollectionatorScannerFrameMixin:FilterLink(link)
  return true
end

function CollectionatorScannerFrameMixin:GetItem(index, link)
  return {}
end

function CollectionatorScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorScannerFrameMixin:BatchStep", "READY", start, #self.results)
    return
  end

  for i=start, math.min(limit, #self.fullScan) do
    local link = self.fullScan[i].itemLink

    if self:FilterLink(link) then
      ItemEventListener:AddCallback(self.fullScan[i].replicateInfo[17], (function(index, link)
        return function()
          local result = self:GetItem(index, link, self.fullScan[index])
          if result ~= nil then
            table.insert(self.results, result)
          end

          self.leftCount = self.leftCount - 1
          if self.leftCount == 0 then
            Auctionator.EventBus:Fire(
              self, self.SCAN_END_EVENT, self.results, self.fullScan
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
      self, self.SCAN_END_EVENT, self.results, self.fullScan
    )
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end
