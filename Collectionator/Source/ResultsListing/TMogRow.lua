CollectionatorTMogRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorTMogRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorTMogRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorTMogRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorTMogRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    Auctionator.API.v1.MultiSearchExact("Collectionator", {self.rowData.name})
  end
end
