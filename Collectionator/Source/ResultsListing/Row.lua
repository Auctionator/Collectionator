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
    self:DoSearch()
  end
end

-- Override
function CollectionatorRowMixin:DoSearch()
  Auctionator.Debug.Message("CollectionatorRowMixin:DoSearch")
end

-- Override
function CollectionatorRowMixin:OnEvent(eventName, itemKey)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnEvent")
end
