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
    if self.processor ~= nil then
      Auctionator.EventBus:Fire(self, Collectionator.Events.BuyQueryRequestAborted, self.request.returnEvent, self.request.returnData)
    end
    self.request = ...

    self.processor = Collectionator.Buy.GetProcessor(self.request.queryType, self.request.itemLink)

    if self.processor == nil then
      return
    end

    FrameUtil.RegisterFrameForEvents(self, BUY_QUERY_EVENTS)

    print("start")
    self.processor:PrepareSearch()
    self:AttemptSend()
  end
end

function CollectionatorBuyFrameMixin:AttemptSend()
  if self.processor:IsReady() then
    print("clear")
    self:SetScript("OnUpdate", nil)
    self.processor:Send()
  else
    print("soue")
    self:SetScript("OnUpdate", self.OnUpdate)
  end
end

function CollectionatorBuyFrameMixin:OnEvent(event, ...)
  if event == "ITEM_SEARCH_RESULTS_UPDATED" then
    local itemKey = ...

    print("isru", Auctionator.Utilities.ItemKeyString(itemKey), C_AuctionHouse.HasSearchResults(itemKey), C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1))

    if self.processor:IsExpectedItemKey(itemKey) then

      local has = C_AuctionHouse.HasSearchResults(itemKey)
      local full = C_AuctionHouse.HasFullItemSearchResults(itemKey)
      local quantity = C_AuctionHouse.GetItemSearchResultsQuantity(itemKey)

      local result = self.processor:GetSearchResult(itemKey)

      -- Check for supposedly having results when not all results are loaded and
      -- there is 0 loaded.
      if has and not full and quantity == 0 then
        print("rereq")
        self.processor:Send()
        --self:AttemptSend()
      -- Now we actually have results
      elseif has then
        FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
        self:SetScript("OnUpdate", nil)
        Auctionator.AH.GetItemKeyInfo(itemKey, function(itemKeyInfo)
          print("expected " .. itemKeyInfo.itemName .. " " .. Auctionator.Utilities.ItemKeyString(itemKey) .. " " .. tostring(result ~= nil) .. " ".. tostring(has) .. " " .. tostring(full) .. " " .. tostring(quantity))
        end)
        self.processor = nil
        Auctionator.EventBus:Fire(self, self.request.returnEvent, result, self.request.returnData)
      -- Maybe not
      else
        print("miss has")
        self:AttemptSend()
      end
    end
  elseif event == "AUCTION_HOUSE_CLOSED" then
    FrameUtil.UnregisterFrameForEvents(self, BUY_QUERY_EVENTS)
    self:SetScript("OnUpdate", nil)
    self.processor = nil
    self.request = nil
  end
end

function CollectionatorBuyFrameMixin:OnUpdate()
  print("update")
  self:AttemptSend()
end
