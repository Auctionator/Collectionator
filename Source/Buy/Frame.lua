CollectionatorBuyFrameMixin = {}

local AH_BUY_EVENTS = {
  Auctionator.AH.Events.ItemSearchResultsReady
}

local CLOSE_EVENTS = {
  "AUCTION_HOUSE_CLOSED",
}

function CollectionatorBuyFrameMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorBuyFrameMixin")
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.BuyQueryRequest,
  })
end

function CollectionatorBuyFrameMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.BuyQueryRequest then
    if self.processor ~= nil then
      Auctionator.EventBus:Fire(self, Collectionator.Events.BuyQueryRequestAborted, self.request.returnEvent, self.request.returnData)
    end
    self.request = ...

    self.processor = Collectionator.Buy.GetProcessor(self.request.queryType, self.request.itemLink)

    if self.processor == nil then
      return
    end

    Auctionator.EventBus:Register(self, AH_BUY_EVENTS)
    FrameUtil.RegisterFrameForEvents(self, CLOSE_EVENTS)

    self.processor:PrepareSearch()
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

function CollectionatorBuyFrameMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_CLOSED" then
    Auctionator.EventBus:Unregister(self, AH_BUY_EVENTS)
    FrameUtil.UnregisterFrameForEvents(self, CLOSE_EVENTS)
    self.processor = nil
    self.request = nil
  end
end
