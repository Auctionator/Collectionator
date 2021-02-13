CollectionatorRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    self:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
    self:StartSearch()
  end
end

-- Override
function CollectionatorRowMixin:StartSearch()
  Auctionator.Debug.Message("CollectionatorRowMixin:StartSearch")
end

-- Override
function CollectionatorRowMixin:GetSearchResult(itemKey)
  Auctionator.Debug.Message("CollectionatorRowMixin:GetResult")
end

function CollectionatorRowMixin:OnEvent(eventName, itemKey)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnEvent")
  self:UnregisterEvent("ITEM_SEARCH_RESULTS_UPDATED")

  Auctionator.EventBus
    :RegisterSource(self, "CollectionatorRowMixin")
    :Fire(self, Collectionator.Events.ShowBuyoutOptions, self:GetSearchResult(itemKey), self.rowData)
    :UnregisterSource(self)
end
