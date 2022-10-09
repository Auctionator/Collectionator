CollectionatorBuyFrameMixin = {}

BUY_QUERY_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_UPDATED",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
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
    self.request = ...

    self.processor = Collectionator.Buy.GetProcessor(self.request.queryType, self.request.itemLink)

    if self.processor == nil then
      return
    end

    FrameUtil.RegisterFrameForEvents(self, BUY_QUERY_EVENTS)

    self.processor:StartSearch()
    self:SetScript("OnUpdate", self.OnUpdate)
  end
end

function CollectionatorBuyFrameMixin:OnEvent(event, ...)
  if event == "ITEM_SEARCH_RESULTS_UPDATED" then
    local itemKey = ...

    if self.processor:IsExpectedItemKey(itemKey) then
      FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
      self:SetScript("OnUpdate", nil)

      local result = self.processor:GetSearchResult(itemKey)

      Auctionator.EventBus:Fire(self, self.request.returnEvent, result, self.request.returnData)
    end
  elseif event == "AUCTION_HOUSE_CLOSED" then
    FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
    self.processor = nil
    self.request = nil
  end
end

function CollectionatorBuyFrameMixin:OnUpdate()
  -- We repeatedly check for the item key being available because if it leaves
  -- the client's cache the search will fail.
  self.processor:DoItemKeyInfoCheck()
end
