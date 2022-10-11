EVENT_BUS_EVENTS = {
  Collectionator.Events.CheapestResultReturn,
  Collectionator.Events.BuyQueryRequestAborted,
  Collectionator.Events.SourceLoadStart,
  Collectionator.Events.PetLoadStart,
  Collectionator.Events.ToyLoadStart,
  Collectionator.Events.MountLoadStart,
  Collectionator.Events.RecipeLoadStart,
  Collectionator.Events.DisplayedResultsUpdated,
}

CollectionatorBuyCheapestMixin = {}

function CollectionatorBuyCheapestMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorBuyCheapestMixin")
  self:Reset()
end

function CollectionatorBuyCheapestMixin:Reset()
  self.focussed = nil
  self.purchaseData = nil
  self.results = nil
  self.offset = 1
  self.SkipButton:Disable()
  self.BuyButton:Enable()
  self:UpdateActionText(COLLECTIONATOR_L_LOAD_FOR_PURCHASING)
end

function CollectionatorBuyCheapestMixin:Focus()
  local oldLink = self.focussed and self.focussed.itemLink
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
  end

  if self.focussed ~= nil then
    local currentLink = self.focussed and self.focussed.itemLink
    if currentLink ~= oldLink then
      Auctionator.EventBus:Fire(self, Collectionator.Events.FocusLink, currentLink)
      self:Query()
    end
  else
    self.BuyButton:Disable()
    self.SkipButton:Disable()
    self:UpdateActionText(COLLECTIONATOR_L_NO_ITEMS_LEFT)
  end
end

function CollectionatorBuyCheapestMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)
  self:Reset()
  Auctionator.EventBus:Fire(self, Collectionator.Events.FocusLink, nil)
end

function CollectionatorBuyCheapestMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)
end

function CollectionatorBuyCheapestMixin:UpdateActionText(text)
  self.BuyButton:SetText(text)
  DynamicResizeButton_Resize(self.BuyButton)
end

function CollectionatorBuyCheapestMixin:BuyOrStart()
  -- Nothing focussed or queried yet
  if not self.focussed or not self.purchaseData then
    self:Focus()

  -- Item focussed and queried, attempt to buy
  else
    self.SkipButton:Disable()
    self.BuyButton:Disable()
    self:UpdateActionText(COLLECTIONATOR_L_PROCESSING)

    Auctionator.EventBus:Fire(self, Collectionator.Events.PurchaseAttempted, self.purchaseData.auctionID, self.purchaseData.itemLink)
    C_AuctionHouse.PlaceBid(self.purchaseData.auctionID, self.purchaseData.buyoutAmount)
    self.purchaseData = nil
  end
end

function CollectionatorBuyCheapestMixin:ProcessPurchaseData(purchaseData)
  self.purchaseData = purchaseData
  -- Check that there's something we can buy
  if self.purchaseData ~= nil and not self.purchaseData.containsAccountItem then
    local moneyString = GetMoneyString(self.purchaseData.buyoutAmount, true)
    if GetMoney() >= self.purchaseData.buyoutAmount then
      self.BuyButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_BUY_CHEAPEST_ITEM_X:format(moneyString))
    else
      self.BuyButton:Disable()
      self:UpdateActionText(COLLECTIONATOR_L_CANT_AFFORD_X:format(moneyString))
    end
    self.SkipButton:Enable()
  -- Nothing to buy for this item, select and query the next one
  else
    self:Skip()
  end
end

function CollectionatorBuyCheapestMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.CheapestResultReturn and self.focussed then
    local purchaseData, queryType = ...
    -- Check that the query corresponds to this tab
    if queryType ~= self:GetParent().queryType then
      return
    end

    self:ProcessPurchaseData(purchaseData)

  elseif event == Collectionator.Events.BuyQueryRequestAborted then
    local expectedEvent, returnData = ...
    if expectedEvent == Collectionator.Events.CheapestResultReturn then
      self.focussed = nil
      self.BuyButton:Enable()
      self.SkipButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_LOAD_FOR_PURCHASING)
    end

  elseif event == Collectionator.Events.DisplayedResultsUpdated then
    self.results = ...
    if self.focussed then
      self:Focus()
    else
      self:Reset()
    end

  else -- New results loading from a new full scan
    self:Reset()
  end
end

function CollectionatorBuyCheapestMixin:Query()

  self.SkipButton:Disable()
  self.BuyButton:Disable()
  self:UpdateActionText(COLLECTIONATOR_L_PROCESSING)
  DynamicResizeButton_Resize(self.BuyButton)

  Auctionator.EventBus:Fire(self, Collectionator.Events.BuyQueryRequest, {
    queryType = self:GetParent().queryType,
    itemLink = self.focussed.itemLink,
    returnEvent = Collectionator.Events.CheapestResultReturn,
    returnData = self:GetParent().queryType,
  })
end

function CollectionatorBuyCheapestMixin:Skip()
  self.offset = self.offset + 1
  self:Focus()
end
