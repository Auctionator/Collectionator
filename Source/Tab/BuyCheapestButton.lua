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
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
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

    Auctionator.EventBus:Fire(self, Collectionator.Events.PurchaseAttempted, self.purchaseData.auctionID)
    C_AuctionHouse.PlaceBid(self.purchaseData.auctionID, self.purchaseData.buyoutAmount)
    self.purchaseData = nil
  end
end

function CollectionatorBuyCheapestButtonMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.CheapestResultReturn then
    self.purchaseData = ...
    if self.purchaseData ~= nil then
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
    self:Focus()
  else
    self:Query()
  end
end

function CollectionatorBuyCheapestButtonMixin:Query()
  Auctionator.EventBus:Fire(self, Collectionator.Events.BuyQueryRequest, {
    queryType = self:GetParent().queryType,
    itemLink = self.focussed.itemLink,
    returnEvent = Collectionator.Events.CheapestResultReturn,
  })
end
