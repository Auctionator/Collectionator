CollectionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function CollectionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorFullScanFrameMixin:OnLoad")
  Auctionator.EventBus:RegisterSource(self, "CollectionatorFullScanFrameMixin")
end

function CollectionatorFullScanFrameMixin:ResetData()
  self.scanData = {}
end

function CollectionatorFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
    Auctionator.EventBus:Fire(self, Collectionator.FullScan.Events.ScanStart)

    COLLECTIONATOR_SCAN_TIME = time()

    self.inProgress = true

    self:RegisterForEvents()
    Collectionator.Utilities.Message(AUCTIONATOR_L_STARTING_FULL_SCAN)
    C_AuctionHouse.ReplicateItems()
    -- 10% complete after making the replicate request
    Auctionator.EventBus:Fire(self, Collectionator.FullScan.Events.ScanProgress, 0.1)
  else
    Collectionator.Utilities.Message(self:NextScanMessage())
  end
end

function CollectionatorFullScanFrameMixin:CanInitiate()
  return
   ( COLLECTIONATOR_SCAN_TIME ~= nil and
     time() - COLLECTIONATOR_SCAN_TIME > 60 * 15 and
     not self.inProgress
   ) or COLLECTIONATOR_SCAN_TIME == nil
end

function CollectionatorFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - COLLECTIONATOR_SCAN_TIME
  local minutesUntilNextScan = 15 - math.ceil(timeSinceLastScan / 60)
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return COLLECTIONATOR_L_NEXT_SCAN_MESSAGE:format(minutesUntilNextScan, secondsUntilNextScan)
end

function CollectionatorFullScanFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("CollectionatorFullScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function CollectionatorFullScanFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("CollectionatorFullScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function CollectionatorFullScanFrameMixin:CacheScanData()
  -- 20% complete after server response
  Auctionator.EventBus:Fire(self, Collectionator.FullScan.Events.ScanProgress, 0.2)

  self:ResetData()
  self.waitingForData = C_AuctionHouse.GetNumReplicateItems()

  self:ProcessBatch(
    0,
    250,
    self.waitingForData
  )
end

function CollectionatorFullScanFrameMixin:ProcessBatch(startIndex, stepSize, limit)
  if startIndex >= limit then
    return
  end

  -- 20-100% complete when 0-100% through caching the scan
  Auctionator.EventBus:Fire(self,
    Collectionator.FullScan.Events.ScanProgress,
    0.2 + startIndex/limit*0.8
  )

  Auctionator.Debug.Message("CollectionatorFullScanFrameMixin:ProcessBatch (links)", startIndex, stepSize, limit)

  local i = startIndex
  while i < startIndex+stepSize and i < limit do
    local info = { C_AuctionHouse.GetReplicateItemInfo(i) }
    local link = C_AuctionHouse.GetReplicateItemLink(i)
    local timeLeft = C_AuctionHouse.GetReplicateItemTimeLeft(i)

    if not info[18] then
      ItemEventListener:AddCallback(info[17], (function(index)
        return function()
          self.waitingForData = self.waitingForData - 1

          table.insert(self.scanData, {
            replicateInfo = { C_AuctionHouse.GetReplicateItemInfo(index) },
            itemLink      = C_AuctionHouse.GetReplicateItemLink(index),
            timeLeft      = C_AuctionHouse.GetReplicateItemTimeLeft(index)
          })

          if self.waitingForData == 0 then
            self:EndProcessing()
          end
        end
      end)(i))
    else
      self.waitingForData = self.waitingForData - 1
      table.insert(self.scanData, {
        replicateInfo = info,
        itemLink      = link,
        timeLeft      = timeLeft
      })
    end

    i = i + 1
  end

  C_Timer.After(0.01, function()
    self:ProcessBatch(startIndex + stepSize, stepSize, limit)
  end)

  if self.waitingForData == 0 then
    self:EndProcessing()
  end
end

function CollectionatorFullScanFrameMixin:OnEvent(event, ...)
  if event == "REPLICATE_ITEM_LIST_UPDATE" then
    Auctionator.Debug.Message("REPLICATE_ITEM_LIST_UPDATE")

    FrameUtil.UnregisterFrameForEvents(self, { "REPLICATE_ITEM_LIST_UPDATE" })
    self:CacheScanData()
  elseif event =="AUCTION_HOUSE_CLOSED" then
    self:UnregisterForEvents()

    if self.inProgress then
      self.inProgress = false
      self:ResetData()

      Collectionator.Utilities.Message(
        COLLECTIONATOR_L_SCAN_FAILED
      )
      Auctionator.EventBus:Fire(self, Collectionator.FullScan.Events.ScanFailed)
    end
  end
end

function CollectionatorFullScanFrameMixin:EndProcessing()
  local rawFullScan = self.scanData

  Collectionator.Utilities.Message(COLLECTIONATOR_L_COMPLETED_SCAN)

  self.inProgress = false
  self:ResetData()

  self:UnregisterForEvents()

  Auctionator.EventBus:Fire(self, Collectionator.FullScan.Events.ScanComplete, rawFullScan)
end
