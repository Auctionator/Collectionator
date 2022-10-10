CollectionatorBuyFrameMixin = {}

BUY_QUERY_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
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

    print("start")
    self.processor:PrepareSearch()
    self.processor:Send()
    self:SetScript("OnUpdate", self.OnUpdate)
  end
end

function CollectionatorBuyFrameMixin:OnEvent(event, ...)
  if event == "ITEM_SEARCH_RESULTS_UPDATED" then
    local itemKey = ...

    print("isru", Auctionator.Utilities.ItemKeyString(itemKey), C_AuctionHouse.HasSearchResults(itemKey), C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1))

    if C_AuctionHouse.HasSearchResults(itemKey) and self.processor:IsExpectedItemKey(itemKey) then
      FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
      self:SetScript("OnUpdate", nil)

      local result = self.processor:GetSearchResult(itemKey)
      print("expected", result ~= nil)

      Auctionator.EventBus:Fire(self, self.request.returnEvent, result, self.request.returnData)
    end
  elseif event == "AUCTION_HOUSE_CLOSED" then
    FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
    self:SetScript("OnUpdate", nil)
    self.processor = nil
    self.request = nil
  end
end

function CollectionatorBuyFrameMixin:OnUpdate()
  self.processor:Send()
end
