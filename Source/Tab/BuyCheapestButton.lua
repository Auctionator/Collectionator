EVENT_BUS_EVENTS = {
  Collectionator.Events.CheapestResultReturn,
  Collectionator.Events.TMogPurchased,
  Collectionator.Events.PetPurchased,
  Collectionator.Events.ToyPurchased,
  Collectionator.Events.MountPurchased,
  Collectionator.Events.RecipePurchased,
  Collectionator.Events.DisplayedResultsUpdated,
}

CollectionatorBuyCheapestButtonMixin = {}

function CollectionatorBuyCheapestButtonMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorBuyCheapestButtonMixin")
  self:Reset()
end

function CollectionatorBuyCheapestButtonMixin:Reset()
  self:Enable()
  self.focussed = nil
  self.purchaseData = nil
  self.results = nil
  self.offset = 1
  self:SetText(COLLECTIONATOR_L_LOAD_FOR_PURCHASING)
  DynamicResizeButton_Resize(self)
end

function CollectionatorBuyCheapestButtonMixin:Focus()
  local oldLink = self.focussed and self.focussed.itemLink
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
  end

  local currentLink = self.focussed and self.focussed.itemLink
  if currentLink ~= oldLink then
    Auctionator.EventBus:Fire(self, Collectionator.Events.FocusLink, currentLink)
  end
end

function CollectionatorBuyCheapestButtonMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)
  self:Reset()
end

function CollectionatorBuyCheapestButtonMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)
end

function CollectionatorBuyCheapestButtonMixin:OnClick()
  if not self.focussed or not self.purchaseData then
    self:Disable()
    self:SetText(COLLECTIONATOR_L_PROCESSING)
    DynamicResizeButton_Resize(self)

    self:Focus()
    self:Query()
  else
    self:Disable()
    self:SetText(COLLECTIONATOR_L_PROCESSING)
    DynamicResizeButton_Resize(self)

    DevTools_Dump(self.purchaseData)
    Auctionator.EventBus:Fire(self, Collectionator.Events.PurchaseAttempted, self.purchaseData.auctionID)
    C_AuctionHouse.PlaceBid(self.purchaseData.auctionID, self.purchaseData.buyoutAmount)
    self.purchaseData = nil
  end
end

function CollectionatorBuyCheapestButtonMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.CheapestResultReturn then
    local purchaseData, queryType = ...
    -- Check that the query corresponds to this tab
    if queryType ~= self:GetParent().queryType then
      return
    end

    self.purchaseData = purchaseData
    -- Check that there's something we can buy
    if self.purchaseData ~= nil and not self.purchaseData.containsAccountItem then
      self:Enable()
      self:SetText(COLLECTIONATOR_L_BUY_CHEAPEST_ITEM:format(GetMoneyString(self.purchaseData.buyoutAmount, true)))
      DynamicResizeButton_Resize(self)
    else
      self.offset = self.offset + 1
      self:Focus()
      self:Query()
    end
  elseif event == Collectionator.Events.DisplayedResultsUpdated then
    self.results = ...
    if self.focussed then
      self:Focus()
    end
  else
    self:Query()
  end
end

function CollectionatorBuyCheapestButtonMixin:Query()
  Auctionator.EventBus:Fire(self, Collectionator.Events.BuyQueryRequest, {
    queryType = self:GetParent().queryType,
    itemLink = self.focussed.itemLink,
    returnEvent = Collectionator.Events.CheapestResultReturn,
    returnData = self:GetParent().queryType,
  })
end
