local EVENT_BUS_EVENTS = {
  Collectionator.Events.ReplicateCheapestResultReturn,
  Collectionator.Events.ReplicateContinueOnBuyCheapestWarning,
  Collectionator.Events.ReplicateBuyQueryRequestAborted,
  Collectionator.Events.SourceLoadStart,
  Collectionator.Events.PetLoadStart,
  Collectionator.Events.ToyLoadStart,
  Collectionator.Events.MountLoadStart,
  Collectionator.Events.RecipeLoadStart,
  Collectionator.Events.ReplicateDisplayedResultsUpdated,
}

CollectionatorReplicateBuyCheapestMixin = {}

function CollectionatorReplicateBuyCheapestMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorReplicateBuyCheapestMixin")
  self:Reset()
end

function CollectionatorReplicateBuyCheapestMixin:Reset()
  self.focussed = nil
  self.purchaseData = nil
  self.results = nil
  self.offset = 1
  self.SkipButton:Disable()
  self.BuyButton:Enable()
  self:UpdateActionText(COLLECTIONATOR_L_START_PURCHASING)
end

function CollectionatorReplicateBuyCheapestMixin:Focus()
  local oldLink = self.focussed and self.focussed.itemLink
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
  end

  if self.focussed ~= nil then
    local currentLink = self.focussed and self.focussed.itemLink
    if currentLink ~= oldLink then
      Auctionator.EventBus:Fire(self, Collectionator.Events.ReplicateFocusLink, currentLink)
      self:Query()
    end
  else
    self.BuyButton:Disable()
    self.SkipButton:Disable()
    self:UpdateActionText(COLLECTIONATOR_L_NO_ITEMS_LEFT)
  end
end

function CollectionatorReplicateBuyCheapestMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)
  if not Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_PURCHASE_WATCH) then
    self.SkipButton:Hide()
    self.BuyButton:Hide()
  else
    self.SkipButton:Show()
    self.BuyButton:Show()
    self:Reset()
    Auctionator.EventBus:Fire(self, Collectionator.Events.ReplicateFocusLink, nil)
  end
end

function CollectionatorReplicateBuyCheapestMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)
end

function CollectionatorReplicateBuyCheapestMixin:UpdateActionText(text)
  self.BuyButton:SetText(text)
  DynamicResizeButton_Resize(self.BuyButton)
end

function CollectionatorReplicateBuyCheapestMixin:BuyOrStart()
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

function CollectionatorReplicateBuyCheapestMixin:ProcessPurchaseData(purchaseData)
  self.purchaseData = purchaseData
  -- Check that there's something we can buy
  if self.purchaseData ~= nil and not self.purchaseData.containsAccountItem and self.purchaseData.buyoutAmount then
    local moneyString = GetMoneyString(self.purchaseData.buyoutAmount, true)
    if GetMoney() >= self.purchaseData.buyoutAmount then
      self.BuyButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_BUY_ITEM_X:format(moneyString))
    else
      self.BuyButton:Disable()
      self:UpdateActionText(COLLECTIONATOR_L_CANT_AFFORD_X:format(moneyString))
    end
    self.SkipButton:Enable()

    if self.BuyButton:IsEnabled() and self.purchaseData.buyoutAmount >= Collectionator.Constants.BuyWarningFactor * self.focussed.price then
      self.BuyButton:Disable()
      self.SkipButton:Disable()
      local increasePercentage = ((self.purchaseData.buyoutAmount - self.focussed.price) / self.focussed.price * 100) .. "%"
      Auctionator.EventBus:Fire(
        self,
        Collectionator.Events.ConfirmAndDelayEvent,
        COLLECTIONATOR_L_PRICE_INCREASED_BY_X:format(increasePercentage),
        Collectionator.Events.ContinueOnBuyCheapestWarning,
        self:GetParent().queryType
      )
    end
  -- Nothing to buy for this item, select and query the next one
  else
    self:Skip()
  end
end

function CollectionatorReplicateBuyCheapestMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.ReplicateCheapestResultReturn and self.focussed then
    local purchaseData, queryType = ...
    -- Check that the query corresponds to this tab
    if queryType ~= self:GetParent().queryType then
      return
    end

    self:ProcessPurchaseData(purchaseData)

  elseif event == Collectionator.Events.ReplicateBuyQueryRequestAborted then
    local expectedEvent, returnData = ...
    if expectedEvent == Collectionator.Events.CheapestResultReturn then
      self.focussed = nil
      self.BuyButton:Enable()
      self.SkipButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_START_PURCHASING)
    end

  elseif event == Collectionator.Events.ReplicateDisplayedResultsUpdated then
    self.results = ...
    if self.focussed then
      self:Focus()
    else
      self:Reset()
    end

  elseif event == Collectionator.Events.ReplicateContinueOnBuyCheapestWarning then
    local queryType = ...
    if queryType == self:GetParent().queryType and self.focussed and self.purchaseData then
      self.BuyButton:Enable()
      self.SkipButton:Enable()
    end

  else -- New results loading from a new full scan
    self:Reset()
  end
end

function CollectionatorReplicateBuyCheapestMixin:Query()

  self.SkipButton:Disable()
  self.BuyButton:Disable()
  self:UpdateActionText(COLLECTIONATOR_L_PROCESSING)
  DynamicResizeButton_Resize(self.BuyButton)

  Auctionator.EventBus:Fire(self, Collectionator.Events.ReplicateBuyQueryRequest, {
    queryType = self:GetParent().queryType,
    itemLink = self.focussed.itemLink,
    returnEvent = Collectionator.Events.ReplicateCheapestResultReturn,
    returnData = self:GetParent().queryType,
  })
end

function CollectionatorReplicateBuyCheapestMixin:Skip()
  self.offset = self.offset + 1
  self:Focus()
end
