CollectionatorSummaryScannerFrameMixin = {}

function CollectionatorSummaryScannerFrameMixin:OnLoad()
  self.results = {}
  self.leftCount = 0

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, self.GetSourceName())
  Auctionator.EventBus:Register(self, {
    Auctionator.IncrementalScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorSummaryScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.IncrementalScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsVisible() then
      self:Process()
    end
  end
end

function CollectionatorSummaryScannerFrameMixin:LoadOldScan()
  local oldScan = PRESERVE_AUCTIONATOR_AH_SCAN_LAST_SUMMARY
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorSummaryScannerFrameMixin:Refresh()
  if self.leftCount == 0 then
    self.dirty = true
    self:Process()
  end
end


function CollectionatorSummaryScannerFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(self, self.SCAN_START_EVENT)

  self.results = {}
  self.leftCount = #self.fullScan

  self:BatchStep(1, self.SCAN_STEP)
end

function CollectionatorSummaryScannerFrameMixin:FilterItemID(itemID)
  return true
end

function CollectionatorSummaryScannerFrameMixin:GetItem(index, itemKeyInfo, scanInfo)
  return {}
end

local function GlobalFilterItemID(itemID)
  if not C_Item.DoesItemExistByID(itemID) then
    return false
  end

  local classID, subClassID = select(6, C_Item.GetItemInfoInstant(itemID))
  if classID == nil then
    return true
  end
  return classID ~= Enum.ItemClass.Tradegoods
end

function CollectionatorSummaryScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorSummaryScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorSummaryScannerFrameMixin:BatchStep", "READY", start, #self.results)
    -- Special case, sometimes the Blizzard APIs don't return item data, this is
    -- a fallback in that case
    self.timer = C_Timer.NewTimer(2, function()
      if self.leftCount > 0 then
        self.leftCount = 0
        Auctionator.EventBus:Fire(
          self, self.SCAN_END_EVENT, self.results, self.fullScan
        )
      end
      self.timer = nil
    end)
    return
  end

  local actualLimit = math.min(limit, #self.fullScan)
  local i = start
  while i <= actualLimit do
    local info = self.fullScan[i]
    local itemID = info.itemKey.itemID

    if GlobalFilterItemID(itemID) then
      if self:FilterItemID(itemID) then
        Auctionator.AH.GetItemKeyInfo(self.fullScan[i].itemKey, (function(index)
          return function(itemKeyInfo)
            local item = Item:CreateFromItemID(itemID)
            item:ContinueOnItemLoad(function()
              local result = self:GetItem(index, itemKeyInfo, info)
              if result ~= nil then
                result.itemKeyInfo = itemKeyInfo
                table.insert(self.results, result)
              end

              self.leftCount = self.leftCount - 1
              if self.leftCount == 0 then
                Auctionator.EventBus:Fire(
                  self, self.SCAN_END_EVENT, self.results, self.fullScan
                )
                if self.timer then
                  self.timer:Cancel()
                  self.timer = nil
                end
              end
            end)
          end
        end)(i))
      else
        self.leftCount = self.leftCount - 1
      end
    else
      actualLimit = math.min(actualLimit + 1, #self.fullScan)
      self.leftCount = self.leftCount - 1
    end
    i = i + 1
  end
  if self.leftCount == 0 then
    Auctionator.EventBus:Fire(
      self, self.SCAN_END_EVENT, self.results, self.fullScan
    )
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
    end
  end

  C_Timer.After(0.01, function()
    self:BatchStep(actualLimit + 1, actualLimit + 1 + (limit-start))
  end)
end
