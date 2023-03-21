CollectionatorSummaryBuyFrameMixin = {}

local AH_BUY_EVENTS = {
  Auctionator.AH.Events.ItemSearchResultsReady
}

local CLOSE_EVENTS = {
  "AUCTION_HOUSE_CLOSED",
}

function CollectionatorSummaryBuyFrameMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryBuyFrameMixin")
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryBuyQueryRequest,
  })
end

function CollectionatorSummaryBuyFrameMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.SummaryBuyQueryRequest then
    if self.processor ~= nil then
      Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryBuyQueryRequestAborted, self.request.returnEvent, self.request.returnData)
    end
    self.request = ...

    self.processor = Collectionator.Summary.Buy.GetProcessor(self.request.queryType, self.request.itemKey, self.request.itemKeyInfo)

    if self.processor == nil then
      return
    end

    Auctionator.EventBus:Register(self, AH_BUY_EVENTS)
    FrameUtil.RegisterFrameForEvents(self, CLOSE_EVENTS)

    self.processor:Send()
  elseif event == Auctionator.AH.Events.ItemSearchResultsReady then
    local itemKey = ...

    if self.processor and self.processor:IsExpectedItemKey(itemKey) then
      local result = self.processor:GetSearchResult(itemKey)
      Auctionator.EventBus:Unregister(self, AH_BUY_EVENTS)
      FrameUtil.UnregisterFrameForEvents(self, CLOSE_EVENTS)
      self.processor = nil
      Auctionator.EventBus:Fire(self, self.request.returnEvent, result, self.request.returnData)
    end
  end
end

function CollectionatorSummaryBuyFrameMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_CLOSED" then
    Auctionator.EventBus:Unregister(self, AH_BUY_EVENTS)
    FrameUtil.UnregisterFrameForEvents(self, CLOSE_EVENTS)
    self.processor = nil
    self.request = nil
  end
end
