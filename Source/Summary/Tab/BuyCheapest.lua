local EVENT_BUS_EVENTS = {
  Collectionator.Events.SummaryCheapestResultReturn,
  Collectionator.Events.SummaryContinueOnBuyCheapestWarning,
  Collectionator.Events.SummaryBuyQueryRequestAborted,
  Collectionator.Events.SummaryTMogLoadStart,
  Collectionator.Events.SummaryPetLoadStart,
  Collectionator.Events.SummaryToyLoadStart,
  Collectionator.Events.SummaryMountLoadStart,
  Collectionator.Events.SummaryRecipeLoadStart,
  Collectionator.Events.SummaryDisplayedResultsUpdated,
}

CollectionatorSummaryBuyCheapestMixin = {}

function CollectionatorSummaryBuyCheapestMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryBuyCheapestMixin")
  self:Reset()
end

function CollectionatorSummaryBuyCheapestMixin:Reset()
  self.focussed = nil
  self.purchaseData = nil
  self.results = nil
  self.offset = 1
  self.SkipButton:Disable()
  self.BuyButton:Enable()
  self:UpdateActionText(COLLECTIONATOR_L_START_PURCHASING)
end

function CollectionatorSummaryBuyCheapestMixin:Focus()
  local oldKeyString = self.focussed and Auctionator.Utilities.ItemKeyString(self.focussed.itemKey)
  if self.results then
    self.focussed = self.results[self.offset]
  else
    self.focussed = self:GetParent().DataProvider:GetEntryAt(self.offset)
  end

  if self.focussed ~= nil then
    local currentKeyString = self.focussed and Auctionator.Utilities.ItemKeyString(self.focussed.itemKey)
    if currentKeyString ~= oldKeyString then
      Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryFocusItem, currentKeyString)
      self:Query()
    end
  else
    self.BuyButton:Disable()
    self.SkipButton:Disable()
    self:UpdateActionText(COLLECTIONATOR_L_NO_ITEMS_LEFT)
  end
end

function CollectionatorSummaryBuyCheapestMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)
  if not Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_PURCHASE_WATCH) then
    self.SkipButton:Hide()
    self.BuyButton:Hide()
  else
    self.SkipButton:Show()
    self.BuyButton:Show()
    self:Reset()
    Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryFocusItem, nil)
  end
end

function CollectionatorSummaryBuyCheapestMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)
end

function CollectionatorSummaryBuyCheapestMixin:UpdateActionText(text)
  self.BuyButton:SetText(text)
  DynamicResizeButton_Resize(self.BuyButton)
end

function CollectionatorSummaryBuyCheapestMixin:BuyOrStart()
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

function CollectionatorSummaryBuyCheapestMixin:ProcessPurchaseData(purchaseData)
  self.purchaseData = purchaseData
  -- Check that there's something we can buy
  if self.purchaseData ~= nil and not self.purchaseData.containsAccountItem then
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
        Collectionator.Events.SummaryConfirmAndDelayEvent,
        COLLECTIONATOR_L_PRICE_INCREASED_BY_X:format(increasePercentage),
        Collectionator.Events.SummaryContinueOnBuyCheapestWarning,
        self:GetParent().queryType
      )
    end
  -- Nothing to buy for this item, select and query the next one
  else
    self:Skip()
  end
end

function CollectionatorSummaryBuyCheapestMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.SummaryCheapestResultReturn and self.focussed then
    local purchaseData, queryType = ...
    -- Check that the query corresponds to this tab
    if queryType ~= self:GetParent().queryType then
      return
    end

    self:ProcessPurchaseData(purchaseData)

  elseif event == Collectionator.Events.SummaryBuyQueryRequestAborted then
    local expectedEvent, returnData = ...
    if expectedEvent == Collectionator.Events.SummaryCheapestResultReturn then
      self.focussed = nil
      self.BuyButton:Enable()
      self.SkipButton:Enable()
      self:UpdateActionText(COLLECTIONATOR_L_START_PURCHASING)
    end

  elseif event == Collectionator.Events.SummaryDisplayedResultsUpdated then
    self.results = ...
    if self.focussed then
      self:Focus()
    else
      self:Reset()
    end

  elseif event == Collectionator.Events.ContinueOnBuyCheapestWarning then
    local queryType = ...
    if queryType == self:GetParent().queryType and self.focussed and self.purchaseData then
      self.BuyButton:Enable()
      self.SkipButton:Enable()
    end

  else -- New results loading from a new full scan
    self:Reset()
  end
end

function CollectionatorSummaryBuyCheapestMixin:Query()

  self.SkipButton:Disable()
  self.BuyButton:Disable()
  self:UpdateActionText(COLLECTIONATOR_L_PROCESSING)
  DynamicResizeButton_Resize(self.BuyButton)

  Auctionator.EventBus:Fire(self, Collectionator.Events.SummaryBuyQueryRequest, {
    queryType = self:GetParent().queryType,
    itemKey = self.focussed.itemKey,
    itemKeyInfo = self.focussed.itemKeyInfo,
    returnEvent = Collectionator.Events.SummaryCheapestResultReturn,
    returnData = self:GetParent().queryType,
  })
end

function CollectionatorSummaryBuyCheapestMixin:Skip()
  self.offset = self.offset + 1
  self:Focus()
end
