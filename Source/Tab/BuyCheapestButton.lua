EVENT_BUS_EVENTS = {
  Collectionator.Events.CheapestResultReturn,
  Collectionator.Events.BuyQueryRequestAborted,
  Collectionator.Events.TMogPurchased,
  Collectionator.Events.PetPurchased,
  Collectionator.Events.ToyPurchased,
  Collectionator.Events.MountPurchased,
  Collectionator.Events.RecipePurchased,
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
  self.BuyButton:Disable()
  self:UpdateActionText(COLLECTIONATOR_L_LOAD_FOR_PURCHASING)
  Auctionator.EventBus:Fire(self, Collectionator.Events.FocusLink, nil)
end

function CollectionatorBuyCheapestMixin:Focus()
  local oldLink = self.focussed and self.focussed.itemLink
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
  end

  local currentLink = self.focussed and self.focussed.itemLink
  if currentLink ~= oldLink then
    Auctionator.EventBus:Fire(self, Collectionator.Events.FocusLink, currentLink)
    self:Query()
  end
end

function CollectionatorBuyCheapestMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)
  self:Reset()
end

function CollectionatorBuyCheapestMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)
end

function CollectionatorBuyCheapestMixin:UpdateActionText(text)
  self.BuyButton:SetText(text)
  DynamicResizeButton_Resize(self.BuyButton)
end

function CollectionatorBuyCheapestMixin:BuyOrStart()
  if not self.focussed or not self.purchaseData then
    self:Focus()
  else
    self.SkipButton:Disable()
    self.BuyButton:Disable()
    self:UpdateActionText(COLLECTIONATOR_L_PROCESSING)

    Auctionator.EventBus:Fire(self, Collectionator.Events.PurchaseAttempted, self.purchaseData.auctionID, self.purchaseData.itemLink)
    C_AuctionHouse.PlaceBid(self.purchaseData.auctionID, self.purchaseData.buyoutAmount)
    self.purchaseData = nil
  end
end

function CollectionatorBuyCheapestMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.CheapestResultReturn and self.focussed then
    local purchaseData, queryType = ...
    -- Check that the query corresponds to this tab
    if queryType ~= self:GetParent().queryType then
      return
    end

    self.purchaseData = purchaseData
    -- Check that there's something we can buy
    if self.purchaseData ~= nil and not self.purchaseData.containsAccountItem then
      self.BuyButton:Enable()
      self.SkipButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_BUY_CHEAPEST_ITEM:format(GetMoneyString(self.purchaseData.buyoutAmount, true)))
    else
      self:Skip()
    end
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
    self.BuyButton:Enable()
    if self.focussed then
      self:Focus()
    end
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
